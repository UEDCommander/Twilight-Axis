import { useState } from 'react';
import { Button, Section } from 'tgui-core/components';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Side = 'one' | 'two';
type CardRow = 'infantry' | 'archers' | 'siege';
type CardRarity = 'base' | 'rare' | 'unique';

type Card = {
  id: string;
  name: string;
  desc: string;
  row: CardRow | 'weather';
  power: number;
  currentPower?: number;
  rarity: CardRarity;
  effect: string;
  combo: string;
  targetRow?: CardRow;
  art?: string;
};

type Data = {
  waiting?: boolean;
  offeredName?: string;
  mySide?: Side;
  turn?: Side;
  players?: Record<Side, string>;
  wins?: Record<Side, number>;
  passed?: Record<Side, boolean>;
  scores?: Record<Side, number>;
  round?: number;
  result?: string;
  message?: string;
  weather?: string[];
  weatherCards?: Card[];
  rowEffects?: Record<Side, Record<CardRow, Card[]>>;
  hand?: Card[];
  opponentHandCount?: number;
  board?: Record<Side, Record<CardRow, Card[]>>;
};

const rowLabels: Record<CardRow, string> = {
  infantry: 'Infantry',
  archers: 'Archers',
  siege: 'Siege',
};

const cardTypeLabels: Record<CardRow | 'weather', string> = {
  ...rowLabels,
  weather: 'Weather',
};

const rarityColor: Record<CardRarity, string> = {
  base: '#f8fafc',
  rare: '#60a5fa',
  unique: '#fbbf24',
};

const sideLabels: Record<Side, string> = {
  one: 'Player One',
  two: 'Player Two',
};

const sideAccent: Record<Side, string> = {
  one: '#38bdf8',
  two: '#ef4444',
};

const effectBadges: Record<string, string> = {
  morale: 'MOR',
  scorch: 'SC',
  scorch_infantry: 'SC',
  scorch_global: 'SC',
  spy: 'SPY',
  medic: 'MED',
  bond: 'BND',
  agile: 'AGI',
  muster: 'MUS',
  horn: 'HORN',
  decoy: 'DEC',
  berserk: 'BER',
  mardroeme: 'MAR',
  avenger: 'AVG',
};

const effectDescriptions: Record<string, string> = {
  morale: 'Прилив сил: +1 к силе остальных отрядов в этом ряду.',
  scorch: 'Казнь: уничтожает сильнейшую карту противника.',
  scorch_infantry: 'Казнь: уничтожает сильнейшую пехоту врага, если его пехота имеет 10+ силы.',
  scorch_global: 'Казнь: уничтожает сильнейшую карту или карты на поле.',
  spy: 'Шпион: кладётся на поле врага и даёт вам две карты.',
  medic: 'Медик: возвращает сильнейшую отбитую карту на поле.',
  bond: 'Прочная связь: одинаковые карты с этим умением усиливают друг друга.',
  agile: 'Проворство: тестовая метка гибкой карты.',
  muster: 'Двойник: выкладывает такие же карты из руки и колоды.',
  horn: 'Командирский рог: удваивает силу выбранного ряда на раунд.',
  decoy: 'Чучело: возвращает сильнейшую вашу карту с поля в руку.',
  berserk: 'Берсерк: под Мардрёмом превращается в медведя.',
  mardroeme: 'Мардрём: превращает берсерков в ряду в медведей.',
  avenger: 'Призвание Мстителя: при уничтожении призывает сильную карту на своё место.',
  clear_weather: 'Ясная погода: снимает всю погоду.',
  frost: 'Мороз: снижает пехоту до 1.',
  fog: 'Туман: снижает лучников до 1.',
  rain: 'Дождь: снижает осаду до 1.',
};

const cardTooltip = (card: Card) => {
  const lines = [
    card.name,
    `Type: ${cardTypeLabels[card.row]}`,
    `Power: ${card.power}`,
  ];
  if (effectDescriptions[card.effect]) {
    lines.push(`Effect: ${effectDescriptions[card.effect]}`);
  } else if (card.desc) {
    lines.push(card.desc);
  }
  return lines;
};

