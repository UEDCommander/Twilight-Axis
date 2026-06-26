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
  faction: string;
  factionName?: string;
  factionAllowed?: boolean;
  effect: string;
  combo: string;
  art?: string;
  ownedCount?: number;
  limited?: boolean;
  known: boolean;
  selected: boolean;
};

type CcgFaction = {
  id: string;
  name: string;
  desc: string;
  effect: string;
  defaultLeader: string;
};

type CcgLeader = {
  id: string;
  name: string;
  desc: string;
  faction: string;
  effect: string;
  targetRow?: CardRow;
};

type Data = {
  mode?: 'pool' | 'build';
  cards?: Card[];
  selected?: string[];
  selectedCount: number;
  deckSize: number;
  knownRareCount: number;
  canRequestDeck?: boolean;
  faction?: string;
  leader?: string;
  factions?: CcgFaction[];
  leaders?: CcgLeader[];
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

const rarityOrder: Record<CardRarity, number> = {
  base: 0,
  rare: 1,
  unique: 2,
};

const rowOrder: Record<CardRow, number> = {
  infantry: 0,
  archers: 1,
  siege: 2,
  weather: 3,
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

const rowIconAssets: Record<CardRow, string> = {
  infantry: 'ccg_cards/gwent_icons/melee.webp',
  archers: 'ccg_cards/gwent_icons/ranged.webp',
  siege: 'ccg_cards/gwent_icons/siege.webp',
  weather: 'ccg_cards/gwent_icons/weather.webp',
};

const effectIconAssets: Record<string, string> = {
  morale: 'ccg_cards/gwent_icons/add_power.webp',
  scorch: 'ccg_cards/gwent_icons/kill_any_powerful_include_itself.webp',
  scorch_infantry: 'ccg_cards/gwent_icons/kill_any_if_10.webp',
  scorch_global: 'ccg_cards/gwent_icons/scorch_special.webp',
  spy: 'ccg_cards/gwent_icons/spy.webp',
  medic: 'ccg_cards/gwent_icons/medic.webp',
  bond: 'ccg_cards/gwent_icons/double.webp',
  agile: 'ccg_cards/gwent_icons/any_type_card.webp',
  muster: 'ccg_cards/gwent_icons/double.webp',
  horn: 'ccg_cards/gwent_icons/horn.webp',
  decoy: 'ccg_cards/gwent_icons/maneken.webp',
  berserk: 'ccg_cards/gwent_icons/berserk_to_bear.webp',
  mardroeme: 'ccg_cards/gwent_icons/mardrem.webp',
  avenger: 'ccg_cards/gwent_icons/berserk_mushroom.webp',
  clear_weather: 'ccg_cards/gwent_icons/sun.webp',
  frost: 'ccg_cards/gwent_icons/winter.webp',
  fog: 'ccg_cards/gwent_icons/fog.webp',
  rain: 'ccg_cards/gwent_icons/rain.webp',
};

const effectDescriptions: Record<string, string> = {
  morale: 'Прилив сил: +1 к силе остальных отрядов в этом ряду.',
  scorch: 'Казнь: уничтожает сильнейшую карту противника.',
  scorch_infantry:
    'Казнь: уничтожает сильнейшую пехоту врага, если его пехота имеет 10+ силы.',
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
  avenger:
    'Призвание Мстителя: при уничтожении призывает сильную карту на своё место.',
  clear_weather: 'Ясная погода: снимает всю погоду.',
  frost: 'Мороз: снижает пехоту до 1.',
  fog: 'Туман: снижает лучников до 1.',
  rain: 'Дождь: снижает осаду до 1.',
};

const CardIconBadge = ({
  asset,
  label,
  compact,
  title,
}: {
  asset?: string;
  label?: string;
  compact: boolean;
  title: string;
}) => {
  const size = compact ? 17 : 23;
  return (
    <div
      title={title}
      style={{
        width: `${size}px`,
        height: `${size}px`,
        borderRadius: '50%',
        backgroundColor: 'rgba(5,7,11,0.82)',
        border: '1px solid rgba(248,250,252,0.72)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        overflow: 'hidden',
        boxShadow: '0 1px 4px rgba(0,0,0,0.65)',
      }}
    >
      {asset ? (
        <img
          src={resolveAsset(asset)}
          style={{
            width: compact ? '13px' : '18px',
            height: compact ? '13px' : '18px',
            objectFit: 'contain',
          }}
        />
      ) : (
        <span
          style={{
            color: '#f8fafc',
            fontSize: compact ? '5px' : '7px',
            fontWeight: 900,
            lineHeight: 1,
          }}
        >
          {label}
        </span>
      )}
    </div>
  );
};

const cardTooltip = (card: Card) => {
  if (!card.known) {
    return ['Unknown'];
  }
  const lines = [
    card.name,
    `Type: ${cardType(card)}`,
    `Group: ${card.factionName || card.faction}`,
    `Power: ${card.power}`,
  ];
  if (effectDescriptions[card.effect]) {
    lines.push(`Effect: ${effectDescriptions[card.effect]}`);
  } else if (card.desc) {
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
  const [tooltipPlacement, setTooltipPlacement] = useState<{
    side: 'left' | 'center' | 'right';
    vertical: 'above' | 'below';
  }>({ side: 'center', vertical: 'below' });
  const tooltip = cardTooltip(card);
  const tooltipWidth = compact ? 136 : 188;
  const tooltipGap = compact ? 8 : 10;
  const effectIcon = card.known ? effectIconAssets[card.effect] : undefined;
  const effectBadge = card.known ? effectBadges[card.effect] : undefined;
  const updateTooltipPlacement = (cardElement: HTMLElement) => {
    const rect = cardElement.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2;
    const tooltipHeight = compact
      ? Math.min(220, 48 + tooltip.length * 18)
      : Math.min(280, 58 + tooltip.length * 24);
    let side: 'left' | 'center' | 'right' = 'center';
    if (centerX - tooltipWidth / 2 < 12) {
      side = 'left';
    } else if (centerX + tooltipWidth / 2 > window.innerWidth - 12) {
      side = 'right';
    }
    setTooltipPlacement({
      side,
      vertical:
        rect.bottom + tooltipHeight + tooltipGap <= window.innerHeight
          ? 'below'
          : 'above',
    });
  };
  return (
    <div
      style={{
        position: 'relative',
        aspectRatio: '1 / 1.6',
        width: compact ? '88px' : '118px',
        padding: compact ? '4px' : '6px',
        border: `2px solid ${rarityColor[card.rarity]}`,
        borderRadius: '4px',
        background:
          'linear-gradient(180deg, rgba(35,39,48,0.98), rgba(14,16,22,0.98))',
        boxShadow: `0 0 0 1px rgba(0,0,0,0.7), 0 0 10px ${rarityColor[card.rarity]}33`,
        cursor: onClick && !disabled ? 'pointer' : 'default',
        opacity: disabled && !unavailable ? 0.62 : 1,
        transform: hovered ? 'scale(1.15)' : 'scale(1)',
        transformOrigin: 'center center',
        transition: 'transform 140ms ease, z-index 140ms ease',
        zIndex: hovered ? 50 : 1,
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'space-between',
        overflow: 'visible',
      }}
      onClick={!disabled ? onClick : undefined}
      onContextMenu={(event) => {
        if (!onRightClick) {
          return;
        }
        event.preventDefault();
        onRightClick();
      }}
      onMouseEnter={(event) => {
        updateTooltipPlacement(event.currentTarget);
        setHovered(true);
      }}
      onMouseMove={(event) => updateTooltipPlacement(event.currentTarget)}
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
            filter: unavailable
              ? 'grayscale(1) brightness(0.16) contrast(0.85)'
              : undefined,
            zIndex: 0,
          }}
        />
      )}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background: unavailable
            ? 'linear-gradient(180deg, rgba(0,0,0,0.84), rgba(0,0,0,0.78) 32%, rgba(0,0,0,0.94))'
            : 'linear-gradient(180deg, rgba(0,0,0,0.34), rgba(0,0,0,0.04) 32%, rgba(0,0,0,0.62))',
          zIndex: 0,
        }}
      />
      <div
        style={{
          position: 'relative',
          zIndex: 2,
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          width: '100%',
        }}
      >
        <CardIconBadge
          asset={rowIconAssets[card.row]}
          compact={compact}
          title={cardType(card)}
        />
        {(!!effectIcon || !!effectBadge) && (
          <CardIconBadge
            asset={effectIcon}
            label={effectBadge}
            compact={compact}
            title={effectDescriptions[card.effect] || card.effect}
          />
        )}
      </div>
      {!!count && (
        <div
          style={{
            position: 'absolute',
            left: '5px',
            top: compact ? '24px' : '34px',
            minWidth: compact ? '18px' : '20px',
            height: compact ? '16px' : '20px',
            borderRadius: '10px',
            backgroundColor: '#05070b',
            border: `1px solid ${rarityColor[card.rarity]}`,
            color: '#f8fafc',
            fontSize: compact ? '9px' : '11px',
            fontWeight: 700,
            textAlign: 'center',
            lineHeight: compact ? '14px' : '18px',
            zIndex: 2,
          }}
        >
          x{count}
        </div>
      )}
      {hovered && (
        <div
          style={{
            position: 'absolute',
            left:
              tooltipPlacement.side === 'right'
                ? undefined
                : tooltipPlacement.side === 'left'
                  ? 0
                  : '50%',
            right: tooltipPlacement.side === 'right' ? 0 : undefined,
            top:
              tooltipPlacement.vertical === 'below'
                ? `calc(100% + ${tooltipGap}px)`
                : undefined,
            bottom:
              tooltipPlacement.vertical === 'above'
                ? `calc(100% + ${tooltipGap}px)`
                : undefined,
            width: `${tooltipWidth}px`,
            maxWidth: '70vw',
            padding: compact ? '12px' : '16px',
            border: '2px solid rgba(248,250,252,0.85)',
            borderRadius: '6px',
            backgroundColor: 'rgba(5,7,11,0.96)',
            color: '#f8fafc',
            fontSize: compact ? '14px' : '18px',
            lineHeight: 1.25,
            zIndex: 1000,
            boxShadow: '0 8px 24px rgba(0,0,0,0.85)',
            pointerEvents: 'none',
            transform:
              tooltipPlacement.side === 'center'
                ? 'translateX(-50%)'
                : undefined,
            whiteSpace: 'normal',
            overflowWrap: 'break-word',
          }}
        >
          <div
            style={{
              color: rarityColor[card.rarity],
              fontWeight: 900,
              marginBottom: compact ? '8px' : '10px',
            }}
          >
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
            padding: compact ? '2px 4px 2px 7px' : '3px 5px 3px 9px',
            border: `1px solid ${rarityColor[card.rarity]}`,
            backgroundColor: unavailable
              ? 'rgba(5,7,11,0.98)'
              : 'rgba(5,7,11,0.92)',
            color: unavailable ? '#64748b' : '#f8fafc',
            fontWeight: 700,
            lineHeight: 1.1,
            overflow: 'hidden',
          }}
        >
          <div
            style={{
              fontSize: compact ? '7px' : '10px',
              whiteSpace: 'nowrap',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
            }}
          >
            {card.known ? card.name : 'Unknown'}
          </div>
          <div
            style={{
              color: rarityColor[card.rarity],
              fontSize: compact ? '5px' : '7px',
              fontWeight: 900,
              lineHeight: 1,
              textTransform: 'uppercase',
              whiteSpace: 'nowrap',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
            }}
          >
            {cardType(card)}
          </div>
        </div>
      </div>
    </div>
  );
};

