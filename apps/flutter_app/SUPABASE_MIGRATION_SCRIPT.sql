-- =============================================
-- AURA DATABASE SCHEMA MIGRATION
-- Copy this entire script and paste it into Supabase SQL Editor
-- =============================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Function to update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ language 'plpgsql';

-- =============================================
-- CORE TABLES
-- =============================================

-- users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    username TEXT UNIQUE,
    avatar_url TEXT,
    bio TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login TIMESTAMPTZ
);

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE PROCEDURE update_updated_at_column();

-- profiles table (extended user data)
CREATE TABLE IF NOT EXISTS profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    preferred_style JSONB,
    measurements JSONB,
    onboarding_skipped BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON profiles 
    FOR EACH ROW 
    EXECUTE PROCEDURE update_updated_at_column();

-- clothing_items table
CREATE TABLE IF NOT EXISTS clothing_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    category TEXT,
    color TEXT,
    pattern TEXT,
    brand TEXT,
    purchase_date DATE,
    price NUMERIC,
    currency TEXT DEFAULT 'USD',
    image_url TEXT,
    notes TEXT,
    tags TEXT[],
    ai_tags JSONB,
    last_worn_date DATE,
    is_favorite BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_clothing_items_updated_at 
    BEFORE UPDATE ON clothing_items 
    FOR EACH ROW 
    EXECUTE PROCEDURE update_updated_at_column();

-- Indexes for clothing_items
CREATE INDEX IF NOT EXISTS idx_clothing_items_user_id ON clothing_items(user_id);
CREATE INDEX IF NOT EXISTS idx_clothing_items_category ON clothing_items(category);
CREATE INDEX IF NOT EXISTS idx_clothing_items_tags ON clothing_items USING GIN (tags);
CREATE INDEX IF NOT EXISTS idx_clothing_items_ai_tags ON clothing_items USING GIN (ai_tags);

-- combinations table
CREATE TABLE IF NOT EXISTS combinations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    cover_image_url TEXT,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_combinations_updated_at 
    BEFORE UPDATE ON combinations 
    FOR EACH ROW 
    EXECUTE PROCEDURE update_updated_at_column();

CREATE INDEX IF NOT EXISTS idx_combinations_user_id ON combinations(user_id);
CREATE INDEX IF NOT EXISTS idx_combinations_is_public ON combinations(is_public);

-- combination_items table (junction table)
CREATE TABLE IF NOT EXISTS combination_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    combination_id UUID NOT NULL REFERENCES combinations(id) ON DELETE CASCADE,
    clothing_item_id UUID NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
    position_data JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(combination_id, clothing_item_id)
);

CREATE INDEX IF NOT EXISTS idx_combination_items_combination_id ON combination_items(combination_id);
CREATE INDEX IF NOT EXISTS idx_combination_items_clothing_item_id ON combination_items(clothing_item_id);

-- =============================================
-- SOCIAL FEATURES TABLES
-- =============================================

-- follows table
CREATE TABLE IF NOT EXISTS follows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(follower_id, following_id),
    CHECK(follower_id != following_id)
);

CREATE INDEX IF NOT EXISTS idx_follows_follower_id ON follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following_id ON follows(following_id);

-- likes table
CREATE TABLE IF NOT EXISTS likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    combination_id UUID NOT NULL REFERENCES combinations(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, combination_id)
);

CREATE INDEX IF NOT EXISTS idx_likes_user_id ON likes(user_id);
CREATE INDEX IF NOT EXISTS idx_likes_combination_id ON likes(combination_id);

