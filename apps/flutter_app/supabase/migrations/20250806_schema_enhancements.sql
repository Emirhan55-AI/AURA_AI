-- Migration: Schema Enhancements for Aura App
-- Created: 2025-08-06
-- Description: Adds new tables and columns for enhanced functionality

-- =============================================
-- 1. NEW TABLES FOR STYLE ASSISTANT
-- =============================================

-- Style Challenges Table
CREATE TABLE IF NOT EXISTS style_challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    requirements JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for style_challenges
ALTER TABLE style_challenges ENABLE ROW LEVEL SECURITY;

-- RLS Policies for style_challenges
CREATE POLICY "Anyone can view style challenges" ON style_challenges
    FOR SELECT USING (true);

-- User Challenge Entries Table
CREATE TABLE IF NOT EXISTS user_challenge_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    challenge_id UUID REFERENCES style_challenges(id) ON DELETE CASCADE,
    combination_id UUID REFERENCES combinations(id) ON DELETE CASCADE,
    submission_date TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for user_challenge_entries
ALTER TABLE user_challenge_entries ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_challenge_entries
CREATE POLICY "Users can view their own challenge entries" ON user_challenge_entries
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can create their own challenge entries" ON user_challenge_entries
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- =============================================
-- 2. NEW TABLES FOR MESSAGING SYSTEM
-- =============================================

-- Chats Table
CREATE TABLE IF NOT EXISTS chats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for chats
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;

-- Chat Participants Table
CREATE TABLE IF NOT EXISTS chat_participants (
    chat_id UUID REFERENCES chats(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    PRIMARY KEY (chat_id, user_id)
);

-- Enable RLS for chat_participants
ALTER TABLE chat_participants ENABLE ROW LEVEL SECURITY;

-- Messages Table
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chat_id UUID REFERENCES chats(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for messages
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- RLS Policies for chat system
CREATE POLICY "Users can view their chats" ON chats
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM chat_participants
            WHERE chat_participants.chat_id = chats.id
            AND chat_participants.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can view chat participants" ON chat_participants
    FOR SELECT USING (user_id = auth.uid() OR 
        EXISTS (
            SELECT 1 FROM chat_participants cp
            WHERE cp.chat_id = chat_participants.chat_id
            AND cp.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can view messages in their chats" ON messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM chat_participants
            WHERE chat_participants.chat_id = messages.chat_id
            AND chat_participants.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can send messages to their chats" ON messages
    FOR INSERT WITH CHECK (
        sender_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM chat_participants
            WHERE chat_participants.chat_id = messages.chat_id
            AND chat_participants.user_id = auth.uid()
        )
    );

-- =============================================
-- 3. NEW TABLES FOR ANALYTICS
-- =============================================

-- Clothing Item Usage Table
CREATE TABLE IF NOT EXISTS clothing_item_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clothing_item_id UUID REFERENCES clothing_items(id) ON DELETE CASCADE,
    date_worn DATE,
    weather_data JSONB,
    occasion TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for clothing_item_usage
ALTER TABLE clothing_item_usage ENABLE ROW LEVEL SECURITY;

-- RLS Policies for clothing_item_usage
CREATE POLICY "Users can view their own clothing usage" ON clothing_item_usage
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM clothing_items
            WHERE clothing_items.id = clothing_item_usage.clothing_item_id
            AND clothing_items.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create their own clothing usage" ON clothing_item_usage
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM clothing_items
            WHERE clothing_items.id = clothing_item_usage.clothing_item_id
            AND clothing_items.user_id = auth.uid()
        )
    );

-- =============================================
-- 4. NEW COLUMNS FOR EXISTING TABLES
-- =============================================

-- Add columns to clothing_items
ALTER TABLE clothing_items ADD COLUMN IF NOT EXISTS wear_count INTEGER DEFAULT 0;
ALTER TABLE clothing_items ADD COLUMN IF NOT EXISTS season_tags TEXT[];

-- Add index for season_tags
CREATE INDEX IF NOT EXISTS idx_clothing_items_season_tags ON clothing_items USING GIN (season_tags);

-- Add columns to combinations
ALTER TABLE combinations ADD COLUMN IF NOT EXISTS occasion TEXT;
ALTER TABLE combinations ADD COLUMN IF NOT EXISTS season TEXT;

-- Add index for occasion and season
CREATE INDEX IF NOT EXISTS idx_combinations_occasion ON combinations(occasion);
CREATE INDEX IF NOT EXISTS idx_combinations_season ON combinations(season);

-- Add columns to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS style_preferences JSONB;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS seasonal_preferences JSONB;

-- Add index for JSONB fields
CREATE INDEX IF NOT EXISTS idx_profiles_style_preferences ON profiles USING GIN (style_preferences);
CREATE INDEX IF NOT EXISTS idx_profiles_seasonal_preferences ON profiles USING GIN (seasonal_preferences);

-- =============================================
-- 5. FUNCTIONS AND TRIGGERS FOR ANALYTICS
-- =============================================

-- Function to update wear_count when usage is logged
CREATE OR REPLACE FUNCTION update_clothing_item_wear_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE clothing_items 
    SET wear_count = wear_count + 1 
    WHERE id = NEW.clothing_item_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for updating wear_count
CREATE TRIGGER trigger_update_wear_count
    AFTER INSERT ON clothing_item_usage
    FOR EACH ROW
    EXECUTE FUNCTION update_clothing_item_wear_count();

-- =============================================
-- 6. INDEXES FOR PERFORMANCE
-- =============================================

-- Add indexes for timestamp columns
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_style_challenges_date_range ON style_challenges(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_clothing_item_usage_date ON clothing_item_usage(date_worn);

-- Add indexes for foreign keys
CREATE INDEX IF NOT EXISTS idx_user_challenge_entries_user_id ON user_challenge_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_user_challenge_entries_challenge_id ON user_challenge_entries(challenge_id);
CREATE INDEX IF NOT EXISTS idx_messages_chat_id ON messages(chat_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