const cardBoxStyle = (card: Card, compact = false) => ({
  position: 'relative' as const,
  width: compact ? '54px' : '86px',
  aspectRatio: '1 / 1.6',
  padding: compact ? '3px' : '4px',
  border: `2px solid ${rarityColor[card.rarity]}`,
  borderRadius: '4px',
  background: 'linear-gradient(180deg, rgba(35,39,48,0.98), rgba(14,16,22,0.98))',
  boxShadow: `0 0 0 1px rgba(0,0,0,0.7), 0 0 10px ${rarityColor[card.rarity]}33`,
  display: 'flex',
  flexDirection: 'column' as const,
  justifyContent: 'space-between',
  overflow: 'hidden',
});

const CardView = ({
  card,
  compact = false,
  onClick,
}: {
  card: Card;
  compact?: boolean;
  onClick?: () => void;
}) => {
  const [hovered, setHovered] = useState(false);
  const tooltip = cardTooltip(card);
  return (
    <div
      style={{
        ...cardBoxStyle(card, compact),
        cursor: onClick ? 'pointer' : 'default',
      }}
      onClick={onClick}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
    >
    {!!card.art && (
      <img
        src={resolveAsset(card.art)}
        style={{
          position: 'absolute',
          inset: 0,
          width: '100%',
          height: '100%',
          objectFit: 'cover',
          zIndex: 0,
        }}
      />
    )}
    <div
      style={{
        position: 'absolute',
        inset: 0,
        background:
          'linear-gradient(180deg, rgba(0,0,0,0.34), rgba(0,0,0,0.04) 32%, rgba(0,0,0,0.62))',
        zIndex: 0,
      }}
    />
    <div
      style={{
        position: 'relative',
        zIndex: 1,
        color: rarityColor[card.rarity],
        fontSize: compact ? '6px' : '8px',
        fontWeight: 700,
        textAlign: 'center',
        textTransform: 'uppercase',
        whiteSpace: 'nowrap',
        overflow: 'hidden',
        textOverflow: 'ellipsis',
      }}
    >
      {cardTypeLabels[card.row]}
    </div>
    {!!effectBadges[card.effect] && (
      <div
        style={{
          position: 'absolute',
          top: compact ? '14px' : '20px',
          left: '50%',
          transform: 'translateX(-50%)',
          minWidth: compact ? '17px' : '24px',
          height: compact ? '13px' : '17px',
          padding: '0 3px',
          borderRadius: '9px',
          backgroundColor: 'rgba(248,250,252,0.94)',
          color: '#0f172a',
          fontSize: compact ? '5px' : '7px',
          fontWeight: 900,
          lineHeight: compact ? '13px' : '17px',
          textAlign: 'center',
          zIndex: 2,
        }}
      >
        {effectBadges[card.effect]}
      </div>
    )}
    {hovered && (
      <div
        style={{
          position: 'absolute',
          left: compact ? '8px' : '10px',
          right: compact ? '8px' : '10px',
          top: compact ? '30px' : '42px',
          padding: compact ? '5px' : '7px',
          border: '1px solid rgba(248,250,252,0.85)',
          borderRadius: '4px',
          backgroundColor: 'rgba(5,7,11,0.96)',
          color: '#f8fafc',
          fontSize: compact ? '6px' : '8px',
          lineHeight: 1.25,
          zIndex: 5,
          boxShadow: '0 4px 12px rgba(0,0,0,0.75)',
          pointerEvents: 'none',
        }}
      >
        <div style={{ color: rarityColor[card.rarity], fontWeight: 900, marginBottom: '3px' }}>
          {tooltip[0]}
        </div>
        {tooltip.slice(1).map((line) => (
          <div key={line}>{line}</div>
        ))}
      </div>
    )}

    <div
      style={{
        position: 'relative',
        zIndex: 1,
        display: 'grid',
        gridTemplateColumns: compact ? '16px 1fr' : '23px 1fr',
        alignItems: 'center',
        width: '100%',
        minHeight: compact ? '16px' : '22px',
      }}
    >
      <div
        style={{
          width: compact ? '16px' : '23px',
          height: compact ? '16px' : '23px',
          borderRadius: '50%',
          backgroundColor: '#05070b',
          border: `2px solid ${rarityColor[card.rarity]}`,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: '#f8fafc',
          fontSize: compact ? '8px' : '12px',
          fontWeight: 700,
          zIndex: 1,
        }}
      >
        {card.currentPower ?? card.power}
      </div>
      <div
        style={{
          marginLeft: compact ? '-3px' : '-4px',
          padding: compact ? '2px 3px 2px 5px' : '3px 4px 3px 7px',
          border: `1px solid ${rarityColor[card.rarity]}`,
          backgroundColor: 'rgba(5,7,11,0.92)',
          color: '#f8fafc',
          fontSize: compact ? '6px' : '8px',
          fontWeight: 700,
          lineHeight: 1.1,
          whiteSpace: 'nowrap',
          overflow: 'hidden',
          textOverflow: 'ellipsis',
        }}
      >
        {card.name}
      </div>
    </div>
    </div>
  );
};

