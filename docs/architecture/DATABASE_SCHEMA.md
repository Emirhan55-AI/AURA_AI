# Aura Database Schema

This document defines the schema for the Aura application's database hosted on Supabase. It details the tables, their columns, relationships (Foreign Keys), and Row Level Security (RLS) policies to ensure data isolation and security.

It is designed to align with the architectural principles in `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf` and the data access patterns defined in `API_INTEGRATION.md` and `BACKEND_SERVICES.md`. It explicitly considers how RLS policies interact with API calls made from the Flutter frontend and the FastAPI backend.

## 1. Overview

The database is designed to store user profiles, their wardrobe items (clothing), user-generated combinations, social features (following, likes, comments), marketplace listings (SwapMarket), and notifications. It leverages PostgreSQL's features within Supabase for relational integrity, real-time capabilities, and advanced data types like `VECTOR` for AI embeddings. <sup>[[1]](https://supabase.com/docs/guides/database) [[2]](https://www.postgresql.org/docs/)</sup>

### 1.1. Data Lifecycle & Access Strategy

Data flows from the Flutter frontend and FastAPI backend through defined API endpoints (REST, GraphQL, Realtime) provided by Supabase. Access to data is governed by Row Level Security (RLS) policies defined on each table. The application layers (Repository in Flutter, Services in FastAPI) interact with these Supabase APIs. It's crucial to understand that RLS policies are evaluated for every query hitting the database, whether initiated by the Flutter app directly or by the FastAPI backend on behalf of the Flutter app. See `API_INTEGRATION.md` and `BACKEND_SERVICES.md` for details on how the application layers authenticate and authorize these calls using Supabase JWTs. <sup>[[3]](https://supabase.com/docs/guides/auth/row-level-security)</sup>

### 1.2. Timestamps and Soft Deletes

To ensure data integrity and auditability, the following timestamp columns are recommended for most tables:

*   `created_at`: `TIMESTAMPTZ NOT NULL DEFAULT NOW()`
*   `updated_at`: `TIMESTAMPTZ NOT NULL DEFAULT NOW()`
*   `deleted_at`: `TIMESTAMPTZ` (Optional, for soft-delete on tables where historical data is valuable, e.g., `swap_listings`).

