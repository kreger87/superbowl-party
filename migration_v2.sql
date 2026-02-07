-- Super Bowl LX Party Prop Game - Multi-Party Migration
-- Run this in the Supabase SQL Editor AFTER migration.sql

-- 1. Create parties table
CREATE TABLE parties (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE parties ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can insert parties"
  ON parties FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "Anyone can read parties"
  ON parties FOR SELECT TO anon USING (true);

-- 2. Create default party and migrate existing data
INSERT INTO parties (name) VALUES ('Bev and Jerry''s Super Bowl Party');

-- 3. Add party_id to party_picks
ALTER TABLE party_picks ADD COLUMN party_id BIGINT REFERENCES parties(id);

-- Set all existing picks to the default party
UPDATE party_picks SET party_id = (SELECT id FROM parties WHERE name = 'Bev and Jerry''s Super Bowl Party');

-- Make party_id NOT NULL now that existing rows are filled
ALTER TABLE party_picks ALTER COLUMN party_id SET NOT NULL;

-- Drop old unique constraint on name, add composite unique
ALTER TABLE party_picks DROP CONSTRAINT party_picks_name_key;
ALTER TABLE party_picks ADD CONSTRAINT party_picks_party_id_name_key UNIQUE (party_id, name);

-- 4. Alter party_answers for multi-party support
-- Remove the CHECK constraint and add party_id
ALTER TABLE party_answers DROP CONSTRAINT party_answers_pkey;
ALTER TABLE party_answers DROP CONSTRAINT IF EXISTS party_answers_id_check;
ALTER TABLE party_answers ADD COLUMN party_id BIGINT REFERENCES parties(id);

-- Set existing answer row to the default party
UPDATE party_answers SET party_id = (SELECT id FROM parties WHERE name = 'Bev and Jerry''s Super Bowl Party');

-- Make party_id the primary key
ALTER TABLE party_answers ALTER COLUMN party_id SET NOT NULL;
ALTER TABLE party_answers ADD PRIMARY KEY (party_id);

-- Drop the old id column
ALTER TABLE party_answers DROP COLUMN id;

-- Add INSERT policy for party_answers (needed when creating new parties)
CREATE POLICY "Anyone can insert answers"
  ON party_answers FOR INSERT TO anon WITH CHECK (true);
