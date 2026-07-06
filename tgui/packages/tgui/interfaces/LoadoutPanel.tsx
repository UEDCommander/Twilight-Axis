import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { classes } from 'tgui-core/react';
import { Window } from 'tgui/layouts';
import {
  DmIcon,
  Button,
  Icon,
  Box,
  ProgressBar,
  Stack,
  Tabs,
  Input,
} from 'tgui-core/components';

interface Data {
  categories: Record<string, Record<string, Item>>;
  isDonator: boolean | number;
  selectedLoadoutItems: string[];
  donatTier: number;
  triumphDiscount: number;
  triumphDiscountUsed: number;
  curLoadoutSlots: number;
  maxLoadoutSlots: number;
}

interface Item {
  name: string;
  path: string;
  icon_class_name: string;
  isDonatorItem: boolean;
  icon: string;
  icon_state: string;
  unavailable?: boolean;
  unavailableReason?: string;
  requiredTier?: number;
  triumphCost?: number;
}

export const LoadoutPanel = () => {
  const { data, act } = useBackend<Data>();
  const [tabIndex, setTabIndex] = useState(0);
  const [searchQuery, setSearchQuery] = useState('');
  const [confirmReset, setConfirmReset] = useState(false);

  const selectedSet = new Set(data.selectedLoadoutItems ?? []);

  const categoriesArray = Object.entries(data.categories ?? {}).map(
    ([name, items]) => ({
      name,
      items,
    })
  );

  const filteredItems = Object.values(categoriesArray[tabIndex]?.items || {}).filter(
    (item) => (item?.name?.toLowerCase() || '').includes(searchQuery.toLowerCase())
  );

  const handleResetClick = () => {
    if (confirmReset) {
      act('clear', {});
      setTimeout(() => setConfirmReset(false), 100);
    } else {
      setConfirmReset(true);
      setTimeout(() => setConfirmReset(false), 5000);
    }
  };

  const slotRatio =
    data.maxLoadoutSlots > 0
      ? data.curLoadoutSlots / data.maxLoadoutSlots
      : 0;

  const hasDonatorTriumphDiscount =
    !!data.isDonator && data.triumphDiscount > 0;

  return (
    <Window title="Лодаут" width={1000} height={700}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="300px">
            <Stack vertical textAlign="justify">
              <Stack.Item>
                <h2>Выберите предметы для вашего персонажа.</h2>
              </Stack.Item>
              <Stack.Item>
                <h2>
                  Вы их сможете забрать, когда нажмете правой кнопкой мыши по статуе
                  или дереву.
                </h2>
              </Stack.Item>
              <Stack.Item>
                <h4>
                  Рескины на оружие (Donator kit) являются просто рескинами, чтобы
                  его получить используйте зелье на соответствующем предмете.
                </h4>
              </Stack.Item>
              <Stack.Item>
                <Button onClick={() => act('boosty')}>
                  <h3>Поддержать сервер</h3>
                </Button>
              </Stack.Item>
              <br />
              <Stack.Item>
                {data.curLoadoutSlots} / {data.maxLoadoutSlots}
              </Stack.Item>
              <Stack.Item>
                <ProgressBar
                  ranges={{
                    bad: [0.75, Infinity],
                    average: [0.25, 0.75],
                    good: [-Infinity, 0.25],
                  }}
                  value={slotRatio}
                  width="300px"
                />
              </Stack.Item>

              {hasDonatorTriumphDiscount ? (
                <Stack.Item>
                  <Box
                    style={{
                      display: 'inline-block',
                      padding: '8px 14px',
                      borderRadius: '8px',
                      backgroundColor: 'rgba(212, 175, 55, 0.14)',
                      border: '1px solid rgba(212, 175, 55, 0.55)',
                      color: '#facc15',
                      fontWeight: 'bold',
                      textShadow: '1px 1px 3px rgba(0,0,0,0.75)',
                    }}
                  >
                    ★ Скидочные триумфы: занято {data.triumphDiscountUsed} из{' '}
                    {data.triumphDiscount}
                  </Box>
                </Stack.Item>
              ) : null}
              <Stack.Item>
                <Box
                  mt={2}
                  style={{
                    minHeight: '180px',
                    maxHeight: '200px',
                    overflowY: 'auto',
                    overflowX: 'hidden',
                    padding: '8px',
                    border: '1px solid rgba(120, 150, 190, 0.65)',
                    borderRadius: '6px',
                    backgroundColor: 'rgba(0, 0, 0, 0.14)',
                  }}
                >
                  <Box
                    mb={1}
                    textAlign="center"
                    style={{
                      fontSize: '16px',
                      fontWeight: 'bold',
                      textShadow: '1px 1px 3px rgba(0,0,0,0.8)',
                    }}
                  >
                    Выбранные предметы:
                  </Box>

                  {(data.selectedLoadoutItems ?? []).length ? (
                    (data.selectedLoadoutItems ?? []).map((item) => (
                      <Box
                        key={item}
                        mb={1}
                        style={{
                          display: 'flex',
                          justifyContent: 'space-between',
                          alignItems: 'center',
                          gap: '6px',
                        }}
                      >
                        <Box
                          style={{
                            overflow: 'hidden',
                            textOverflow: 'ellipsis',
                            whiteSpace: 'nowrap',
                          }}
                          tooltip={item}
                        >
                          {item}
                        </Box>
                        <Button
                          color="danger"
                          onClick={() => act('remove', { item })}
                        >
                          Удалить
                        </Button>
                      </Box>
                    ))
                  ) : (
                    <Box color="label" textAlign="center">
                      Пока ничего не выбрано.
                    </Box>
                  )}
                </Box>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item width="100%">
            <Stack vertical fill>
              <Stack.Item>
                <Tabs>
                  {categoriesArray.map((cat, i) => (
                    <Tabs.Tab
                      key={cat.name}
                      selected={i === tabIndex}
                      onClick={() => setTabIndex(i)}
                      style={{
                        flex: 1,
                        backgroundColor: i === tabIndex ? '#444' : '#222',
                        color: 'white',
                      }}
                    >
                      {cat.name}
                    </Tabs.Tab>
                  ))}
                </Tabs>
              </Stack.Item>
              <Stack.Item
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginTop: '10px',
                }}
              >
                <Input
                  placeholder="Поиск предметов..."
                  value={searchQuery}
                  onChange={setSearchQuery}
                  width="300px"
                />
                <Button
                  onClick={handleResetClick}
                  style={{ marginTop: '10px' }}
                  color={confirmReset ? 'good' : 'danger'}
                >
                  <span style={{ color: 'white' }}>
                    {confirmReset ? 'Точно?' : 'Сбросить все'}
                  </span>
                </Button>
              </Stack.Item>
              <Stack.Item
                style={{
                  overflowY: 'auto',
                  overflowX: 'hidden',
                }}
              >
                <div
                  style={{
                    display: 'grid',
                    gridTemplateColumns: 'repeat(auto-fill, minmax(96px, 1fr))',
                    gap: '8px',
                  }}
                >
                  {filteredItems.map((item, index) => (
                    <div
                      key={item?.name || item?.path || index}
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        minHeight: '64px',
                        borderRadius: '4px',
                      }}
                    >
                      <Box
                        style={{
                          display: 'flex',
                          flexDirection: 'column',
                          alignItems: 'center',
                          justifyContent: 'center',
                          minWidth: '96px',
                          flexShrink: 0,
                        }}
                      >
                        <Button
                          style={{
                            backgroundColor: '#141414',
                            padding: '16px',
                            width: '96px',
                            height: '96px',
                            border: '2x solid red',
                            borderColor: `${item?.unavailable ? '#a77a18' : (selectedSet.has(item?.name)? '#a71818' : '#24a718')}`,
                            borderRadius: '8px',
                          }}
                          tooltip={
                            `${item?.unavailable
                              ? item?.unavailableReason || (item?.requiredTier ? "Недоступно. Требуется уровень:"+item.requiredTier : 'Недоступно.')
                              : item?.name || 'Без названия'}`}
                          onClick={() => {
                            if (selectedSet.has(item?.name)) {
                              act('remove', { item: item?.name || item?.path });
                            } else {
                              act('add', { item: item?.name || item?.path });
                            }
                          }}
                        >
                          <Box
                            inline
                            verticalAlign="middle"
                            className={item.icon_class_name}
                            style={{
                              transform: 'scale(0.67) translate(-51px, -50px)',
                            }}
                          >
                            {item?.triumphCost ? (
                              <Box
                                style={{
                                  width: '100%',
                                  marginTop: '96px',
                                  fontSize: '20px',
                                  fontWeight: 'bold',
                                  color: '#d4af37',
                                  outlineColor: 'black',
                                  textAlign: 'center',
                                  textShadow: '1px 1px 3px rgba(0,0,0,0.75)',
                                  lineHeight: 1.2,
                                }}
                              >
                                {item.triumphCost} триумфов
                              </Box>
                            ) : null}

                            {item?.isDonatorItem ? (
                              <Box
                                style={{
                                  width: '100%',
                                  marginTop: '96px',
                                  fontSize: '20px',
                                  fontWeight: 'bold',
                                  color: '#c084fc',
                                  outlineColor: 'black',
                                  textAlign: 'center',
                                  textShadow: '1px 1px 3px rgba(0,0,0,0.75)',
                                  lineHeight: 1.2,
                                }}
                              >
                                Донат тир {item.requiredTier && item.requiredTier > 0 ? item.requiredTier : 1}
                              </Box>
                            ) : null}
                          </Box>
                        </Button>
                      </Box>
                    </div>
                  ))}
                </div>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
