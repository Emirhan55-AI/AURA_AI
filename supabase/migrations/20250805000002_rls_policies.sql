-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clothing_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.outfits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.outfit_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.social_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.social_post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.social_post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Profiles RLS policies
CREATE POLICY "Users can view all public profiles" ON profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can update their own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Clothing items RLS policies
CREATE POLICY "Users can view their own clothing items" ON clothing_items
  FOR SELECT USING (auth.uid() = user_id AND deleted_at IS NULL);

CREATE POLICY "Users can insert their own clothing items" ON clothing_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own clothing items" ON clothing_items
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own clothing items" ON clothing_items
  FOR DELETE USING (auth.uid() = user_id);

-- Outfits RLS policies
CREATE POLICY "Users can view their own outfits" ON outfits
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own outfits" ON outfits
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own outfits" ON outfits
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own outfits" ON outfits
  FOR DELETE USING (auth.uid() = user_id);

-- Outfit items RLS policies
CREATE POLICY "Users can view outfit items for their outfits" ON outfit_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM outfits 
      WHERE outfits.id = outfit_items.outfit_id 
      AND outfits.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can manage outfit items for their outfits" ON outfit_items
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM outfits 
      WHERE outfits.id = outfit_items.outfit_id 
      AND outfits.user_id = auth.uid()
    )
  );

-- Social posts RLS policies
CREATE POLICY "Users can view public social posts" ON social_posts
  FOR SELECT USING (
    visibility = 'public' OR 
    auth.uid() = user_id OR
    (visibility = 'friends' AND EXISTS (
      SELECT 1 FROM user_follows 
      WHERE following_id = social_posts.user_id 
      AND follower_id = auth.uid()
    ))
  );

CREATE POLICY "Users can insert their own social posts" ON social_posts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own social posts" ON social_posts
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own social posts" ON social_posts
  FOR DELETE USING (auth.uid() = user_id);

-- Social post likes RLS policies
CREATE POLICY "Users can view likes on visible posts" ON social_post_likes
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM social_posts 
      WHERE social_posts.id = social_post_likes.post_id
      AND (
        social_posts.visibility = 'public' OR 
        social_posts.user_id = auth.uid() OR
        (social_posts.visibility = 'friends' AND EXISTS (
          SELECT 1 FROM user_follows 
          WHERE following_id = social_posts.user_id 
          AND follower_id = auth.uid()
        ))
      )
    )
  );

CREATE POLICY "Users can manage their own likes" ON social_post_likes
  FOR ALL USING (auth.uid() = user_id);

-- Social post comments RLS policies
CREATE POLICY "Users can view comments on visible posts" ON social_post_comments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM social_posts 
      WHERE social_posts.id = social_post_comments.post_id
      AND (
        social_posts.visibility = 'public' OR 
        social_posts.user_id = auth.uid() OR
        (social_posts.visibility = 'friends' AND EXISTS (
          SELECT 1 FROM user_follows 
          WHERE following_id = social_posts.user_id 
          AND follower_id = auth.uid()
        ))
      )
    )
  );

CREATE POLICY "Users can insert comments on visible posts" ON social_post_comments
  FOR INSERT WITH CHECK (
    auth.uid() = user_id AND
    EXISTS (
      SELECT 1 FROM social_posts 
      WHERE social_posts.id = social_post_comments.post_id
      AND (
        social_posts.visibility = 'public' OR 
        social_posts.user_id = auth.uid() OR
        (social_posts.visibility = 'friends' AND EXISTS (
          SELECT 1 FROM user_follows 
          WHERE following_id = social_posts.user_id 
          AND follower_id = auth.uid()
        ))
      )
    )
  );

CREATE POLICY "Users can update their own comments" ON social_post_comments
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own comments" ON social_post_comments
  FOR DELETE USING (auth.uid() = user_id);

-- User follows RLS policies
CREATE POLICY "Users can view all follows" ON user_follows
  FOR SELECT USING (true);

CREATE POLICY "Users can manage their own follows" ON user_follows
  FOR ALL USING (auth.uid() = follower_id);

-- Notifications RLS policies
CREATE POLICY "Users can view their own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- Messages RLS policies
CREATE POLICY "Users can view their own messages" ON messages
  FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = recipient_id);

CREATE POLICY "Users can send messages" ON messages
  FOR INSERT WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can update messages they sent" ON messages
  FOR UPDATE USING (auth.uid() = sender_id);

-- Clothing categories are public (read-only for users)
ALTER TABLE public.clothing_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view clothing categories" ON clothing_categories
  FOR SELECT USING (true);