const RowView = ({
  row,
  title,
  cards,
  weathered,
}: {
  row: CardRow;
  title: string;
  cards: Card[];
  weathered: boolean;
}) => {
  const total = cards.reduce((sum, card) => sum + (card.currentPower ?? card.power), 0);
  return (
    <div
      style={{
        position: 'relative',
        display: 'grid',
        gridTemplateColumns: '54px 1fr 42px',
        gap: '8px',
        alignItems: 'center',
        minHeight: '72px',
        padding: '5px 8px',
        borderTop: '1px solid rgba(255,255,255,0.16)',
        borderBottom: '1px solid rgba(0,0,0,0.6)',
        background:
          'linear-gradient(90deg, rgba(45,30,18,0.92), rgba(116,91,58,0.78) 18%, rgba(72,55,35,0.84) 74%, rgba(22,19,18,0.9)), repeating-linear-gradient(0deg, rgba(255,255,255,0.05) 0 1px, transparent 1px 18px)',
        boxShadow: 'inset 0 0 16px rgba(0,0,0,0.55)',
        overflow: 'hidden',
      }}
    >
      {weathered && (
        <div
          style={{
            position: 'absolute',
            inset: 0,
            background:
              row === 'infantry'
                ? 'linear-gradient(90deg, rgba(147,197,253,0.26), rgba(219,234,254,0.16), rgba(147,197,253,0.24))'
                : 'linear-gradient(90deg, rgba(148,163,184,0.24), rgba(203,213,225,0.12), rgba(100,116,139,0.24))',
            boxShadow: 'inset 0 0 18px rgba(239,68,68,0.45)',
            pointerEvents: 'none',
          }}
        />
      )}
      <div
        style={{
          position: 'relative',
          zIndex: 1,
          color: weathered ? '#fecaca' : '#e5e7eb',
          fontSize: '11px',
          fontWeight: 700,
          textTransform: 'uppercase',
        }}
      >
        {title}
      </div>
      <div
        style={{
          position: 'relative',
          zIndex: 1,
          display: 'flex',
          gap: '4px',
          minHeight: '58px',
          alignItems: 'center',
          flexWrap: 'wrap',
          borderLeft: '1px solid rgba(15,23,42,0.55)',
          borderRight: '1px solid rgba(15,23,42,0.55)',
          padding: '2px 6px',
        }}
      >
        {cards.map((card, index) => (
          <CardView key={`${card.id}-${index}`} card={card} compact />
        ))}
      </div>
      <div
        style={{
          position: 'relative',
          zIndex: 1,
          width: '34px',
          height: '34px',
          borderRadius: '4px',
          border: `2px solid ${weathered ? '#ef4444' : '#111827'}`,
          background: weathered
            ? 'linear-gradient(180deg, #7f1d1d, #1f1111)'
            : 'linear-gradient(180deg, #263447, #0f172a)',
          color: weathered ? '#fecaca' : '#f8fafc',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          textAlign: 'center',
          fontSize: '17px',
          fontWeight: 800,
          boxShadow: '0 1px 0 rgba(255,255,255,0.15), inset 0 0 8px rgba(0,0,0,0.65)',
        }}
      >
        {total}
      </div>
    </div>
  );
};

