export type Phase = 'ready' | 'playing' | 'paused' | 'won' | 'lost';
export interface Run { phase: Phase; x: number; y: number; turn: number; limit: number; rescued: string[]; shield: number; dash: number; hits: number; message: string; level?: number; key?: boolean; }
export interface GameSave { run: Run; best: number; played: number; wins: number; language?: 'ary'|'en'|'fr'|'es'; }
