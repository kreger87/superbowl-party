-- Super Bowl LX Party Prop Game - UUID & Creator Token Migration
-- Run this in the Supabase SQL Editor AFTER migration_v2.sql
--
-- Changes:
--   1. Convert parties.id from BIGINT to UUID
--   2. Convert party_picks.party_id and party_answers.party_id to UUID
--   3. Add creator_token UUID column to parties
--   4. Add DELETE RLS policy on party_picks
--   5. Create verify_creator_token() RPC function
--   6. Output existing party tokens for admin recovery

BEGIN;

-- ============================================================
-- 1. ADD STAGING UUID COLUMNS
-- ============================================================

-- parties: new UUID primary key
ALTER TABLE parties ADD COLUMN new_id UUID DEFAULT gen_random_uuid();
UPDATE parties SET new_id = gen_random_uuid() WHERE new_id IS NULL;

-- party_picks: new UUID foreign key
ALTER TABLE party_picks ADD COLUMN new_party_id UUID;

-- party_answers: new UUID foreign key / primary key
ALTER TABLE party_answers ADD COLUMN new_party_id UUID;

-- ============================================================
-- 2. BACKFILL UUID COLUMNS FROM JOINS
-- ============================================================

UPDATE party_picks pp
SET new_party_id = p.new_id
FROM parties p
WHERE pp.party_id = p.id;

UPDATE party_answers pa
SET new_party_id = p.new_id
FROM parties p
WHERE pa.party_id = p.id;

-- ============================================================
-- 3. DROP OLD CONSTRAINTS
-- ============================================================

-- Drop composite unique on party_picks (party_id, name)
ALTER TABLE party_picks DROP CONSTRAINT party_picks_party_id_name_key;

-- Drop primary key on party_answers (party_id)
ALTER TABLE party_answers DROP CONSTRAINT party_answers_pkey;

-- Drop foreign keys (auto-named by Postgres)
ALTER TABLE party_picks DROP CONSTRAINT party_picks_party_id_fkey;
ALTER TABLE party_answers DROP CONSTRAINT party_answers_party_id_fkey;

-- ============================================================
-- 4. DROP OLD COLUMNS, RENAME NEW COLUMNS
-- ============================================================

-- parties: drop old id, rename new_id to id
ALTER TABLE parties DROP COLUMN id;
ALTER TABLE parties RENAME COLUMN new_id TO id;
ALTER TABLE parties ALTER COLUMN id SET NOT NULL;
ALTER TABLE parties ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE parties ADD PRIMARY KEY (id);

-- party_picks: drop old party_id, rename new_party_id to party_id
ALTER TABLE party_picks DROP COLUMN party_id;
ALTER TABLE party_picks RENAME COLUMN new_party_id TO party_id;
ALTER TABLE party_picks ALTER COLUMN party_id SET NOT NULL;

-- party_answers: drop old party_id, rename new_party_id to party_id
ALTER TABLE party_answers DROP COLUMN party_id;
ALTER TABLE party_answers RENAME COLUMN new_party_id TO party_id;
ALTER TABLE party_answers ALTER COLUMN party_id SET NOT NULL;

-- ============================================================
-- 5. RE-ADD CONSTRAINTS
-- ============================================================

ALTER TABLE party_picks
  ADD CONSTRAINT party_picks_party_id_fkey FOREIGN KEY (party_id) REFERENCES parties(id);

ALTER TABLE party_picks
  ADD CONSTRAINT party_picks_party_id_name_key UNIQUE (party_id, name);

ALTER TABLE party_answers
  ADD CONSTRAINT party_answers_party_id_fkey FOREIGN KEY (party_id) REFERENCES parties(id);

ALTER TABLE party_answers
  ADD PRIMARY KEY (party_id);

-- ============================================================
-- 6. ADD CREATOR TOKEN
-- ============================================================

ALTER TABLE parties ADD COLUMN creator_token UUID DEFAULT gen_random_uuid();
UPDATE parties SET creator_token = gen_random_uuid() WHERE creator_token IS NULL;
ALTER TABLE parties ALTER COLUMN creator_token SET NOT NULL;

-- ============================================================
-- 7. DELETE RLS POLICY ON party_picks
-- ============================================================

CREATE POLICY "Anyone can delete picks"
  ON party_picks FOR DELETE
  TO anon
  USING (true);

-- ============================================================
-- 8. VERIFY CREATOR TOKEN RPC FUNCTION
-- ============================================================

CREATE OR REPLACE FUNCTION verify_creator_token(p_party_id UUID, p_token UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM parties
    WHERE id = p_party_id AND creator_token = p_token
  );
END;
$$;

COMMIT;

-- ============================================================
-- 9. OUTPUT EXISTING TOKENS (run after commit)
-- ============================================================
-- This shows the new UUIDs and creator tokens for existing parties.
-- Use these to restore admin access:
--   leaderboard.html?party=<id>&admin=<creator_token>

SELECT id, name, creator_token FROM parties;