const PlayerBoard = ({
  side,
  data,
}: {
  side: Side;
  data: Data;
}) => {
  const board = data.board?.[side];
  const weather = data.weather || [];
  const score = data.scores?.[side] ?? 0;
  const rows: CardRow[] =
    side === 'two' ? ['siege', 'archers', 'infantry'] : ['infantry', 'archers', 'siege'];
  return (
    <div
      style={{
        border: `2px solid ${sideAccent[side]}99`,
        background: 'linear-gradient(180deg, rgba(15,23,42,0.92), rgba(8,11,17,0.94))',
        boxShadow: 'inset 0 0 18px rgba(0,0,0,0.65)',
      }}
    >
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '1fr auto auto',
          gap: '10px',
          alignItems: 'center',
          padding: '5px 8px',
          background: `linear-gradient(90deg, ${sideAccent[side]}33, rgba(15,23,42,0.92))`,
          borderBottom: '1px solid rgba(255,255,255,0.12)',
        }}
      >
        <div style={{ color: '#f8fafc', fontWeight: 800 }}>
          {data.players?.[side] || sideLabels[side]}
          {data.passed?.[side] ? ' | Passed' : ''}
        </div>
        <div style={{ color: '#cbd5e1' }}>Wins {data.wins?.[side] ?? 0}</div>
        <div
          style={{
            minWidth: '46px',
            color: sideAccent[side],
            fontSize: '22px',
            fontWeight: 900,
            textAlign: 'right',
          }}
        >
          {score}
        </div>
      </div>
      {rows.map((row) => (
        <RowView
          key={row}
          row={row}
          title={rowLabels[row]}
          cards={board?.[row] || []}
          weathered={weather.includes(row)}
        />
      ))}
    </div>
  );
};

