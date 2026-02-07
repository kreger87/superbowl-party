-- Super Bowl LX Party Prop Game - Supabase Migration (Fresh Install)
-- Run this in the Supabase SQL Editor

-- Parties table
CREATE TABLE IF NOT EXISTS parties (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table for guest picks
CREATE TABLE IF NOT EXISTS party_picks (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  party_id BIGINT NOT NULL REFERENCES parties(id),
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
  party_id BIGINT PRIMARY KEY REFERENCES parties(id),
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

-- RLS Policies for parties
CREATE POLICY "Anyone can insert parties"
  ON parties FOR INSERT TO anon WITH CHECK (true);

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
