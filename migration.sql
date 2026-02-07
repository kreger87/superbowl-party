-- Super Bowl LX Party Prop Game - Supabase Migration
-- Run this in the Supabase SQL Editor

-- Table for guest picks
CREATE TABLE IF NOT EXISTS party_picks (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
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
  q16 TEXT  -- Bonus: Anytime TD Scorer
);

-- Table for correct answers (single row, updated by host)
CREATE TABLE IF NOT EXISTS party_answers (
  id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
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

-- Seed the answers table with an empty row
INSERT INTO party_answers (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

-- Enable RLS
ALTER TABLE party_picks ENABLE ROW LEVEL SECURITY;
ALTER TABLE party_answers ENABLE ROW LEVEL SECURITY;

-- RLS Policies for party_picks
-- Anyone can insert their picks
CREATE POLICY "Anyone can insert picks"
  ON party_picks FOR INSERT
  TO anon
  WITH CHECK (true);

-- Anyone can read all picks
CREATE POLICY "Anyone can read picks"
  ON party_picks FOR SELECT
  TO anon
  USING (true);

-- RLS Policies for party_answers
-- Anyone can read answers
CREATE POLICY "Anyone can read answers"
  ON party_answers FOR SELECT
  TO anon
  USING (true);

-- Anyone can update answers (admin password is enforced client-side)
CREATE POLICY "Anyone can update answers"
  ON party_answers FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);
