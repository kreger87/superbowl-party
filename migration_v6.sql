-- Super Bowl LX Party Prop Game - Allow pick edits
-- Run this in the Supabase SQL Editor AFTER migration_v5.sql

-- Add UPDATE policy so guests can edit their picks before the deadline
CREATE POLICY "Anyone can update picks"
  ON party_picks FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);