-- comments table
CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    combination_id UUID NOT NULL REFERENCES combinations(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_comments_updated_at 
    BEFORE UPDATE ON comments 
    FOR EACH ROW 
    EXECUTE PROCEDURE update_updated_at_column();

CREATE INDEX IF NOT EXISTS idx_comments_user_id ON comments(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_combination_id ON comments(combination_id);
CREATE INDEX IF NOT EXISTS idx_comments_parent_comment_id ON comments(parent_comment_id);

-- =============================================
-- MARKETPLACE & NOTIFICATIONS
-- =============================================

-- swap_listings table
CREATE TABLE IF NOT EXISTS swap_listings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    clothing_item_id UUID REFERENCES clothing_items(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    images_urls TEXT[],
    condition TEXT,
    preferred_swap_categories TEXT[],
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TRIGGER update_swap_listings_updated_at 
    BEFORE UPDATE ON swap_listings 
    FOR EACH ROW 
    EXECUTE PROCEDURE update_updated_at_column();

CREATE INDEX IF NOT EXISTS idx_swap_listings_user_id ON swap_listings(user_id);
CREATE INDEX IF NOT EXISTS idx_swap_listings_is_active ON swap_listings(is_active);

-- notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    message TEXT,
    data JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);

-- =============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE clothing_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE combinations ENABLE ROW LEVEL SECURITY;
ALTER TABLE combination_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE swap_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (id = auth.uid());
CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (id = auth.uid());

-- Profiles policies
CREATE POLICY "Users can view their own extended profile" ON profiles
    FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can insert their own extended profile" ON profiles
    FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users can update their own extended profile" ON profiles
    FOR UPDATE USING (user_id = auth.uid());

-- Clothing items policies
CREATE POLICY "Users can view their own clothing items" ON clothing_items
    FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can insert their own clothing items" ON clothing_items
    FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users can update their own clothing items" ON clothing_items
    FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Users can delete their own clothing items" ON clothing_items
    FOR DELETE USING (user_id = auth.uid());

-- Combinations policies
CREATE POLICY "Users can view their own or public combinations" ON combinations
    FOR SELECT USING (user_id = auth.uid() OR is_public = true);
CREATE POLICY "Users can insert their own combinations" ON combinations
    FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users can update their own combinations" ON combinations
    FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Users can delete their own combinations" ON combinations
    FOR DELETE USING (user_id = auth.uid());

-- Combination items policies
CREATE POLICY "Users can view combination items for accessible combinations" ON combination_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM combinations 
            WHERE combinations.id = combination_items.combination_id 
            AND (combinations.user_id = auth.uid() OR combinations.is_public = true)
        )
    );
CREATE POLICY "Users can manage their own combination items" ON combination_items
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM combinations 
            WHERE combinations.id = combination_items.combination_id 
            AND combinations.user_id = auth.uid()
        )
    );

-- Social policies
CREATE POLICY "Users can view all follows" ON follows
    FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can follow others" ON follows
    FOR INSERT WITH CHECK (follower_id = auth.uid());
CREATE POLICY "Users can unfollow others" ON follows
    FOR DELETE USING (follower_id = auth.uid());

CREATE POLICY "Users can view all likes" ON likes
    FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can like public combinations" ON likes
    FOR INSERT WITH CHECK (
        user_id = auth.uid() AND
        EXISTS (SELECT 1 FROM combinations WHERE combinations.id = likes.combination_id AND combinations.is_public = true)
    );
CREATE POLICY "Users can unlike their own likes" ON likes
    FOR DELETE USING (user_id = auth.uid());

CREATE POLICY "Users can view comments on public combinations" ON comments
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM combinations WHERE combinations.id = comments.combination_id AND combinations.is_public = true)
    );
CREATE POLICY "Users can comment on public combinations" ON comments
    FOR INSERT WITH CHECK (
        user_id = auth.uid() AND
        EXISTS (SELECT 1 FROM combinations WHERE combinations.id = comments.combination_id AND combinations.is_public = true)
    );
CREATE POLICY "Users can update their own comments" ON comments
    FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Users can delete their own comments" ON comments
    FOR DELETE USING (user_id = auth.uid());

-- Marketplace policies
CREATE POLICY "Users can view active swap listings" ON swap_listings
    FOR SELECT USING (is_active = true AND deleted_at IS NULL);
CREATE POLICY "Users can insert their own swap listings" ON swap_listings
    FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users can update their own swap listings" ON swap_listings
    FOR UPDATE USING (user_id = auth.uid());

-- Notifications policies
CREATE POLICY "Users can view their own notifications" ON notifications
    FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can update their own notifications" ON notifications
    FOR UPDATE USING (user_id = auth.uid());

-- =============================================
-- AUTOMATIC COUNTERS AND TRIGGERS
-- =============================================

-- Function to update likes_count on combinations
CREATE OR REPLACE FUNCTION update_combination_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE combinations 
        SET likes_count = likes_count + 1 
        WHERE id = NEW.combination_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE combinations 
        SET likes_count = likes_count - 1 
        WHERE id = OLD.combination_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Triggers for automatic likes count
CREATE TRIGGER trigger_update_combination_likes_count_insert
    AFTER INSERT ON likes
    FOR EACH ROW
    EXECUTE FUNCTION update_combination_likes_count();

CREATE TRIGGER trigger_update_combination_likes_count_delete
    AFTER DELETE ON likes
    FOR EACH ROW
    EXECUTE FUNCTION update_combination_likes_count();

-- =============================================
-- SAMPLE DATA (FOR TESTING)
-- =============================================

INSERT INTO users (id, email, full_name, username, avatar_url, bio) 
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'test@aura.com',
    'Test User',
    'testuser',
    'https://example.com/avatar.jpg',
    'This is a test user for development'
) ON CONFLICT (id) DO NOTHING;

INSERT INTO profiles (user_id, preferred_style, onboarding_skipped) 
VALUES (
    '00000000-0000-0000-0000-000000000001',
    '{"styles": ["casual", "modern"], "colors": ["blue", "black"]}',
    false
) ON CONFLICT (user_id) DO NOTHING;
