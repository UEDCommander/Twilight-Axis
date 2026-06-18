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
  known: boolean;
  selected: boolean;
};

type Data = {
  cards?: Card[];
  selected?: string[];
  selectedCount: number;
  deckSize: number;
  knownRareCount: number;
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

const CardFace = ({
  card,
  disabled = false,
  compact = false,
  count = 0,
  onClick,
}: {
  card: Card;
  disabled?: boolean;
  compact?: boolean;
  count?: number;
  onClick?: () => void;
}) => (
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
      opacity: disabled ? 0.42 : 1,
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'space-between',
      overflow: 'hidden',
    }}
    onClick={!disabled ? onClick : undefined}
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
        width: '100%',
        whiteSpace: 'nowrap',
        overflow: 'hidden',
        textOverflow: 'ellipsis',
      }}
    >
      {cardType(card)}
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
        {card.power}
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

  return (
    <Window title="Card Deck Builder" width={980} height={720}>
      <Window.Content>
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: '1fr 330px',
            gap: '12px',
            height: '100%',
          }}
        >
          <Section title="Collection" fill scrollable>
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

            <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
              {filteredCards.map((card) => (
                <CardFace
                  key={card.id}
                  card={card}
                  count={selectedCounts[card.id] || 0}
                  disabled={!card.known || data.selectedCount >= data.deckSize}
                  onClick={() => act('add', { card: card.id })}
                />
              ))}
            </div>
          </Section>

          <Section title="Deck" fill scrollable>
            <div style={{ marginBottom: '8px' }}>
              {data.selectedCount} / {data.deckSize}
            </div>
            <ProgressBar
              value={deckRatio}
              ranges={{
                good: [1, 1],
                average: [0.5, 0.99],
                bad: [0, 0.49],
              }}
              mb="10px"
            />
            <div style={{ color: '#94a3b8', fontSize: '12px', marginBottom: '10px' }}>
              Known rare cards: {data.knownRareCount}
            </div>
            <div style={{ display: 'flex', gap: '6px', marginBottom: '10px' }}>
              <Button onClick={() => act('create_deck')}>
                Create Deck
              </Button>
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
                />
              ))}
            </div>
          </Section>
        </div>
      </Window.Content>
    </Window>
  );
};
