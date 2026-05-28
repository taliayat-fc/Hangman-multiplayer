-- Run this in your Supabase project: Dashboard → SQL Editor → New query

-- Rooms table: one row per active game
CREATE TABLE rooms (
  id           TEXT PRIMARY KEY,          -- e.g. 'AB3KP'
  theme        TEXT,
  word         TEXT,
  guessed      TEXT[]   DEFAULT '{}',
  wrong_count  INT      DEFAULT 0,
  status       TEXT     DEFAULT 'waiting', -- waiting | playing | won | lost
  winner_name  TEXT,
  host_name    TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- Players table: one row per player per game
CREATE TABLE players (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id    TEXT REFERENCES rooms(id) ON DELETE CASCADE,
  name       TEXT NOT NULL,
  is_host    BOOLEAN DEFAULT FALSE,
  joined_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Realtime for both tables (required for live sync)
ALTER PUBLICATION supabase_realtime ADD TABLE rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE players;

-- Disable RLS — this is a party game with no sensitive data.
-- Anyone with the room code can read/write, which is the intended behaviour.
ALTER TABLE rooms   DISABLE ROW LEVEL SECURITY;
ALTER TABLE players DISABLE ROW LEVEL SECURITY;

-- Optional: auto-clean rooms older than 24 hours
-- (run as a scheduled function or manually)
-- DELETE FROM rooms WHERE created_at < NOW() - INTERVAL '24 hours';
