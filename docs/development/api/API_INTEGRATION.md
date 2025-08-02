# Aura API Integration Guide

This document describes how the Aura Flutter application communicates with its backend services. It covers the setup, usage, and best practices for the three main API communication methods: **GraphQL (Supabase)**, **REST (Supabase & FastAPI)**, and **WebSocket (Supabase Realtime)**.

It aligns with the architectural principles in `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf` and the security model defined in `DATABASE_SCHEMA.md`.

## 1. Overview of API Strategies

Based on the application's needs, a **Polyglot API** approach is used:

*   **GraphQL (Supabase):** For complex, nested data reads (e.g., fetching a user's social feed with associated comments and likes). It's efficient for retrieving multiple related resources in a single request. <sup>[[1]](https://supabase.com/docs/guides/api) [[2]](https://blog.logrocket.com/graphql-vs-rest-apis/)</sup>
*   **REST (Supabase & FastAPI):** For simple actions, commands, and write operations (e.g., updating user settings, adding a clothing item, liking a post). It's straightforward and well-suited for CRUD operations and triggering specific backend actions. <sup>[[1]](https://supabase.com/docs/guides/api) [[2]](https://blog.logrocket.com/graphql-vs-rest-apis/)</sup>
*   **WebSocket (Supabase Realtime):** For real-time updates (e.g., receiving instant notifications, seeing live chat messages, getting updates when a friend shares a new combination). It maintains a persistent connection for instant data push. <sup>[[3]](https://supabase.com/docs/guides/realtime) [[4]](https://supabase.com/features/realtime-broadcast)</sup>

## 2. Supabase Client Setup

Aura uses the official `supabase_flutter` package to interact with Supabase services (Auth, Database, Storage, Realtime, Functions). A singleton `SupabaseClient` instance is initialized at the app's startup.

### 2.1. Initialization

Initialization typically happens in `lib/src/core/presentation/bootstrap/supabase_client_setup.dart` (or a similar location).

```dart
// lib/src/core/presentation/bootstrap/supabase_client_setup.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/shared/constants.dart'; // Contains SUPABASE_URL and SUPABASE_ANON_KEY

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
    // Optional: Configure Realtime
    realtimeClientOptions: const RealtimeClientOptions(
      // logger: ... // For debugging
    ),
  );
}

// Access the client anywhere in the app
SupabaseClient get supabaseClient => Supabase.instance.client;
```

### 2.2. Authentication Token Handling

The `supabase_flutter` SDK automatically manages the user's JWT token obtained during authentication (`supabaseClient.auth.signInWith...`). This token is crucial for securing data access.

*   **Automatic Attachment:** The SDK automatically attaches the JWT token to the `Authorization: Bearer <token>` header of all subsequent requests made to Supabase services (Database via REST/GraphQL, Storage, Functions).
*   **Token Refresh:** It also handles automatic token refreshing using refresh tokens, ensuring a seamless user experience. <sup>[[5]](https://supabase.com/docs/guides/auth)</sup>

### 2.3. Core Concepts

*   **Client Instance:** `Supabase.instance.client` is the main entry point for interacting with all Supabase services.
*   **Database Access:** `supabaseClient.from('table_name')` is used to interact with database tables via REST or chained for GraphQL.
*   **Storage Access:** `supabaseClient.storage` is used for uploading and downloading files from Supabase Storage.
*   **Realtime Access:** `supabaseClient.channel('channel_name')` is used to create and manage real-time subscriptions.

### 2.4. Security & Row Level Security (RLS) Integration

Aura's data security heavily relies on **Supabase Row Level Security (RLS)**, which is meticulously defined in `DATABASE_SCHEMA.md`.

*   **JWT Token Role:** The JWT token obtained during user login (`supabaseClient.auth.session?.accessToken`) contains the authenticated user's unique ID (`uid`).
*   **Automatic Enforcement:** Crucially, the `supabase_flutter` SDK automatically includes this JWT token in the `Authorization: Bearer <token>` header for *every* API request (REST, GraphQL, Realtime).
*   **RLS Activation:** When Supabase receives a request, it extracts the `uid` from the JWT and makes it available within RLS policies as `auth.uid()`. Every row-level policy defined in `DATABASE_SCHEMA.md` (e.g., `CREATE POLICY "Owner can view items" ON clothing_items FOR SELECT USING (user_id = auth.uid());`) is automatically evaluated against this `auth.uid()`.
*   **Transparent Filtering:** This means that a simple query like `supabaseClient.from('clothing_items').select()` automatically translates to `SELECT * FROM clothing_items WHERE user_id = 'logged_in_user_uid'` at the database level, thanks to RLS. The developer doesn't need to manually add `user_id` filters for basic access control; RLS enforces it transparently for every data access point.
*   **Universal Application:** This security mechanism applies uniformly to all Supabase interactions: REST calls (`supabaseClient.from('table').select()`), GraphQL queries (`supabaseClient.from('table').select('nested(data)')`), and Realtime subscriptions (`channel.on(...)`). <sup>[[6]](https://supabase.com/docs/guides/auth/row-level-security)</sup>

## 3. GraphQL Integration (Supabase)

GraphQL is used to efficiently query complex data structures from Supabase.

### 3.1. Setup & Usage

*   **Via Supabase Client:** Use the `supabaseClient.from('table_name')` method and chain `.select()` with GraphQL-like syntax. The `supabase_flutter` package handles the underlying communication.
    ```dart
    // Example: Fetch a user's wardrobe items with nested category details
    final response = await supabaseClient
        .from('clothing_items')
        .select('id, name, category(name, icon_url), image_url, is_favorite');
    final List<dynamic> items = response;
    // Process items...
    ```
*   **Flexibility:** Allows fetching deeply nested related data in a single request, reducing the number of network calls.

### 3.2. When to Use GraphQL

*   Fetching a user's profile along with their latest 5 combinations and the items in each combination in a single request.
*   Loading a social feed where each post includes author details, comments, and like counts.
*   Any scenario where minimizing the number of network requests for fetching related data is crucial.

### 3.3. Caching

*   Caching is handled by Riverpod's in-memory cache (`AsyncNotifierProvider` with `.autoDispose` by default). For persistent caching, local database storage (`drift`/`floor`) as described in `OFFLINE_STRATEGY.md` should be used.

## 4. REST Integration

REST is used for simpler, action-oriented communication with both Supabase Functions/Edge Functions and the custom FastAPI backend.

### 4.1. Setup & Usage

*   **Supabase REST:** Use `supabaseClient.from('table_name')` methods like `.insert()`, `.update()`, `.delete()`.
    ```dart
    // Example: Add a new clothing item
    final newItem = {
      'name': 'Blue Jeans',
      'category': 'Bottom',
      'user_id': supabaseClient.auth.currentUser!.id // Explicitly include user_id for clarity, though RLS handles it
    };
    await supabaseClient.from('clothing_items').insert(newItem);

    // Example: Update user settings
    final updates = {'bio': 'Updated bio'};
    await supabaseClient.from('profiles').update(updates).eq('user_id', supabaseClient.auth.currentUser!.id);
    ```
*   **FastAPI REST:** Use a dedicated HTTP client like `dio` or `http` for custom API calls. JWT token must be manually attached.
    ```dart
    // Example using dio (configured elsewhere)
    import 'package:dio/dio.dart';
    import 'package:supabase_flutter/supabase_flutter.dart';

    Future<void> triggerAiAnalysis(String itemId) async {
      final dio = Dio(); // Assume configured with interceptors
      final token = Supabase.instance.client.auth.session?.accessToken;
      if (token != null) {
         dio.options.headers['Authorization'] = 'Bearer $token';
      }
      try {
        await dio.post('/api/v1/ai/analyze-clothing-item', data: {'clothing_item_id': itemId});
        // Handle success
      } on DioError catch (e) {
        // Handle error (e.g., check e.response for status code and details)
        rethrow;
      }
    }
    ```

### 4.2. When to Use REST

*   **Supabase REST:**
    *   Simple CRUD operations on database tables.
    *   Invoking Supabase Edge Functions.
    *   Uploading files to Supabase Storage (using specific Supabase Storage APIs, often wrapped by `supabase_flutter`).
*   **FastAPI REST:**
    *   Triggering complex backend logic or AI processing (e.g., `POST /analyze_clothing_item`).
    *   Updating user preferences that require server-side validation or processing.
    *   Any action that doesn't fit the data-fetching nature of GraphQL.

### 4.3. Error Handling

*   Use `try-catch` blocks around Supabase/`dio` calls.
*   Inspect error objects (e.g., `DioError`, Supabase error responses) for `response` (status code, data) and `error` details.
*   Implement retry logic for transient network errors if necessary.

## 5. WebSocket Integration (Supabase Realtime)

WebSocket is used for receiving real-time updates from Supabase.

### 5.1. Setup & Usage

Supabase's Realtime client is integrated via the `supabase_flutter` package. Setup usually happens during Supabase client initialization.

```dart
// Typically in your main Supabase client provider or bootstrap
// lib/src/core/presentation/bootstrap/supabase_client_setup.dart
import 'package:supabase_flutter/supabase_flutter.dart';

// Initialization (already shown in 2.1)
// ...
// Using Realtime
void setupRealtimeListener() {
  final client = Supabase.instance.client;
  final channel = client.channel('notifications_for_user_${client.auth.currentUser!.id}');

  channel
      .on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(
          event: 'INSERT', // Listen for new rows
          schema: 'public',
          table: 'notifications',
          filter: 'user_id=eq.${client.auth.currentUser!.id}', // Filter by user ID
        ),
      )
      .onPostgresChanges(
        event: 'INSERT',
        channelFilter: ChannelFilter(
          schema: 'public',
          table: 'notifications',
        ),
        callback: (payload) {
          // Payload contains the new data
          final newNotification = Notification.fromJson(payload.newRecord!);
          // Update state, e.g., using Riverpod
          // ref.read(notificationsProvider.notifier).add(newNotification);
        },
      )
      .subscribe();
}
```

### 5.2. When to Use WebSocket

*   Receiving instant notifications (e.g., "User X liked your combination").
*   Seeing real-time updates in a shared space (e.g., live chat, collaborative features if any).
*   Getting notified when data relevant to the user changes on the server (e.g., a friend shares a new combination, an item's availability in SwapMarket changes).

### 5.3. Best Practices

*   **Manage Subscriptions:** Subscribe when relevant (e.g., user navigates to a screen that needs real-time updates) and unsubscribe when not (e.g., user navigates away) to save resources. Use `channel.unsubscribe()`.
*   **Handle Reconnects:** The `supabase_flutter` client handles reconnection logic, but be aware of potential missed events during disconnects.
*   **Filter Efficiently:** Use channel filters (`ChannelFilter`) on the server side to only receive relevant updates, reducing client-side processing.

## 6. Choosing the Right API Strategy

| Scenario                                 | Recommended API | Reason                                                                 |
| :--------------------------------------- | :-------------- | :--------------------------------------------------------------------- |
| Fetching a user's profile + combinations | GraphQL         | Efficiently retrieves related, nested data in one request.             |
| Adding a new clothing item               | REST (Supabase) | Direct command to create a resource.                                   |
| Updating user settings                   | REST (Supabase) | Simple data update operation.                                          |
| Liking a combination                     | REST (Supabase) | Simple action, might involve a direct database update.                 |
| Receiving a new notification             | WebSocket       | Instant push of new data from server to client.                        |
| Seeing a friend's live activity          | WebSocket       | Real-time updates for a shared or dynamic resource.                    |
| Triggering AI Analysis (Backend)         | REST (FastAPI)  | Invokes complex server-side logic.                                     |
