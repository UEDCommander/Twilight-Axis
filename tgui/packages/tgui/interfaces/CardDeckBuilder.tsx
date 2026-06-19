import { useMemo, useState } from 'react';
import { Button, Input, ProgressBar, Section } from 'tgui-core/components';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type CardRow = 'infantry' | 'archers' | 'siege' | 'weather';
type CardRarity = 'base' | 'rare' | 'unique';

type Card = {
  id: string;
  name: string;
  desc: string;
  row: CardRow;
  power: number;
  rarity: CardRarity;
  effect: string;
  combo: string;
  art?: string;
  ownedCount?: number;
  known: boolean;
  selected: boolean;
};

type Data = {
  mode?: 'pool' | 'build';
  cards?: Card[];
  selected?: string[];
  selectedCount: number;
  deckSize: number;
  knownRareCount: number;
  canRequestDeck?: boolean;
};

const rowLabels: Record<CardRow, string> = {
  infantry: 'Infantry',
  archers: 'Archers',
  siege: 'Siege',
  weather: 'Weather',
};

const rarityColor: Record<CardRarity, string> = {
  base: '#f8fafc',
  rare: '#60a5fa',
  unique: '#fbbf24',
};

const cardType = (card: Card) => rowLabels[card.row];

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
    card.known ? card.name : 'Unknown',
    `Type: ${cardType(card)}`,
    `Power: ${card.power}`,
  ];
  if (card.known && effectDescriptions[card.effect]) {
    lines.push(`Effect: ${effectDescriptions[card.effect]}`);
  } else if (card.known && card.desc) {
    lines.push(card.desc);
  }
  if (card.rarity !== 'base') {
    lines.push(`Owned: ${card.ownedCount || 0}`);
  }
  return lines;
};

const CardFace = ({
  card,
  disabled = false,
  unavailable = false,
  compact = false,
  count = 0,
  onClick,
  onRightClick,
}: {
  card: Card;
  disabled?: boolean;
  unavailable?: boolean;
  compact?: boolean;
  count?: number;
  onClick?: () => void;
  onRightClick?: () => void;
}) => {
  const [hovered, setHovered] = useState(false);
  const tooltip = cardTooltip(card);
  return (
    <div
      style={{
        position: 'relative',
        aspectRatio: '1 / 1.6',
        width: compact ? '88px' : '118px',
        padding: compact ? '4px' : '6px',
        border: `2px solid ${rarityColor[card.rarity]}`,
        borderRadius: '4px',
        background: 'linear-gradient(180deg, rgba(35,39,48,0.98), rgba(14,16,22,0.98))',
        boxShadow: `0 0 0 1px rgba(0,0,0,0.7), 0 0 10px ${rarityColor[card.rarity]}33`,
        cursor: onClick && !disabled ? 'pointer' : 'default',
        opacity: disabled && !unavailable ? 0.62 : 1,
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'space-between',
        overflow: 'hidden',
      }}
      onClick={!disabled ? onClick : undefined}
      onContextMenu={(event) => {
        if (!onRightClick) {
          return;
        }
        event.preventDefault();
        onRightClick();
      }}
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
          filter: unavailable ? 'grayscale(1) brightness(0.16) contrast(0.85)' : undefined,
          zIndex: 0,
        }}
      />
    )}
    <div
      style={{
        position: 'absolute',
        inset: 0,
        background:
          unavailable
            ? 'linear-gradient(180deg, rgba(0,0,0,0.84), rgba(0,0,0,0.78) 32%, rgba(0,0,0,0.94))'
            : 'linear-gradient(180deg, rgba(0,0,0,0.34), rgba(0,0,0,0.04) 32%, rgba(0,0,0,0.62))',
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
        width: '100%',
        whiteSpace: 'nowrap',
        overflow: 'hidden',
        textOverflow: 'ellipsis',
      }}
    >
      {cardType(card)}
    </div>
    {card.known && !!effectBadges[card.effect] && (
      <div
        style={{
          position: 'absolute',
          top: compact ? '18px' : '28px',
          left: '50%',
          transform: 'translateX(-50%)',
          minWidth: compact ? '22px' : '30px',
          height: compact ? '15px' : '20px',
          padding: '0 4px',
          borderRadius: '10px',
          backgroundColor: 'rgba(248,250,252,0.94)',
          color: '#0f172a',
          fontSize: compact ? '6px' : '8px',
          fontWeight: 900,
          lineHeight: compact ? '15px' : '20px',
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
          left: compact ? '10px' : '12px',
          right: compact ? '10px' : '12px',
          top: compact ? '38px' : '52px',
          padding: compact ? '6px' : '8px',
          border: '1px solid rgba(248,250,252,0.85)',
          borderRadius: '4px',
          backgroundColor: 'rgba(5,7,11,0.96)',
          color: '#f8fafc',
          fontSize: compact ? '7px' : '9px',
          lineHeight: 1.25,
          zIndex: 5,
          boxShadow: '0 4px 12px rgba(0,0,0,0.75)',
          pointerEvents: 'none',
        }}
      >
        <div style={{ color: rarityColor[card.rarity], fontWeight: 900, marginBottom: '4px' }}>
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
          color: unavailable ? '#64748b' : '#f8fafc',
          fontSize: compact ? '10px' : '15px',
          fontWeight: 700,
          zIndex: 1,
        }}
      >
        {card.power}
      </div>
      <div
        style={{
          marginLeft: compact ? '-4px' : '-5px',
          padding: compact ? '3px 4px 3px 7px' : '4px 5px 4px 9px',
          border: `1px solid ${rarityColor[card.rarity]}`,
          backgroundColor: unavailable ? 'rgba(5,7,11,0.98)' : 'rgba(5,7,11,0.92)',
          color: unavailable ? '#64748b' : '#f8fafc',
          fontSize: compact ? '7px' : '10px',
          fontWeight: 700,
          lineHeight: 1.1,
          whiteSpace: 'nowrap',
          overflow: 'hidden',
          textOverflow: 'ellipsis',
        }}
      >
        {card.known ? card.name : 'Unknown'}
      </div>
    </div>

    {!!count && (
      <div
        style={{
          position: 'absolute',
          right: '5px',
          top: '22px',
          minWidth: '20px',
          height: '20px',
          borderRadius: '10px',
          backgroundColor: '#05070b',
          border: `1px solid ${rarityColor[card.rarity]}`,
          color: '#f8fafc',
          fontSize: '11px',
          fontWeight: 700,
          textAlign: 'center',
          lineHeight: '18px',
          zIndex: 2,
        }}
      >
        x{count}
      </div>
    )}
    </div>
  );
};

