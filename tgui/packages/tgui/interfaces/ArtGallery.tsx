import { useState, useEffect } from 'react';
import { Button, Section, Stack, NoticeBox, Box, Tabs } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type PaintingMeta = {
  id: string;
  title: string;
  author: string;
  author_ckey?: string;
  ic_date?: string;
};

type Data = {
  is_admin: boolean;
  paintings: PaintingMeta[];
  deletion_logs?: string[];
};

export const ArtGallery = (props) => {
  const { act, data } = useBackend<Data>();
  const [loadedImages, setLoadedImages] = useState<Record<string, string>>({});
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<'gallery' | 'logs'>('gallery');

  const customMessage = useBackend<any>().data?.image_data;

  useEffect(() => {
    if (customMessage && customMessage.id && customMessage.base64) {
      if (!loadedImages[customMessage.id]) {
        setLoadedImages(prev => ({
          ...prev,
          [customMessage.id]: customMessage.base64
        }));
      }
    }
  }, [customMessage, loadedImages]);

  const requestImage = (id: string) => {
    setSelectedId(id);
    act('get_image', { id });
  };

  const handleDelete = (id: string) => {
    act('delete_painting', { id });
    setSelectedId(null);
  };

  return (
    <Window width={600} height={520} title="Server Art Gallery">
      <Window.Content scrollable>
        <Stack vertical fill>
          {data.is_admin && (
            <Stack.Item>
              <Tabs>
                <Tabs.Tab selected={activeTab === 'gallery'} onClick={() => setActiveTab('gallery')}>
                  Галерея
                </Tabs.Tab>
                <Tabs.Tab selected={activeTab === 'logs'} onClick={() => setActiveTab('logs')}>
                  Логи удаления ({data.deletion_logs?.length || 0})
                </Tabs.Tab>
              </Tabs>
            </Stack.Item>
          )}

          {activeTab === 'gallery' && (
            <Stack.Item grow>
              <Stack fill>
                <Stack.Item width="200px">
                  <Section title="Архив" fill scrollable>
                    {data.paintings?.length === 0 && <NoticeBox>Галерея пуста.</NoticeBox>}
                    <Stack vertical>
                      {data.paintings?.map(p => (
                        <Stack.Item key={p.id}>
                          <Button 
                            fluid 
                            selected={selectedId === p.id} 
                            onClick={() => requestImage(p.id)}
                          >
                            {p.title} <br/>
                            <span style={{ fontSize: '10px', opacity: 0.7 }}>от {p.author}</span>
                          </Button>
                        </Stack.Item>
                      ))}
                    </Stack>
                  </Section>
                </Stack.Item>

                <Stack.Item grow>
                  <Section title="Просмотр" fill>
                    {selectedId ? (
                      <Stack vertical align="center">
                        <Stack.Item>
                          {loadedImages[selectedId] ? (
                            <div style={{
                              width: '256px', 
                              height: '256px', 
                              backgroundColor: '#f5e8d3',
                              border: '2px solid #333',
                              backgroundImage: `url(data:image/png;base64,${loadedImages[selectedId]})`,
                              backgroundSize: '100%',
                              imageRendering: 'pixelated'
                            }} />
                          ) : (
                            <Box>Загрузка холста из архива...</Box>
                          )}
                        </Stack.Item>

                        <Stack.Item mt={2} textAlign="center">
                          <Box bold fontSize={2}>{data.paintings.find(p => p.id === selectedId)?.title}</Box>
                          <Box italic>Автор: {data.paintings.find(p => p.id === selectedId)?.author}</Box>
                          <Box color="#f4cf5c" fontSize="11px" mt={0.5}>
                            Дата создания: {data.paintings.find(p => p.id === selectedId)?.ic_date || 'До Эпохи Нового Порядка'}
                          </Box>
                          {data.is_admin && (
                            <Box color="label" fontSize="11px" mt={0.5}>
                              Ckey автора: {data.paintings.find(p => p.id === selectedId)?.author_ckey || 'неизвестно'}
                            </Box>
                          )}
                        </Stack.Item>

                        {data.is_admin && (
                          <Stack.Item mt={3}>
                            <Button.Confirm color="bad" icon="trash" onClick={() => handleDelete(selectedId)}>
                              Удалить из базы сервера
                            </Button.Confirm>
                          </Stack.Item>
                        )}
                      </Stack>
                    ) : (
                      <Box italic textAlign="center" mt={10}>
                        Выберите картину из списка слева.
                      </Box>
                    )}
                  </Section>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          )}

          {activeTab === 'logs' && data.is_admin && (
            <Stack.Item grow>
              <Section title="Логи модерации" fill scrollable>
                {data.deletion_logs?.length === 0 ? (
                  <NoticeBox>Логи пусты. Картины не удалялись.</NoticeBox>
                ) : (
                  <Stack vertical>
                    {data.deletion_logs?.map((log, index) => (
                      <Stack.Item key={index}>
                        <Box style={{ 
                          fontFamily: 'monospace', 
                          borderBottom: '1px solid rgba(255,255,255,0.1)', 
                          padding: '6px 0',
                          opacity: 0.9 
                        }}>
                          {log}
                        </Box>
                      </Stack.Item>
                    ))}
                  </Stack>
                )}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
