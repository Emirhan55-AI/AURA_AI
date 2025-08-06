-- RLS Policy Fix for Users Table
-- Run this in Supabase SQL Editor

-- Add INSERT policy for users table
CREATE POLICY "Users can insert their own profile" ON users
    FOR INSERT WITH CHECK (id = auth.uid());

-- Add better error handling policy for profiles  
DROP POLICY IF EXISTS "Users can insert their own extended profile" ON profiles;
CREATE POLICY "Users can insert their own extended profile" ON profiles
    FOR INSERT WITH CHECK (user_id = auth.uid());
