-- Fix array types
ALTER TABLE public.clothing_items 
    ALTER COLUMN tags TYPE TEXT[] USING tags::TEXT[],
    ALTER COLUMN season_tags TYPE TEXT[] USING season_tags::TEXT[];

ALTER TABLE public.swap_listings 
    ALTER COLUMN images_urls TYPE TEXT[] USING images_urls::TEXT[],
    ALTER COLUMN preferred_swap_categories TYPE TEXT[] USING preferred_swap_categories::TEXT[];

-- Enable RLS on all tables
ALTER TABLE chat_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE clothing_item_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE clothing_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE combination_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE combinations ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE style_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE swap_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_challenge_entries ENABLE ROW LEVEL SECURITY;

-- Add RLS Policies
CREATE POLICY "Anyone can view style challenges" ON style_challenges FOR SELECT USING (true);

CREATE POLICY "Users can view their own challenge entries" ON user_challenge_entries
    FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can create their own challenge entries" ON user_challenge_entries
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can view their chats" ON chats
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM chat_participants
        WHERE chat_participants.chat_id = chats.id
        AND chat_participants.user_id = auth.uid()
    ));

CREATE POLICY "Users can view chat participants" ON chat_participants
    FOR SELECT USING (user_id = auth.uid() OR EXISTS (
        SELECT 1 FROM chat_participants cp
        WHERE cp.chat_id = chat_participants.chat_id
        AND cp.user_id = auth.uid()
    ));

CREATE POLICY "Users can view messages in their chats" ON messages
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM chat_participants
        WHERE chat_participants.chat_id = messages.chat_id
        AND chat_participants.user_id = auth.uid()
    ));

CREATE POLICY "Users can send messages to their chats" ON messages
    FOR INSERT WITH CHECK (
        sender_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM chat_participants
            WHERE chat_participants.chat_id = messages.chat_id
            AND chat_participants.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can view their own clothing usage" ON clothing_item_usage
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM clothing_items
        WHERE clothing_items.id = clothing_item_usage.clothing_item_id
        AND clothing_items.user_id = auth.uid()
    ));

CREATE POLICY "Users can create their own clothing usage" ON clothing_item_usage
    FOR INSERT WITH CHECK (EXISTS (
        SELECT 1 FROM clothing_items
        WHERE clothing_items.id = clothing_item_usage.clothing_item_id
        AND clothing_items.user_id = auth.uid()
    ));

CREATE POLICY "Users can view their own clothing items" ON clothing_items
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can manage their own clothing items" ON clothing_items
    FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Users can view public combinations" ON combinations
    FOR SELECT USING (user_id = auth.uid() OR is_public = true);

CREATE POLICY "Users can manage their own combinations" ON combinations
    FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Users can manage their own profile" ON profiles
    FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Users can view public swap listings" ON swap_listings
    FOR SELECT USING (is_active = true AND deleted_at IS NULL);

CREATE POLICY "Users can manage their own swap listings" ON swap_listings
    FOR ALL USING (user_id = auth.uid());

-- Create wear count trigger
CREATE OR REPLACE FUNCTION update_clothing_item_wear_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE clothing_items 
    SET wear_count = wear_count + 1 
    WHERE id = NEW.clothing_item_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_wear_count
    AFTER INSERT ON clothing_item_usage
    FOR EACH ROW
    EXECUTE FUNCTION update_clothing_item_wear_count();

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_clothing_items_season_tags ON clothing_items USING GIN (season_tags);
CREATE INDEX IF NOT EXISTS idx_combinations_occasion ON combinations(occasion);
CREATE INDEX IF NOT EXISTS idx_combinations_season ON combinations(season);
CREATE INDEX IF NOT EXISTS idx_profiles_style_preferences ON profiles USING GIN (style_preferences);
CREATE INDEX IF NOT EXISTS idx_profiles_seasonal_preferences ON profiles USING GIN (seasonal_preferences);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_style_challenges_date_range ON style_challenges(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_clothing_item_usage_date ON clothing_item_usage(date_worn);
CREATE INDEX IF NOT EXISTS idx_messages_chat_id ON messages(chat_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
