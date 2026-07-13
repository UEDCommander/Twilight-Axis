import { useState } from 'react';
import { Button, Section, Stack, NoticeBox, Box } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type PaintingMeta = {
  id: string;
  title: string;
  author: string;
};

type Data = {
  is_admin: boolean;
  paintings: PaintingMeta[];
};

export const ArtGallery = (props) => {
  const { act, data } = useBackend<Data>();
  const [loadedImages, setLoadedImages] = useState<Record<string, string>>({});
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const requestImage = (id: string) => {
    setSelectedId(id);
    act('get_image', { id });
  };

  const handleDelete = (id: string) => {
    act('delete_painting', { id });
    setSelectedId(null);
  };

  const customMessage = useBackend<any>().data?.image_data;
  if (customMessage && customMessage.id && customMessage.base64 && !loadedImages[customMessage.id]) {
    setLoadedImages(prev => ({ ...prev, [customMessage.id]: customMessage.base64 }));
  }

  return (
    <Window width={600} height={500} title="Server Art Gallery">
      <Window.Content>
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

                  <Stack.Item mt={2}>
                    <Box bold fontSize={2}>{data.paintings.find(p => p.id === selectedId)?.title}</Box>
                    <Box italic>Автор: {data.paintings.find(p => p.id === selectedId)?.author}</Box>
                  </Stack.Item>

                  {data.is_admin && (
                    <Stack.Item mt={5}>
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
      </Window.Content>
    </Window>
  );
};