export const CardDeckBuilder = () => {
  const { act, data } = useBackend<Data>();
  const [query, setQuery] = useState('');
  const [row, setRow] = useState<CardRow | 'all'>('all');

  const cards = data.cards || [];
  const selected = data.selected || [];
  const selectedCounts = useMemo(() => {
    const counts: Record<string, number> = {};
    for (const id of selected) {
      counts[id] = (counts[id] || 0) + 1;
    }
    return counts;
  }, [selected]);

  const filteredCards = cards.filter((card) => {
    if (row !== 'all' && card.row !== row) {
      return false;
    }
    const needle = query.toLowerCase();
    return (
      !needle ||
      card.name.toLowerCase().includes(needle) ||
      card.desc.toLowerCase().includes(needle) ||
      card.effect.toLowerCase().includes(needle) ||
      card.combo.toLowerCase().includes(needle)
    );
  });

  const selectedCards = selected
    .map((id) => cards.find((card) => card.id === id))
    .filter(Boolean) as Card[];

  const deckRatio = data.deckSize > 0 ? data.selectedCount / data.deckSize : 0;
  const isPool = data.mode === 'pool';

  return (
    <Window title={isPool ? 'Card Deck Pool' : 'Card Deck Builder'} width={980} height={720}>
      <Window.Content>
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: isPool ? '1fr' : '1fr 330px',
            gap: '12px',
            height: '100%',
          }}
        >
          <Section title={isPool ? 'Pool' : 'Collection'} fill scrollable>
            <div style={{ display: 'flex', gap: '8px', marginBottom: '10px' }}>
              <Input
                value={query}
                onChange={setQuery}
                placeholder="Search cards"
                width="260px"
              />
              {(['all', 'infantry', 'archers', 'siege', 'weather'] as const).map(
                (key) => (
                  <Button
                    key={key}
                    selected={row === key}
                    onClick={() => setRow(key)}
                  >
                    {key === 'all' ? 'All' : rowLabels[key]}
                  </Button>
                ),
              )}
            </div>
            {isPool && (
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '10px',
                  marginBottom: '10px',
                  color: '#94a3b8',
                  fontSize: '12px',
                }}
              >
                <span>Rare and unique cards in pool: {data.knownRareCount}</span>
                <Button disabled={!data.canRequestDeck} onClick={() => act('request_deck')}>
                  Request Deck
                </Button>
              </div>
            )}

            <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
              {filteredCards.map((card) => {
                const selectedCount = selectedCounts[card.id] || 0;
                const ownedCount =
                  card.rarity === 'base' ? data.deckSize : card.ownedCount || 0;
                const unavailable = !card.known;
                return (
                  <CardFace
                    key={card.id}
                    card={card}
                    count={isPool && card.rarity !== 'base' ? ownedCount : selectedCount}
                    unavailable={unavailable}
                    disabled={
                      isPool
                        ? unavailable
                        : !card.known ||
                          data.selectedCount >= data.deckSize ||
                          selectedCount >= ownedCount
                    }
                    onClick={!isPool ? () => act('add', { card: card.id }) : undefined}
                    onRightClick={
                      !isPool && selectedCount > 0
                        ? () => act('take_card', { card: card.id })
                        : undefined
                    }
                  />
                );
              })}
            </div>
          </Section>

          {!isPool && (
          <Section title="Deck" fill scrollable>
            <div style={{ marginBottom: '8px' }}>
              {data.selectedCount} / {data.deckSize}
            </div>
            <ProgressBar
              value={deckRatio}
              ranges={{
                good: [0, 1],
              }}
              mb="10px"
            />
            <div style={{ color: '#94a3b8', fontSize: '12px', marginBottom: '10px' }}>
              Rare and unique cards in pool: {data.knownRareCount}
            </div>
            <div style={{ display: 'flex', gap: '6px', marginBottom: '10px' }}>
              <Button color="bad" onClick={() => act('clear')}>
                Clear
              </Button>
            </div>

            {!selectedCards.length && (
              <div style={{ color: '#94a3b8' }}>No cards selected.</div>
            )}

            <div
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(3, 88px)',
                gap: '10px',
              }}
            >
              {selectedCards.map((card, index) => (
                <CardFace
                  key={`${card.id}-${index}`}
                  card={card}
                  compact
                  onClick={() => act('remove_one', { card: card.id })}
                  onRightClick={() => act('take_card', { card: card.id })}
                />
              ))}
            </div>
          </Section>
          )}
        </div>
      </Window.Content>
    </Window>
  );
};
