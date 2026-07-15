import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Input,
  NumberInput,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Track = {
  title: string;
  selected: boolean;
  duration_seconds: number;
  duration_label: string;
  phrase_count: number;
  custom: boolean;
  analyzed_duration: boolean;
};

type Phrase = {
  time: number;
  text: string;
};

type SelectedTrack = {
  title: string;
  custom: boolean;
  duration_seconds: number;
  duration_label: string;
  analyzed_duration: boolean;
  spacing_seconds: number;
  lyrics: string;
  json: string;
  phrases: Phrase[];
};

type Data = {
  tracks: Track[];
  selected?: SelectedTrack | null;
  is_expert: boolean;
  playing: boolean;
  repeat_enabled: boolean;
  auto_singing_title?: string | null;
};

export const BardMusicLibrary = () => {
  const { data, act } = useBackend<Data>();
  const {
    tracks = [],
    selected,
    is_expert,
    playing,
    repeat_enabled,
    auto_singing_title,
  } = data;
  const [lyricsDraft, setLyricsDraft] = useState('');
  const [jsonDraft, setJsonDraft] = useState('');
  const [showPrepared, setShowPrepared] = useState(true);
  const [activeTab, setActiveTab] = useState<'text' | 'timing'>('timing');
  const [spacingDraft, setSpacingDraft] = useState(2);
  const preparedTracks = tracks.filter((track) => !track.custom);
  const customTracks = tracks.filter((track) => track.custom);
  const canEditSelected = !!selected?.custom;

  const updateLyrics = (value: string) => {
    setLyricsDraft(value);
    if (canEditSelected) {
      act('set_lyrics', {
        lyrics: value,
        spacing: spacingDraft,
      });
    }
  };

  useEffect(() => {
    setLyricsDraft(selected?.lyrics || '');
    setJsonDraft(selected?.json || '');
    setSpacingDraft(selected?.spacing_seconds || 2);
  }, [selected?.title]);

  return (
    <Window width={980} height={650} title="Music">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack align="center">
                <Stack.Item grow basis={0}>
                  <Box bold fontSize={1.25}>
                    {selected?.title || 'No track selected'}
                  </Box>
                  {!!selected && (
                    <Box color="label">
                      {selected.duration_seconds}s ({selected.duration_label}),{' '}
                      {selected.phrases.length} records
                      {selected.analyzed_duration ? '' : ' - fallback length'}
                    </Box>
                  )}
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="repeat"
                    selected={repeat_enabled}
                    onClick={() => act('toggle_repeat')}
                  >
                    Repeat
                  </Button>
                  <Button
                    icon={playing ? 'stop' : 'play'}
                    disabled={!selected}
                    onClick={() => act('play')}
                  >
                    {playing ? 'Stop' : 'Play'}
                  </Button>
                  <Button
                    icon="save"
                    disabled={!canEditSelected}
                    onClick={() =>
                      act('set_lyrics', {
                        lyrics: lyricsDraft,
                        spacing: spacingDraft,
                      })
                    }
                  >
                    Build records
                  </Button>
                  <Button
                    icon="trash"
                    color="red"
                    disabled={!canEditSelected}
                    onClick={() => act('clear_lyrics')}
                  >
                    Clear
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section
              title={`Prepared (${preparedTracks.length})`}
              buttons={
                <Button
                  compact
                  icon={showPrepared ? 'chevron-up' : 'chevron-down'}
                  onClick={() => setShowPrepared(!showPrepared)}
                >
                  {showPrepared ? 'Hide' : 'Show'}
                </Button>
              }
            >
              {showPrepared && (
                <Box
                  style={{
                    display: 'grid',
                    gap: '4px',
                    gridTemplateColumns: 'repeat(4, minmax(0, 1fr))',
                  }}
                >
                  {preparedTracks.map((track) => (
                    <Button
                      key={track.title}
                      fluid
                      compact
                      selected={track.selected}
                      onClick={() =>
                        act('select', {
                          title: track.title,
                        })
                      }
                    >
                      {track.title}
                    </Button>
                  ))}
                </Box>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item grow basis={0}>
            <Stack fill>
              <Stack.Item width="280px">
                <Section
                  fill
                  scrollable
                  title="Custom"
                  buttons={
                    is_expert && (
                      <Button
                        compact
                        icon="plus"
                        onClick={() =>
                          act('upload', {
                            lyrics: lyricsDraft,
                            spacing: spacingDraft,
                          })
                        }
                      >
                        Add song/track
                      </Button>
                    )
                  }
                >
                  <Stack vertical>
                    {customTracks.map((track) => (
                      <Stack.Item key={track.title}>
                        <Stack align="center">
                          <Stack.Item grow basis={0}>
                            <Button
                              fluid
                              compact
                              selected={track.selected}
                              onClick={() =>
                                act('select', {
                                  title: track.title,
                                })
                              }
                            >
                              {track.title}
                            </Button>
                          </Stack.Item>
                          <Stack.Item width="52px">
                            <Button
                              compact
                              onClick={() =>
                                act('sing_track', {
                                  title: track.title,
                                })
                              }
                            >
                              {auto_singing_title === track.title ? 'Sing' : 'Mute'}
                            </Button>
                          </Stack.Item>
                          <Stack.Item width="104px">
                            <Box color="label" textAlign="right">
                              {track.duration_seconds}s ({track.duration_label}),{' '}
                              {track.phrase_count}
                            </Box>
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    ))}
                    {!customTracks.length && (
                      <Stack.Item>
                        <Box color="label">No custom tracks.</Box>
                      </Stack.Item>
                    )}
                  </Stack>
                </Section>
              </Stack.Item>

              <Stack.Item grow basis={0}>
                <Stack vertical fill>
                  <Stack.Item>
                    <Section>
                      <Stack>
                        <Stack.Item grow basis={0}>
                          <Button
                            fluid
                            selected={activeTab === 'text'}
                            onClick={() => setActiveTab('text')}
                          >
                            Text
                          </Button>
                        </Stack.Item>
                        <Stack.Item grow basis={0}>
                          <Button
                            fluid
                            selected={activeTab === 'timing'}
                            onClick={() => setActiveTab('timing')}
                          >
                            Timing
                          </Button>
                        </Stack.Item>
                        <Stack.Item width="170px">
                          <Stack align="center">
                            <Stack.Item>
                              <Box color="label">Delay</Box>
                            </Stack.Item>
                            <Stack.Item>
                              <NumberInput
                                value={spacingDraft}
                                minValue={0.1}
                                maxValue={120}
                                step={0.5}
                                stepPixelSize={4}
                                width="64px"
                                onChange={(value: number) => setSpacingDraft(value)}
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                compact
                                disabled={!canEditSelected}
                                onClick={() =>
                                  act('set_spacing', {
                                    spacing: spacingDraft,
                                  })
                                }
                              >
                                Set
                              </Button>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                      </Stack>
                    </Section>
                  </Stack.Item>

                  <Stack.Item grow basis={0}>
                    {!canEditSelected ? (
                      <Section fill>
                        <Box color="label" textAlign="center" mt={4}>
                          Недоступно для предзаготовленных
                        </Box>
                      </Section>
                    ) : activeTab === 'text' ? (
                      <Section fill title="Input text">
                        <TextArea
                          height="100%"
                          fluid
                          value={lyricsDraft}
                          placeholder="Paste lyrics here. Tags like [Verse] will be stripped."
                          onChange={updateLyrics}
                          dontUseTabForIndent
                        />
                      </Section>
                    ) : (
                      <Section fill scrollable title="Timing">
                        {selected?.phrases?.length ? (
                          <Stack vertical>
                            {selected.phrases.map((phrase, index) => (
                              <Stack.Item key={`${phrase.time}-${index}`}>
                                <Stack align="center">
                                  <Stack.Item width="82px">
                                    <NumberInput
                                      value={phrase.time}
                                      minValue={0}
                                      maxValue={9999}
                                      step={0.5}
                                      stepPixelSize={4}
                                      width="78px"
                                      onChange={(value: number) =>
                                        act('set_phrase_time', {
                                          index: index + 1,
                                          time: value,
                                        })
                                      }
                                    />
                                  </Stack.Item>
                                  <Stack.Item grow>
                                    <Input
                                      fluid
                                      value={phrase.text}
                                      onBlur={(value) =>
                                        act('set_phrase_text', {
                                          index: index + 1,
                                          text: value,
                                        })
                                      }
                                      onEnter={(value) =>
                                        act('set_phrase_text', {
                                          index: index + 1,
                                          text: value,
                                        })
                                      }
                                    />
                                  </Stack.Item>
                                </Stack>
                              </Stack.Item>
                            ))}
                          </Stack>
                        ) : (
                          <Box color="label">No phrase records yet.</Box>
                        )}
                      </Section>
                    )}
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item height="78px">
            <Section
              fill
              title="JSON"
              buttons={
                <>
                  <Button
                    icon="file-export"
                    disabled={!canEditSelected}
                    onClick={() => setJsonDraft(selected?.json || '')}
                  >
                    Export
                  </Button>
                  <Button
                    icon="file-import"
                    disabled={!canEditSelected}
                    onClick={() =>
                      act('import_json', {
                        json: jsonDraft,
                      })
                    }
                  >
                    Import
                  </Button>
                </>
              }
            >
              <TextArea
                height="32px"
                fluid
                value={jsonDraft}
                onChange={setJsonDraft}
                placeholder="Export prepares this string. Import applies the string to the selected track."
                dontUseTabForIndent
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
