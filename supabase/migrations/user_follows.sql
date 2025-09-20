-- user_follows.sql
-- Create the user_follows table with Instagram-style follow system support

CREATE TABLE IF NOT EXISTS user_follows (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  follower_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  followed_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status VARCHAR(255) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  
  -- Ensure no duplicate follows
  UNIQUE(follower_id, followed_id)
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_follows_follower ON user_follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_followed ON user_follows(followed_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_status ON user_follows(status);

-- Automatic updated_at update
CREATE OR REPLACE FUNCTION update_user_follows_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc', NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_user_follows_updated_at
BEFORE UPDATE ON user_follows
FOR EACH ROW
EXECUTE FUNCTION update_user_follows_updated_at();

-- Row Level Security (RLS) policies
ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;

-- Allow users to see their own follow relationships
CREATE POLICY "Users can view their own follow relationships"
ON user_follows
FOR SELECT
USING (
  auth.uid() = follower_id OR auth.uid() = followed_id
);

-- Allow users to create follow requests
CREATE POLICY "Users can create follow requests"
ON user_follows
FOR INSERT
WITH CHECK (
  auth.uid() = follower_id
);

-- Allow users to update follow requests they've received
CREATE POLICY "Users can update follow requests they've received"
ON user_follows
FOR UPDATE
USING (
  auth.uid() = followed_id AND OLD.status = 'pending'
);

-- Allow users to delete their own follow relationships
CREATE POLICY "Users can delete their own follow relationships"
ON user_follows
FOR DELETE
USING (
  auth.uid() = follower_id
);
