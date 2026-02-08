-- Super Bowl LX Party Prop Game - Add CASCADE deletes
-- Run this in the Supabase SQL Editor AFTER migration_v4.sql
--
-- Problem: Can't delete a party because party_picks and party_answers
--          still reference it via foreign keys.
-- Fix: Re-create the FKs with ON DELETE CASCADE.

-- party_picks
ALTER TABLE party_picks
  DROP CONSTRAINT party_picks_party_id_fkey;

ALTER TABLE party_picks
  ADD CONSTRAINT party_picks_party_id_fkey
  FOREIGN KEY (party_id) REFERENCES parties(id) ON DELETE CASCADE;

-- party_answers
ALTER TABLE party_answers
  DROP CONSTRAINT party_answers_party_id_fkey;

ALTER TABLE party_answers
  ADD CONSTRAINT party_answers_party_id_fkey
  FOREIGN KEY (party_id) REFERENCES parties(id) ON DELETE CASCADE;