An automatic trigger will update the `updated_at` column on every row modification. <sup>[[4]](https://x-team.com/blog/automatic-timestamps-with-postgresql/)</sup>

```sql
-- Function to update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger example for clothing_items table
CREATE TRIGGER update_clothing_items_updated_at BEFORE UPDATE
ON clothing_items FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Repeat for other relevant tables
```

## 2. Core Tables

### 2.1. `users`

Stores core user profile information. This table is often auto-populated by Supabase Auth, but can be extended.

| Column Name       | Data Type     | Constraints                   | Description                                  |
| :---------------- | :------------ | :---------------------------- | :------------------------------------------- |
| `id`              | `UUID`        | `PRIMARY KEY`, `NOT NULL`     | Unique user ID, linked to Supabase Auth UID. |
| `email`           | `TEXT`        | `UNIQUE`, `NOT NULL`          | User's email address.                        |
| `full_name`       | `TEXT`        |                               | User's full name.                            |
| `username`        | `TEXT`        | `UNIQUE`                      | User's chosen username.                      |
| `avatar_url`      | `TEXT`        |                               | URL to the user's profile picture.           |
| `bio`             | `TEXT`        |                               | Short user bio.                              |
| `created_at`      | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()`   | Timestamp of account creation.               |
| `updated_at`      | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()`   | Timestamp of last profile update.            |
| `last_login`      | `TIMESTAMPTZ` |                               | Timestamp of last login.                     |

**RLS Policy:**
*   **View:** Users can view their own profile (`id = auth.uid()`).
*   **Update:** Users can update their own profile (`id = auth.uid()`).

### 2.2. `profiles`

An extension table for `users` to store additional, less frequently accessed profile data.

| Column Name          | Data Type     | Constraints                 | Description                                        |
| :------------------- | :------------ | :-------------------------- | :------------------------------------------------- |
| `user_id`            | `UUID`        | `PRIMARY KEY`, `REFERENCES users(id)` | Foreign key linking to `users` table. Ensures 1:1 relationship. <sup>[[5]](https://dba.stackexchange.com/questions/140349/how-to-enforce-11-relationship-in-postgresql)</sup> |
| `preferred_style`    | `JSONB`       |                             | User's defined style preferences (e.g., JSON object). |
| `measurements`       | `JSONB`       |                             | User's body measurements (if provided).            |
| `onboarding_skipped` | `BOOLEAN`     | `DEFAULT FALSE`             | Flag indicating if the user skipped onboarding.    |
| `created_at`         | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()` | Timestamp of profile creation.                     |
| `updated_at`         | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()` | Timestamp of last profile update.                  |

**RLS Policy:**
*   **View:** Users can view their own extended profile (`user_id = auth.uid()`).
*   **Update:** Users can update their own extended profile (`user_id = auth.uid()`).

### 2.3. `clothing_items`

Stores individual clothing items added by users to their digital wardrobe.

| Column Name         | Data Type     | Constraints                   | Description                                         |
| :------------------ | :------------ | :---------------------------- | :-------------------------------------------------- |
| `id`                | `UUID`        | `PRIMARY KEY`, `NOT NULL`     | Unique item ID.                                     |
| `user_id`           | `UUID`        | `NOT NULL`, `REFERENCES users(id)` | Owner of the item.                             |
| `name`              | `TEXT`        | `NOT NULL`                    | Name/label for the item (e.g., "Blue Jeans").       |
| `category`          | `TEXT`        |                               | Category (e.g., "Top", "Bottom", "Shoes").          |
| `color`             | `TEXT`        |                               | Main color of the item.                             |
| `pattern`           | `TEXT`        |                               | Pattern (e.g., "Striped", "Polka Dot").             |
| `brand`             | `TEXT`        |                               | Brand name.                                         |
| `purchase_date`     | `DATE`        |                               | Date the item was purchased.                        |
| `price`             | `NUMERIC`     |                               | Purchase price.                                     |
| `currency`          | `TEXT`        | `DEFAULT 'USD'`               | Currency code for the price.                        |
| `image_url`         | `TEXT`        |                               | URL to the item's primary image. <sup>[[6]](https://supabase.com/docs/guides/storage)</sup> |
| `notes`             | `TEXT`        |                               | User's personal notes about the item.               |
| `tags`              | `TEXT[]`      |                               | Array of user-defined tags (e.g., `["casual", "summer"]`). |
| `ai_tags`           | `JSONB`       |                               | Tags generated by AI analysis (e.g., JSON object).  |
| `last_worn_date`    | `DATE`        |                               | Date the item was last worn (for wardrobe review).  |
| `is_favorite`       | `BOOLEAN`     | `DEFAULT FALSE`               | Flag for favoriting items.                          |
| `created_at`        | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()`   | Timestamp of item creation.                         |
| `updated_at`        | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()`   | Timestamp of last item update.                      |

**RLS Policy:**
*   **View:** Users can view only their own items (`user_id = auth.uid()`).
*   **Insert:** Users can add items to their own wardrobe (`user_id = auth.uid()`).
*   **Update:** Users can update their own items (`user_id = auth.uid()`).
*   **Delete:** Users can delete their own items (`user_id = auth.uid()`).

**Indexes:**
*   `(user_id)` (Implied by FK/RLS)
*   `(category)`
*   `USING GIN (tags)`
*   `USING GIN (ai_tags)` (For efficient filtering on AI tags) <sup>[[7]](https://www.postgresql.org/docs/current/datatype-json.html#JSON-INDEXING)</sup>

### 2.4. `combinations`

Stores user-created outfit combinations.

| Column Name         | Data Type     | Constraints                   | Description                                         |
| :------------------ | :------------ | :---------------------------- | :-------------------------------------------------- |
| `id`                | `UUID`        | `PRIMARY KEY`, `NOT NULL`     | Unique combination ID.                              |
| `user_id`           | `UUID`        | `NOT NULL`, `REFERENCES users(id)` | Owner of the combination.                      |
| `name`              | `TEXT`        | `NOT NULL`                    | Name for the combination (e.g., "Casual Friday").   |
| `cover_image_url`   | `TEXT`        |                               | URL to the combination's cover image.               |
| `description`       | `TEXT`        |                               | User's description of the combination.              |
| `is_public`         | `BOOLEAN`     | `DEFAULT FALSE`               | Flag indicating if the combination is public.       |
| `likes_count`       | `INTEGER`     | `DEFAULT 0`                   | Cached count of likes.                              |
| `created_at`        | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()`   | Timestamp of combination creation.                  |
| `updated_at`        | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()`   | Timestamp of last combination update.               |

**RLS Policy:**
*   **View:** Users can view their own combinations or public ones (`user_id = auth.uid() OR is_public = true`). <sup>[[8]](https://supabase.com/docs/guides/auth/row-level-security)</sup>
    ```sql
    CREATE POLICY "Public combinations readable"
    ON combinations
    FOR SELECT
    USING (
      user_id = auth.uid() OR is_public = true
    );
    ```
*   **Insert:** Users can create combinations (`user_id = auth.uid()`).
*   **Update:** Users can update their own combinations (`user_id = auth.uid()`).
*   **Delete:** Users can delete their own combinations (`user_id = auth.uid()`).

**Indexes:**
*   `(user_id)`
*   `(is_public)`

### 2.5. `combination_items`

A junction table to link `clothing_items` to `combinations`, allowing many-to-many relationships.

| Column Name         | Data Type     | Constraints                   | Description                                         |
| :------------------ | :------------ | :---------------------------- | :-------------------------------------------------- |
| `combination_id`    | `UUID`        | `NOT NULL`, `REFERENCES combinations(id)` | Link to the combination.                   |
| `clothing_item_id`  | `UUID`        | `NOT NULL`, `REFERENCES clothing_items(id)` | Link to the clothing item.                 |
| `position`          | `INTEGER`     |                               | Optional order of items within the combination.     |

**RLS Policy:**
*   **View/Insert/Update/Delete:** Access is controlled through the parent `combinations` table's RLS policies. If a user can access a combination, they can manage its items.

### 2.6. `likes`

Tracks likes on public content (e.g., combinations).

| Column Name         | Data Type     | Constraints                   | Description                                         |
| :------------------ | :------------ | :---------------------------- | :-------------------------------------------------- |
| `id`                | `UUID`        | `PRIMARY KEY`, `NOT NULL`     | Unique like ID.                                     |
| `user_id`           | `UUID`        | `NOT NULL`, `REFERENCES users(id)` | User who liked the content.                    |
| `combination_id`    | `UUID`        | `REFERENCES combinations(id)` | The combination that was liked (nullable for future expansion). |
| `created_at`        | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()`   | Timestamp of the like.                              |

**RLS Policy:**
*   **View:** Users can see their own likes (`user_id = auth.uid()`). Public content likes might be viewable by content owners.
*   **Insert:** Users can like content (`user_id = auth.uid()`). Prevent duplicates via unique constraint.
*   **Delete:** Users can unlike content (`user_id = auth.uid()`).
*   **Unique Constraint:** `(user_id, combination_id)` to prevent a user from liking the same combination multiple times.

**Indexes:**
*   `(combination_id)`

### 2.7. `comments`

Stores comments on public content (e.g., combinations).

| Column Name         | Data Type     | Constraints                   | Description                                         |
| :------------------ | :------------ | :---------------------------- | :-------------------------------------------------- |
| `id`                | `UUID`        | `PRIMARY KEY`, `NOT NULL`     | Unique comment ID.                                  |
| `user_id`           | `UUID`        | `NOT NULL`, `REFERENCES users(id)` | Author of the comment.                         |
| `combination_id`    | `UUID`        | `NOT NULL`, `REFERENCES combinations(id) ON DELETE CASCADE` | The combination being commented on.            |
| `content`           | `TEXT`        | `NOT NULL`                    | The text of the comment.                            |
| `created_at`        | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()`   | Timestamp of comment creation.                      |
| `updated_at`        | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()`   | Timestamp of last comment update.                   |

**RLS Policy:**
*   **View:** Users can view comments on combinations they can see (their own or public).
*   **Insert:** Users can comment on combinations they can see.
*   **Update/Delete:** Users can update/delete their own comments (`user_id = auth.uid()`).

### 2.8. `follows`

Tracks user follow relationships.

| Column Name         | Data Type     | Constraints                   | Description                                         |
| :------------------ | :------------ | :---------------------------- | :-------------------------------------------------- |
| `follower_id`       | `UUID`        | `NOT NULL`, `REFERENCES users(id)` | The user doing the following.                  |
| `following_id`      | `UUID`        | `NOT NULL`, `REFERENCES users(id)` | The user being followed.                       |
| `created_at`        | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()`   | Timestamp of follow creation.                       |

**RLS Policy:**
*   **View:** Users can see who they follow and who follows them.
*   **Insert:** Users can follow other users.
*   **Delete:** Users can unfollow users they are following.

**Unique Constraint:** `(follower_id, following_id)` to prevent duplicate follows.

**Indexes:**
*   `(follower_id)`
*   `(following_id)`

### 2.9. `notifications`

Stores in-app notifications for users, often populated by Supabase Realtime triggers or backend jobs.

| Column Name         | Data Type     | Constraints                   | Description                                         |
| :------------------ | :------------ | :---------------------------- | :-------------------------------------------------- |
| `id`                | `UUID`        | `PRIMARY KEY`, `NOT NULL`     | Unique notification ID.                             |
| `user_id`           | `UUID`        | `NOT NULL`, `REFERENCES users(id)` | Recipient of the notification.                 |
| `type`              | `TEXT`        | `NOT NULL`                    | Type of notification (e.g., "like", "comment", "follow"). |
| `related_user_id`   | `UUID`        | `REFERENCES users(id)`        | User related to the notification (e.g., who liked it). |
| `related_combination_id` | `UUID`   | `REFERENCES combinations(id)` | Combination related to the notification.            |
| `message`           | `TEXT`        |                               | Notification message content.                       |
| `is_read`           | `BOOLEAN`     | `DEFAULT FALSE`               | Flag indicating if the notification has been read.  |
| `created_at`        | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()`   | Timestamp of notification creation.                 |

**RLS Policy:**
*   **View:** Users can view only their own notifications (`user_id = auth.uid()`).
*   **Update:** Users can mark their own notifications as read (`user_id = auth.uid()`).
*   **Delete:** Users can delete their own notifications (`user_id = auth.uid()`).

**Indexes:**
*   `(user_id, is_read)`
*   `(user_id, created_at)`

### 2.10. `swap_listings` (Ikinci El Takas Platformu)

Stores items listed by users for sale or swap in the marketplace.

| Column Name         | Data Type     | Constraints                   | Description                                         |
| :------------------ | :------------ | :---------------------------- | :-------------------------------------------------- |
| `id`                | `UUID`        | `PRIMARY KEY`, `NOT NULL`     | Unique listing ID.                                  |
| `user_id`           | `UUID`        | `NOT NULL`, `REFERENCES users(id)` | Seller/Owner of the listing.                   |
| `clothing_item_id`  | `UUID`        | `NOT NULL`, `REFERENCES clothing_items(id)` | The item being listed.                     |
| `title`             | `TEXT`        | `NOT NULL`                    | Title for the listing.                              |
| `description`       | `TEXT`        |                               | Detailed description of the item.                   |
| `price`             | `NUMERIC`     |                               | Asking price (if for sale).                         |
| `currency`          | `TEXT`        | `DEFAULT 'USD'`               | Currency for the price.                             |
| `is_for_swap`       | `BOOLEAN`     | `DEFAULT FALSE`               | Flag indicating if the item is for swap.            |
| `is_for_sale`       | `BOOLEAN`     | `DEFAULT FALSE`               | Flag indicating if the item is for sale.            |
| `condition`         | `TEXT`        |                               | Condition of the item (e.g., "New", "Like New").    |
| `images_urls`       | `TEXT[]`      |                               | Array of URLs to listing images.                    |
| `status`            | `TEXT`        | `DEFAULT 'active'`            | Status (e.g., "active", "sold", "swapped", "draft", "deleted"). |
| `deleted_at`        | `TIMESTAMPTZ` |                               | Timestamp of soft deletion (for archive/analysis).  |
| `likes_count`       | `INTEGER`     | `DEFAULT 0`                   | Cached count of likes on the listing.               |
| `created_at`        | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()`   | Timestamp of listing creation.                      |
| `updated_at`        | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()`   | Timestamp of last listing update.                   |

**RLS Policy:**
*   **View:** Users can view their own listings (`user_id = auth.uid()`). Active listings are viewable by all.
*   **Insert:** Users can create listings for their own items (`user_id = auth.uid()`).
*   **Update:** Users can update their own listings (`user_id = auth.uid()`).
*   **Delete:** Users can soft-delete their own listings (`user_id = auth.uid()`).

**Indexes:**
*   `(status, is_for_sale, is_for_swap)`
*   `(user_id)`

## 3. AI & Personalization Tables

### 3.1. `ai_profiles`

Stores the AI-generated, personalized style profile for each user.

| Column Name         | Data Type     | Constraints                   | Description                                         |
| :------------------ | :------------ | :---------------------------- | :-------------------------------------------------- |
| `user_id`           | `UUID`        | `PRIMARY KEY`, `REFERENCES users(id)` | Links to the user. Ensures 1:1 relationship. <sup>[[5]](https://dba.stackexchange.com/questions/140349/how-to-enforce-11-relationship-in-postgresql)</sup> |
| `style_vector`      | `VECTOR(128)` |                               | Numerical representation of the user's style for similarity searches. |
| `preference_scores` | `JSONB`       |                               | Detailed scores for preferences (e.g., `{"minimalism": 0.8, "colorfulness": 0.3}`). |
| `last_updated`      | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()`   | Timestamp of last profile update by AI.             |

**RLS Policy:**
*   **View/Update:** Users can view and update their own AI profile (`user_id = auth.uid()`).
    ```sql
    CREATE POLICY "Only owner can access their AI profile"
    ON ai_profiles
    FOR ALL
    USING (user_id = auth.uid());
    ```

**Indexes:**
*   `USING ivfflat (style_vector vector_cosine_ops)` (For efficient ANN searches) <sup>[[9]](https://supabase.com/docs/guides/database/extensions/pgvector)</sup>

### 3.2. `ai_clothing_embeddings`

Stores AI-generated vector embeddings for clothing items, used for similarity matching.

| Column Name         | Data Type     | Constraints                   | Description                                         |
| :------------------ | :------------ | :---------------------------- | :-------------------------------------------------- |
| `clothing_item_id`  | `UUID`        | `PRIMARY KEY`, `REFERENCES clothing_items(id) ON DELETE CASCADE` | Links to the clothing item.            |
| `embedding`         | `VECTOR(256)` | `NOT NULL`                    | Vector representation of the item's features.       |
| `generated_at`      | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()`   | Timestamp of embedding generation.                  |

**RLS Policy:**
*   **View:** Access is controlled through the parent `clothing_items` table's RLS policies.

**Indexes:**
*   `USING ivfflat (embedding vector_cosine_ops)` (For efficient ANN searches) <sup>[[9]](https://supabase.com/docs/guides/database/extensions/pgvector)</sup>

### 3.3. `styles`

Defines predefined style categories or tags.

| Column Name         | Data Type     | Constraints                   | Description                                         |
| :------------------ | :------------ | :---------------------------- | :-------------------------------------------------- |
| `id`                | `TEXT`        | `PRIMARY KEY`                 | Unique style identifier (e.g., "boho", "sporty").   |
| `name`              | `TEXT`        | `NOT NULL`                    | Human-readable name of the style.                   |
| `description`       | `TEXT`        |                               | A brief description of the style.                   |

### 3.4. `style_history`

Tracks the styles a user has interacted with or been recommended.

| Column Name         | Data Type     | Constraints                   | Description                                         |
| :------------------ | :------------ | :---------------------------- | :-------------------------------------------------- |
| `id`                | `UUID`        | `PRIMARY KEY`, `NOT NULL`     | Unique history entry ID.                            |
| `user_id`           | `UUID`        | `NOT NULL`, `REFERENCES users(id)` | The user.                                      |
| `style_id`          | `TEXT`        | `NOT NULL`, `REFERENCES styles(id)` | The style interacted with.                     |
| `interaction_type`  | `TEXT`        | `NOT NULL`                    | Type of interaction (e.g., "viewed", "liked", "used_in_combination"). |
| `created_at`        | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()`   | Timestamp of the interaction.                       |

**RLS Policy:**
*   **View/Insert:** Users can view and add to their own style history (`user_id = auth.uid()`).
    ```sql
    CREATE POLICY "Users manage their own style history"
    ON style_history
    FOR ALL
    USING (user_id = auth.uid());
    ```

### 3.5. `ai_feedback`

Stores user feedback on AI-generated suggestions to improve the model.

| Column Name         | Data Type     | Constraints                   | Description                                         |
| :------------------ | :------------ | :---------------------------- | :-------------------------------------------------- |
| `id`                | `UUID`        | `PRIMARY KEY`, `NOT NULL`     | Unique feedback ID.                                 |
| `user_id`           | `UUID`        | `NOT NULL`, `REFERENCES users(id)` | The user providing feedback.                   |
| `suggestion_type`   | `TEXT`        | `NOT NULL`                    | Type of suggestion (e.g., "combination", "item").   |
| `suggestion_id`     | `UUID`        |                               | ID of the specific suggestion (e.g., combination ID). |
| `feedback_type`     | `TEXT`        | `NOT NULL`                    | Type of feedback (e.g., "like", "dislike", "confused", "not_my_style"). |
| `comment`           | `TEXT`        |                               | Optional textual feedback from the user.            |
| `created_at`        | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()`   | Timestamp of feedback submission.                   |

**RLS Policy:**
*   **View/Insert:** Users can view and submit their own feedback (`user_id = auth.uid()`).
    ```sql
    CREATE POLICY "Users manage their own AI feedback"
    ON ai_feedback
    FOR ALL
    USING (user_id = auth.uid());
    ```

## 4. Relationships (Foreign Keys)

Foreign Key relationships ensure data integrity. The following `ON DELETE` behaviors are applied:

*   **`CASCADE`**: Used for junction/dependent tables (e.g., `combination_items`, `ai_clothing_embeddings`) to automatically remove related data when the parent is deleted.
*   **Default (RESTRICT/NO ACTION)**: Used for core ownership links (e.g., `clothing_items.user_id`, `combinations.user_id`) to prevent accidental deletion of core user data.

*   `profiles.user_id` → `users.id`
*   `clothing_items.user_id` → `users.id`
*   `combinations.user_id` → `users.id`
*   `combination_items.combination_id` → `combinations.id` (ON DELETE CASCADE)
*   `combination_items.clothing_item_id` → `clothing_items.id` (ON DELETE CASCADE)
*   `likes.user_id` → `users.id`
*   `likes.combination_id` → `combinations.id`
*   `comments.user_id` → `users.id`
*   `comments.combination_id` → `combinations.id` (ON DELETE CASCADE)
*   `follows.follower_id` → `users.id`
*   `follows.following_id` → `users.id`
*   `notifications.user_id` → `users.id`
*   `notifications.related_user_id` → `users.id`
*   `notifications.related_combination_id` → `combinations.id`
*   `swap_listings.user_id` → `users.id`
*   `swap_listings.clothing_item_id` → `clothing_items.id`
*   `ai_profiles.user_id` → `users.id`
*   `ai_clothing_embeddings.clothing_item_id` → `clothing_items.id` (ON DELETE CASCADE)
*   `style_history.user_id` → `users.id`
*   `style_history.style_id` → `styles.id`
*   `ai_feedback.user_id` → `users.id`

## 5. Row Level Security (RLS) Summary

RLS policies are crucial for ensuring users can only access their own data. The policies outlined above for each table enforce this. Key principles include:

*   **User Isolation:** Core user data (`users`, `profiles`, `clothing_items`, `combinations`, `notifications`, `swap_listings`) is isolated using `user_id = auth.uid()`.
*   **Granular Control:** Policies are defined for `SELECT`, `INSERT`, `UPDATE`, and `DELETE` operations as appropriate for each table's purpose.
*   **Public Content:** Tables or rows representing public content (e.g., public `combinations`, active `swap_listings`) will have specific policies allowing broader read access.
*   **AI Data Isolation:** AI-related tables (`ai_profiles`, `style_history`, `ai_feedback`) also enforce strict user-level access.
*   **Interaction with Application Layers:** As detailed in `API_INTEGRATION.md` and `BACKEND_SERVICES.md`, the Flutter app and FastAPI backend authenticate with Supabase using JWTs. These JWTs contain the user's `uid`, which Supabase makes available within RLS policy expressions as `auth.uid()`. Therefore, every database query made by these layers (whether directly via Supabase client libraries or indirectly via the FastAPI backend calling Supabase REST/DB) is subject to these RLS checks, ensuring that a user can only access data they are permitted to by these policies.

## 6. Indexes (Recommended)

To optimize query performance, consider adding indexes on frequently queried columns:

*   `clothing_items(user_id)` (Implied by FK/RLS)
*   `clothing_items(category)`
*   `clothing_items(tags)` (Gin index for array)
*   `clothing_items(ai_tags)` (Gin index for JSONB filtering)
*   `combinations(user_id)`
*   `combinations(is_public)`
*   `likes(user_id, combination_id)` (Covering index)
*   `likes(combination_id)`
*   `comments(combination_id, created_at)`
*   `follows(follower_id)`
*   `follows(following_id)`
*   `notifications(user_id, is_read)`
*   `notifications(user_id, created_at)`
*   `swap_listings(status, is_for_sale, is_for_swap)`
*   `swap_listings(user_id)`
*   `ai_profiles USING ivfflat (style_vector vector_cosine_ops)`
*   `ai_clothing_embeddings USING ivfflat (embedding vector_cosine_ops)`
*   `style_history(user_id, style_id, created_at)`
*   `ai_feedback(user_id, suggestion_type, created_at)`