const BattleBoard = ({
  data,
  weatherCards,
}: {
  data: Data;
  weatherCards: Card[];
}) => (
  <div
    style={{
      padding: '10px',
      border: '3px solid #1f2937',
      background:
        'linear-gradient(90deg, #27170d, #6b4a28 8%, #2a1c12 50%, #6b4a28 92%, #1b120b)',
      boxShadow:
        'inset 0 0 0 2px rgba(255,255,255,0.12), inset 0 0 28px rgba(0,0,0,0.85), 0 0 22px rgba(0,0,0,0.65)',
    }}
  >
    <div
      style={{
        display: 'grid',
        gridTemplateColumns: '1fr 1fr',
        gap: '8px',
        marginBottom: '8px',
        minHeight: '46px',
      }}
    >
      <div
        style={{
          padding: '5px 8px',
          border: '1px solid rgba(255,255,255,0.16)',
          background: 'linear-gradient(90deg, rgba(5,7,11,0.72), rgba(30,41,59,0.55))',
        }}
      >
        <div style={{ color: '#cbd5e1', fontSize: '11px', fontWeight: 800, marginBottom: '4px' }}>
          WEATHER
        </div>
        <div style={{ display: 'flex', gap: '5px', flexWrap: 'wrap' }}>
          {weatherCards.map((card, index) => (
            <CardView key={`${card.id}-${index}`} card={card} compact />
          ))}
        </div>
      </div>
      <div
        style={{
          padding: '5px 8px',
          border: '1px solid rgba(255,255,255,0.16)',
          background: 'linear-gradient(90deg, rgba(5,7,11,0.72), rgba(55,65,81,0.5))',
        }}
      >
        <div style={{ color: '#cbd5e1', fontSize: '11px', fontWeight: 800, marginBottom: '4px' }}>
          ROW EFFECTS
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '5px' }}>
          {(['infantry', 'archers', 'siege'] as CardRow[]).map((row) => (
            <div
              key={row}
              style={{
                minHeight: '36px',
                padding: '4px',
                border: '1px dashed rgba(203,213,225,0.28)',
                color: '#94a3b8',
                fontSize: '10px',
                fontWeight: 700,
                textAlign: 'center',
                textTransform: 'uppercase',
              }}
            >
              <div style={{ marginBottom: '4px' }}>{rowLabels[row]}</div>
              <div style={{ display: 'flex', justifyContent: 'center', gap: '3px', flexWrap: 'wrap' }}>
                {(['two', 'one'] as Side[]).flatMap((side) =>
                  (data.rowEffects?.[side]?.[row] || []).map((card, index) => (
                    <CardView key={`${side}-${row}-${card.id}-${index}`} card={card} compact />
                  )),
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
    <PlayerBoard side="two" data={data} />
    <div
      style={{
        height: '6px',
        background: 'linear-gradient(90deg, #111827, #94a3b8, #111827)',
        borderTop: '1px solid rgba(255,255,255,0.18)',
        borderBottom: '1px solid rgba(0,0,0,0.8)',
      }}
    />
    <PlayerBoard side="one" data={data} />
  </div>
);

export const CardTable = () => {
  const { act, data } = useBackend<Data>();

  if (data.waiting) {
    return (
      <Window title="Card Battle" width={420} height={180}>
        <Window.Content>
          <Section title="Invitation">
            {data.offeredName || 'Someone'} is waiting for an opponent.
            Strike this deck with your own deck to begin.
          </Section>
        </Window.Content>
      </Window>
    );
  }

  const hand = data.hand || [];
  const weatherCards = data.weatherCards || [];
  const myTurn = data.mySide && data.turn === data.mySide && !data.result;
  const weather = data.weather?.length ? data.weather.join(', ') : 'Clear';

  return (
    <Window title="Card Battle" width={1180} height={760}>
      <Window.Content scrollable>
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: '1fr 360px',
            gap: '12px',
          }}
        >
          <div>
            <BattleBoard data={data} weatherCards={weatherCards} />
          </div>

          <div>
            <Section title="Match">
              <div style={{ marginBottom: '8px' }}>
                <b>Round:</b> {data.round || 1}
              </div>
              <div style={{ marginBottom: '8px' }}>
                <b>Turn:</b> {data.turn ? data.players?.[data.turn] : 'None'}
              </div>
              <div style={{ marginBottom: '8px' }}>
                <b>You:</b> {data.mySide ? data.players?.[data.mySide] : 'Observer'}
              </div>
              <div style={{ marginBottom: '8px' }}>
                <b>Opponent hand:</b> {data.opponentHandCount ?? 0}
              </div>
              <div style={{ marginBottom: '8px' }}>
                <b>Weather:</b> {weather}
              </div>
              {data.message && (
                <div style={{ color: '#d9f99d', marginBottom: '8px' }}>{data.message}</div>
              )}
              {data.result && (
                <div style={{ color: '#fbbf24', marginBottom: '8px', fontWeight: 700 }}>
                  {data.result}
                </div>
              )}
              <Button disabled={!myTurn} onClick={() => act('pass')}>
                Pass
              </Button>
              <Button disabled={!data.result} onClick={() => act('collect')}>
                Collect Decks
              </Button>
            </Section>
            <Section title={`Hand | ${hand.length} cards`}>
              <div
                style={{
                  display: 'grid',
                  gridTemplateColumns: 'repeat(3, 86px)',
                  gap: '8px',
                }}
              >
                {hand.map((card, index) => (
                  <CardView
                    key={`${card.id}-${index}`}
                    card={card}
                    onClick={myTurn ? () => act('play', { card: card.id }) : undefined}
                  />
                ))}
              </div>
            </Section>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};
