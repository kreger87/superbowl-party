-- Super Bowl LX Party Prop Game - Lock Down creator_token
-- Run this in the Supabase SQL Editor AFTER migration_v3.sql
--
-- Problem: anon can SELECT creator_token directly from parties table.
-- Fix: Revoke table-level SELECT/INSERT, grant only safe columns,
--       and use an RPC function for party creation.

-- ============================================================
-- 1. RESTRICT SELECT TO SAFE COLUMNS ONLY
-- ============================================================

-- Remove table-level SELECT (which exposes all columns)
REVOKE SELECT ON parties FROM anon;

-- Grant column-level SELECT on only the safe columns
GRANT SELECT (id, name, created_at) ON parties TO anon;

-- ============================================================
-- 2. RESTRICT INSERT (prevent crafting a known creator_token)
-- ============================================================

-- Remove direct INSERT from anon (party creation goes through RPC now)
REVOKE INSERT ON parties FROM anon;

-- Drop the now-useless INSERT policy
DROP POLICY IF EXISTS "Anyone can insert parties" ON parties;

-- ============================================================
-- 3. CREATE PARTY RPC FUNCTION
-- ============================================================

-- SECURITY DEFINER runs as the function owner (bypasses column restrictions).
-- This is the only way anon can create a party and receive the token.
CREATE OR REPLACE FUNCTION create_party(p_name TEXT)
RETURNS TABLE(id UUID, name TEXT, creator_token UUID)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_party RECORD;
BEGIN
  INSERT INTO parties (name) VALUES (p_name)
  RETURNING parties.id, parties.name, parties.creator_token INTO v_party;

  INSERT INTO party_answers (party_id) VALUES (v_party.id);

  RETURN QUERY SELECT v_party.id, v_party.name, v_party.creator_token;
END;
$$;
