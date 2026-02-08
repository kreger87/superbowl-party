-- Super Bowl LX Party Prop Game - Supabase Migration (Fresh Install)
-- Run this in the Supabase SQL Editor

-- Parties table
CREATE TABLE IF NOT EXISTS parties (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  creator_token UUID DEFAULT gen_random_uuid() NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table for guest picks
CREATE TABLE IF NOT EXISTS party_picks (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  party_id UUID NOT NULL REFERENCES parties(id),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  q1  TEXT, -- Coin Toss
  q2  TEXT, -- National Anthem Length
  q3  TEXT, -- First Commercial
  q4  TEXT, -- First Team to Score
  q5  TEXT, -- First TD Scorer
  q6  TEXT, -- First Half Total Points
  q7  TEXT, -- Bad Bunny's First Song
  q8  TEXT, -- Halftime Guest Performer
  q9  TEXT, -- Which QB Throws More Yards
  q10 TEXT, -- Defensive/ST TD?
  q11 TEXT, -- Total Game Points
  q12 TEXT, -- Longest Field Goal
  q13 TEXT, -- Super Bowl Winner
  q14 TEXT, -- Super Bowl MVP
  q15 TEXT, -- Gatorade Bath Color
  q16 TEXT, -- Bonus: Anytime TD Scorer
  UNIQUE(party_id, name)
);

-- Table for correct answers (one row per party, updated by host)
CREATE TABLE IF NOT EXISTS party_answers (
  party_id UUID PRIMARY KEY REFERENCES parties(id),
  q1  TEXT,
  q2  TEXT,
  q3  TEXT,
  q4  TEXT,
  q5  TEXT,
  q6  TEXT,
  q7  TEXT,
  q8  TEXT,
  q9  TEXT,
  q10 TEXT,
  q11 TEXT,
  q12 TEXT,
  q13 TEXT,
  q14 TEXT,
  q15 TEXT,
  q16 TEXT
);

-- Enable RLS
ALTER TABLE parties ENABLE ROW LEVEL SECURITY;
ALTER TABLE party_picks ENABLE ROW LEVEL SECURITY;
ALTER TABLE party_answers ENABLE ROW LEVEL SECURITY;

-- Parties: restrict SELECT to safe columns only (no creator_token)
REVOKE SELECT ON parties FROM anon;
GRANT SELECT (id, name, created_at) ON parties TO anon;

-- Parties: no direct INSERT from anon (use create_party RPC instead)
REVOKE INSERT ON parties FROM anon;

CREATE POLICY "Anyone can read parties"
  ON parties FOR SELECT TO anon USING (true);

-- RLS Policies for party_picks
CREATE POLICY "Anyone can insert picks"
  ON party_picks FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Anyone can read picks"
  ON party_picks FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Anyone can delete picks"
  ON party_picks FOR DELETE
  TO anon
  USING (true);

-- RLS Policies for party_answers
CREATE POLICY "Anyone can read answers"
  ON party_answers FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Anyone can insert answers"
  ON party_answers FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Anyone can update answers"
  ON party_answers FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);

-- Verify creator token RPC function
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

-- Create party RPC function (returns token only to the creator)
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