export const CardDeckBuilder = () => {
  const { act, data } = useBackend<Data>();
  const [query, setQuery] = useState('');
  const [row, setRow] = useState<CardRow | 'all'>('all');
  const [factionFilter, setFactionFilter] = useState('all');

  const cards = data.cards || [];
  const selected = data.selected || [];
  const selectedCounts = useMemo(() => {
    const counts: Record<string, number> = {};
    for (const id of selected) {
      counts[id] = (counts[id] || 0) + 1;
    }
    return counts;
  }, [selected]);

  const factionOrder = useMemo(() => {
    const order: Record<string, number> = { neutral: 0 };
    (data.factions || []).forEach((faction, index) => {
      order[faction.id] = index + 1;
    });
    return order;
  }, [data.factions]);

  const filteredCards = cards
    .filter((card) => {
      if (row !== 'all' && card.row !== row) {
        return false;
      }
      let factionMatches = true;
      if (factionFilter === 'neutral') {
        factionMatches = card.faction === 'neutral';
      } else if (factionFilter !== 'all') {
        factionMatches = card.faction === factionFilter;
      }
      if (!factionMatches) {
        return false;
      }
      const terms = query.toLowerCase().trim().split(/\s+/).filter(Boolean);
      const haystack = (
        card.known
          ? [
              card.name,
              card.desc,
              card.effect,
              card.combo,
              card.faction,
              card.factionName || '',
              rowLabels[card.row],
            ]
          : ['Unknown']
      )
        .join(' ')
        .toLowerCase();
      return !terms.length || terms.every((term) => haystack.includes(term));
    })
    .sort((a, b) => {
      const factionDiff =
        (factionOrder[a.faction] ?? Number.MAX_SAFE_INTEGER) -
        (factionOrder[b.faction] ?? Number.MAX_SAFE_INTEGER);
      if (factionDiff) {
        return factionDiff;
      }
      const rarityDiff = rarityOrder[a.rarity] - rarityOrder[b.rarity];
      if (rarityDiff) {
        return rarityDiff;
      }
      const rowDiff = rowOrder[a.row] - rowOrder[b.row];
      if (rowDiff) {
        return rowDiff;
      }
      return a.name.localeCompare(b.name);
    });

  const selectedCards = selected
    .map((id) => cards.find((card) => card.id === id))
    .filter(Boolean) as Card[];

  const deckRatio = data.deckSize > 0 ? data.selectedCount / data.deckSize : 0;
  const isPool = data.mode === 'pool';
  const currentFaction = data.factions?.find(
    (faction) => faction.id === data.faction,
  );
  const currentLeader = data.leaders?.find(
    (leader) => leader.id === data.leader,
  );
  const factionLeaders = (data.leaders || []).filter(
    (leader) => leader.faction === data.faction,
  );

  return (
    <Window
      title={isPool ? 'Card Deck Pool' : 'Card Deck Builder'}
      width={980}
      height={720}
    >
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
              {(
                ['all', 'infantry', 'archers', 'siege', 'weather'] as const
              ).map((key) => (
                <Button
                  key={key}
                  selected={row === key}
                  onClick={() => setRow(key)}
                >
                  {key === 'all' ? 'All' : rowLabels[key]}
                </Button>
              ))}
            </div>
            <div
              style={{
                display: 'flex',
                gap: '8px',
                flexWrap: 'wrap',
                marginBottom: '10px',
              }}
            >
              {(
                [
                  ['all', 'Any'],
                  ['neutral', 'Common'],
                ] as const
              ).map(([key, label]) => (
                <Button
                  key={key}
                  selected={factionFilter === key}
                  onClick={() => setFactionFilter(key)}
                >
                  {label}
                </Button>
              ))}
              {(data.factions || []).map((faction) => (
                <Button
                  key={faction.id}
                  selected={factionFilter === faction.id}
                  onClick={() => setFactionFilter(faction.id)}
                >
                  {faction.name}
                </Button>
              ))}
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
                <span>
                  Limited cards in pool: {data.knownRareCount}
                </span>
                <Button
                  disabled={!data.canRequestDeck}
                  onClick={() => act('request_deck')}
                >
                  Request Deck
                </Button>
              </div>
            )}

            <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
              {filteredCards.map((card) => {
                const selectedCount = selectedCounts[card.id] || 0;
                const ownedCount =
                  card.rarity === 'base' && !card.limited
                    ? data.deckSize
                    : card.ownedCount || 0;
                const factionLocked = !isPool && !card.factionAllowed;
                const unavailable = !card.known || factionLocked;
                return (
                  <CardFace
                    key={card.id}
                    card={card}
                    count={
                      isPool && (card.rarity !== 'base' || card.limited)
                        ? ownedCount
                        : selectedCount
                    }
                    unavailable={unavailable}
                    disabled={
                      isPool
                        ? unavailable
                        : !card.known ||
                          data.selectedCount >= data.deckSize ||
                          selectedCount >= ownedCount ||
                          factionLocked
                    }
                    onClick={
                      !isPool ? () => act('add', { card: card.id }) : undefined
                    }
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
              <div
                style={{
                  marginBottom: '10px',
                  padding: '8px',
                  border: '1px solid rgba(148,163,184,0.28)',
                  backgroundColor: 'rgba(5,7,11,0.35)',
                }}
              >
                <div
                  style={{
                    color: '#cbd5e1',
                    fontSize: '12px',
                    fontWeight: 800,
                    marginBottom: '6px',
                  }}
                >
                  Faction
                </div>
                <div
                  style={{
                    display: 'flex',
                    gap: '6px',
                    flexWrap: 'wrap',
                    marginBottom: '8px',
                  }}
                >
                  {(data.factions || []).map((faction) => (
                    <Button
                      key={faction.id}
                      selected={faction.id === data.faction}
                      onClick={() =>
                        act('set_faction', { faction: faction.id })
                      }
                    >
                      {faction.name}
                    </Button>
                  ))}
                </div>
                {currentFaction && (
                  <div
                    style={{
                      color: '#94a3b8',
                      fontSize: '11px',
                      marginBottom: '8px',
                    }}
                  >
                    {currentFaction.desc}
                  </div>
                )}
                <div
                  style={{
                    color: '#cbd5e1',
                    fontSize: '12px',
                    fontWeight: 800,
                    marginBottom: '6px',
                  }}
                >
                  Leader
                </div>
                <div
                  style={{
                    display: 'flex',
                    gap: '6px',
                    flexWrap: 'wrap',
                    marginBottom: '8px',
                  }}
                >
                  {factionLeaders.map((leader) => (
                    <Button
                      key={leader.id}
                      selected={leader.id === data.leader}
                      onClick={() => act('set_leader', { leader: leader.id })}
                    >
                      {leader.name}
                    </Button>
                  ))}
                </div>
                {currentLeader && (
                  <div style={{ color: '#94a3b8', fontSize: '11px' }}>
                    {currentLeader.desc}
                  </div>
                )}
              </div>
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
              <div
                style={{
                  color: '#94a3b8',
                  fontSize: '12px',
                  marginBottom: '10px',
                }}
              >
                Limited cards in pool: {data.knownRareCount}
              </div>
              <div
                style={{ display: 'flex', gap: '6px', marginBottom: '10px' }}
              >
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
