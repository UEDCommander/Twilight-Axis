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
  hand?: Card[];
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

const cardBoxStyle = (card: Card, compact = false) => ({
  position: 'relative' as const,
  width: compact ? '76px' : '118px',
  aspectRatio: '1 / 1.6',
  padding: compact ? '4px' : '6px',
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
}) => (
  <div
    style={{
      ...cardBoxStyle(card, compact),
      cursor: onClick ? 'pointer' : 'default',
    }}
    onClick={onClick}
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
        fontSize: compact ? '7px' : '10px',
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

    <div
      style={{
        position: 'relative',
        zIndex: 1,
        display: 'grid',
        gridTemplateColumns: compact ? '22px 1fr' : '30px 1fr',
        alignItems: 'center',
        width: '100%',
        minHeight: compact ? '22px' : '28px',
      }}
    >
      <div
        style={{
          width: compact ? '22px' : '30px',
          height: compact ? '22px' : '30px',
          borderRadius: '50%',
          backgroundColor: '#05070b',
          border: `2px solid ${rarityColor[card.rarity]}`,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: '#f8fafc',
          fontSize: compact ? '10px' : '15px',
          fontWeight: 700,
          zIndex: 1,
        }}
      >
        {card.currentPower ?? card.power}
      </div>
      <div
        style={{
          marginLeft: compact ? '-4px' : '-5px',
          padding: compact ? '3px 4px 3px 7px' : '4px 5px 4px 9px',
          border: `1px solid ${rarityColor[card.rarity]}`,
          backgroundColor: 'rgba(5,7,11,0.92)',
          color: '#f8fafc',
          fontSize: compact ? '7px' : '10px',
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

const RowView = ({
  title,
  cards,
}: {
  title: string;
  cards: Card[];
}) => {
  const total = cards.reduce((sum, card) => sum + (card.currentPower ?? card.power), 0);
  return (
    <div
      style={{
        display: 'grid',
        gridTemplateColumns: '90px 1fr 42px',
        gap: '8px',
        alignItems: 'center',
        minHeight: '130px',
        padding: '6px',
        borderBottom: '1px solid rgba(255,255,255,0.08)',
      }}
    >
      <div style={{ color: '#cbd5e1', fontWeight: 700 }}>{title}</div>
      <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap' }}>
        {cards.map((card, index) => (
          <CardView key={`${card.id}-${index}`} card={card} compact />
        ))}
      </div>
      <div style={{ textAlign: 'center', fontSize: '22px', fontWeight: 700 }}>
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
  return (
    <Section
      title={`${data.players?.[side] || sideLabels[side]} | Score ${
        data.scores?.[side] ?? 0
      } | Wins ${data.wins?.[side] ?? 0}${data.passed?.[side] ? ' | Passed' : ''}`}
    >
      <RowView title={rowLabels.infantry} cards={board?.infantry || []} />
      <RowView title={rowLabels.archers} cards={board?.archers || []} />
      <RowView title={rowLabels.siege} cards={board?.siege || []} />
    </Section>
  );
};

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
  const myTurn = data.mySide && data.turn === data.mySide && !data.result;
  const weather = data.weather?.length ? data.weather.join(', ') : 'Clear';

  return (
    <Window title="Card Battle" width={1180} height={760}>
      <Window.Content scrollable>
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: '1fr 300px',
            gap: '12px',
          }}
        >
          <div>
            <PlayerBoard side="two" data={data} />
            <PlayerBoard side="one" data={data} />
            <Section title={`Hand | ${hand.length} cards`}>
              <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
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
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};
