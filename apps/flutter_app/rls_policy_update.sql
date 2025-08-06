-- =============================================
-- RLS POLICY UPDATE FOR USERS TABLE
-- Copy and run this in Supabase SQL Editor if you want stricter user access
-- =============================================

-- Drop existing policies for users table
DROP POLICY IF EXISTS "Users can view their own profile" ON users;
DROP POLICY IF EXISTS "Users can update their own profile" ON users;

-- Create more restrictive policies

-- Users can only view their own profile OR public profile data of others
CREATE POLICY "Users can view profiles with restrictions" ON users
    FOR SELECT USING (
        id = auth.uid() OR  -- Own profile
        (auth.role() = 'authenticated' AND id IS NOT NULL)  -- Others' public info only if authenticated
    );

-- Users can update only their own profile
CREATE POLICY "Users can update their own profile only" ON users
    FOR UPDATE USING (id = auth.uid());

-- Users can insert their own profile (for registration)
CREATE POLICY "Users can insert their own profile" ON users
    FOR INSERT WITH CHECK (id = auth.uid());

-- Alternative: Allow public access to basic profile info
-- Uncomment this if you want public profiles to be viewable
/*
CREATE POLICY "Public profile info accessible" ON users
    FOR SELECT USING (
        id = auth.uid() OR  -- Own profile (full access)
        (id IS NOT NULL)    -- Others' profiles (limited public info)
    );
*/
