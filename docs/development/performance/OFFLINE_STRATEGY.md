# Aura Offline Strategy Guide

This document outlines the offline-first strategy for the Aura Flutter application. It details the caching mechanisms, data persistence, and synchronization processes to ensure a seamless user experience even when network connectivity is intermittent or unavailable.

It is designed to align with the architectural principles in `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf` and complements the state management approach defined in `STATE_MANAGEMENT.md`. It also incorporates advanced resilience strategies like "Backup Plans" as outlined in `AURA PROJESİ - NİHAİ TASARIM VE STRATEJİ DÖKÜMANI (V3.0 - Tam Metin).docx`.

## 1. Overview

An offline-first approach ensures that users can interact with core features of Aura (e.g., viewing their wardrobe, creating combinations) even without an internet connection. This strategy focuses on:

*   **Data Availability:** Storing essential user data locally on the device.
*   **Local Operations:** Allowing users to perform key actions (viewing, basic modifications) while offline.
*   **Seamless Synchronization:** Automatically syncing local changes with the backend (Supabase) when connectivity is restored.
*   **Graceful Degradation:** Providing clear feedback to the user about the offline state and which features are limited.

This guide aligns with the architectural principles outlined in `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf` and complements the state management approach defined in `STATE_MANAGEMENT.md`.

## 2. Core Principles

*   **User-Centric:** The user should be able to perform the most important tasks without noticing (or being significantly hindered by) the offline state.
*   **Data Consistency:** Ensure that data modifications made offline are reliably propagated to the server and conflicts are handled gracefully.
*   **Performance:** Local data access should be fast. Avoid blocking the UI thread during sync operations.
*   **Battery Efficiency:** Background sync processes should be optimized to minimize battery drain.
*   **Resilience & Backup Plans:** Acknowledging that offline scenarios can be complex, this strategy incorporates the principle of having "Backup Plans" for critical operations, similar to the "Kill‑Switch" concept for failing services. For instance, if an automatic sync fails repeatedly, a manual retry or user-mediated conflict resolution ("Backup Plan") should be available. (See `AURA PROJESİ - NİHAİ TASARIM VE STRATEJİ DÖKÜMANI (V3.0 - Tam Metin).docx`, "Acil Durum 'Kill‑Switch'" and "Backup Plan" section).

## 3. Data Storage & Caching Strategy

### 3.1. Local Data Persistence

To store data locally, a robust persistence solution is required. Based on the analysis in `Offline-first ve Cache Stratejileri .pdf` and the architecture guide, the following approach is recommended:

*   **Primary Local Store:** Use a local database for structured data persistence. `drift` (formerly `moor`) or `floor` (SQLite wrappers for Dart) are good choices for Flutter, offering type safety and reactive queries. `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf` pg 27 mentions using SQLite.
*   **Alternative/Complement:** For simple key-value storage (e.g., user preferences, access tokens), use `shared_preferences`. For temporary caching, Riverpod's in-memory cache (`.autoDispose`) is sufficient, but for persistent caching, local database or file system is needed.

### 3.2. Caching Layers

Implement a multi-layered caching strategy for optimal performance and data availability:

1.  **Memory Cache (Riverpod):** Riverpod's built-in caching (`AsyncNotifierProvider` with `.autoDispose` as default, `@Riverpod(keepAlive: true)` for global data) acts as the first and fastest layer. Data fetched from the network or database is held here for quick access. See `STATE_MANAGEMENT.md`.
2.  **Persistent Local Store (Database/File):** The second layer is the local database (e.g., SQLite via `drift`/`floor`). Data fetched from the network is saved here. This ensures data survives app restarts and is available offline.
3.  **Network (Supabase):** The source of truth. Data is fetched from and synced back to Supabase.

### 3.3. Data Models for Local Storage

*   Define local data models (DAOs/Entities for `drift`/`floor`) that mirror or adapt the structure of data fetched from Supabase (defined in `DATABASE_SCHEMA.md`). This might involve flattening nested structures for efficient local storage.
*   Include metadata fields in local models:
    *   `last_synced_at`: Timestamp of the last successful sync with the server.
    *   `is_dirty`: A flag indicating if the local record has been modified and needs to be synced.
    *   `sync_status`: An enum (e.g., `synced`, `pending_sync`, `syncing`, `sync_failed`) to track the sync state of an item.

## 4. Offline Operations

### 4.1. Read Operations

*   **Strategy:** Always attempt to read data from the local persistent store first.
*   **Implementation:**
    1.  The application's `Repository` layer (as defined in `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf`) first queries the local database.
    2.  If data exists locally, it's returned to the UI immediately.
    3.  Simultaneously (or based on a staleness check), a background task attempts to fetch fresh data from Supabase.
    4.  If fresh data is fetched, the local database is updated, and the UI is notified (e.g., via Riverpod) to refresh with the new data.

### 4.2. Write/Update/Delete Operations

*   **Strategy:** Allow these operations to be performed on the local database immediately, marking them as 'dirty' for later synchronization.
*   **Implementation:**
    1.  User performs an action (e.g., adds a clothing item, likes a combination).
    2.  The corresponding `Repository` method updates the local database immediately.
        *   For Create: Insert the new record with `is_dirty = true`.
        *   For Update: Update the local record and set `is_dirty = true`.
        *   For Delete: Mark the local record for deletion (soft delete or set `is_dirty = true` with a delete flag) or perform a hard delete locally.
    3.  The UI is updated instantly based on the local change, providing a responsive experience.
    4.  The change is queued for synchronization (see section 5).

## 5. Synchronization (Sync) Mechanism

### 5.1. Sync Triggering

*   **Connectivity Restoration:** Use the `connectivity_plus` package to listen for network status changes. When the device goes from offline to online, trigger a sync.
*   **Periodic Sync:** Schedule periodic background sync attempts using `workmanager` (Android) or `background_fetch` (iOS) to handle cases where the app wasn't active during connectivity restoration.
*   **Manual Sync:** Provide a user-initiated "Sync Now" button in settings or when errors occur.

### 5.2. Sync Process

*   **Offline Request Queue:** Implement a queue to manage pending operations (create, update, delete). `Offline-first ve Cache Stratejileri .pdf` pg 5 mentions `offlineRequestQueue`. This queue can be a simple table in the local database.
    *   Each queue item stores: operation type, data involved, timestamp, retry count, status.
*   **Sync Worker:**
    1.  When a sync is triggered, the worker processes the offline request queue.
    2.  It picks items from the queue (potentially prioritizing by timestamp or type) and attempts to execute the corresponding API call against Supabase (via `dio` or Supabase client).
    3.  **Success:** If the API call succeeds, remove the item from the queue and update the local database record's `is_dirty` flag to `false` and `sync_status` to `synced`.
    4.  **Failure:** If the API call fails (e.g., due to server error, conflict, or continued offline state):
        *   Increment the retry count for the queue item.
        *   Update the local record's `sync_status` to `sync_failed`.
        *   If retry count exceeds a threshold, mark the item for manual review or discard. *(This is where the "Backup Plan" kicks in - see section 5.4)*.
        *   Implement exponential backoff for retries to avoid overwhelming the server or battery.
*   **Conflict Resolution:** Define strategies for handling conflicts (e.g., if an item was modified both locally and on the server).
    *   **Simple Strategy (Recommended for MVP):** Last Write Wins (LWW) based on a timestamp. The change with the latest timestamp (either local modification time or server update time) is kept.
    *   **Advanced Strategy:** Implement more sophisticated logic based on data type and user intent.

### 5.3. Sync Workflow Diagram

Below is a simplified representation of the core sync workflow:

```
+----------------+       +------------------+       +----------------+
| Local Database | ----> | Offline Queue DB | ----> | Sync Worker    |
+----------------+       +------------------+       +-------+--------+
                                                           |
                                                           v
                                                  +-----------------+
                                                  | Supabase Server |
                                                  +-----------------+
                                                           |
                  +----------------------------------------+
                  |
         +--------v--------+       +---------------------+
         | Success: Update | <---  | API Call (via dio)  |
         | Local DB & UI   |       +---------------------+
         +-----------------+                |
                                            |
                              +-------------v--------------+
                              | Failure: Update Queue Item |
                              | (Retry Count, Status)      |
                              +----------------------------+
```

### 5.4. Advanced Scenarios: Schema Evolution & Backup Plans

*   **Schema Evolution:**
    When the Supabase database schema evolves (e.g., a new column is added to `clothing_items`), offline queue items created with the old schema might conflict during sync.
    *   **Strategy:**
        1.  Include a `schema_version` field in both your local database records and offline queue items.
        2.  Define a schema version for your Supabase tables (this can be a simple integer managed by you).
        3.  When the app starts or detects a schema change, compare the local `schema_version` with the latest known version.
        4.  If they differ, run a migration script that updates local data and potentially transforms offline queue items to be compatible with the new schema before attempting sync.
        5.  The `Sync Worker` should be aware of different schema versions and handle queue items accordingly, potentially discarding very old incompatible items if migration is not feasible.

*   **Backup Plans for Persistent Failures:**
    In line with the resilience principles of `AURA PROJESİ - NİHAİ TASARIM VE STRATEJİ DÖKÜMANI (V3.0 - Tam Metin).docx`, persistent sync failures require a fallback.
    *   **Scenario:** An item in the sync queue fails to sync after multiple retries (e.g., due to a permanent server error, a conflict that LWW cannot resolve, or a corrupted local record).
    *   **Backup Plan Implementation:**
        1.  **Mark for Manual Intervention:** After a high retry threshold, the item's `sync_status` is set to `requires_manual_intervention`.
        2.  **Notify User (Optional):** The UI can check for items with this status and inform the user (e.g., a banner on the relevant screen: "Some changes couldn't sync. Tap to resolve.").
        3.  **Provide Resolution Options:** A dedicated screen or dialog can present the failed item, the error reason (if available), and options:
            *   **Retry:** Force another sync attempt.
            *   **Discard:** Discard the local change.
            *   **Edit & Retry:** Allow the user to view/edit the item before retrying (advanced).
            *   **View Server Version:** If it's an update conflict, allow viewing the current server version.
        4.  **User Action Completes Cycle:** The user's choice resolves the item's status (e.g., retrying moves it back to `pending_sync`, discarding removes it from the queue and potentially reverts the local change).

## 6. Network Awareness

*   **Connectivity Monitoring:** Use `connectivity_plus` to determine the current network status (none, WiFi, mobile data).
*   **UI Adaptations:**
    *   **Offline Banner:** Display a non-intrusive banner or icon indicating offline mode.
    *   **Feature Disabling:** Disable or visually indicate features that strictly require an online connection (e.g., real-time chat, searching for new items to swap).
    *   **Action Feedback:** When a user performs an action that *requires* an online connection while offline, show a clear message (e.g., "This action requires an internet connection. Please connect and try again.").

## 7. Testing Offline Scenarios

*   **Simulate Offline:** Use device emulators/simulators or tools like `network_link_conditioner` (macOS) to simulate various network conditions, including complete offline states.
*   **Unit/Integration Tests:** Write tests for repository methods to ensure they correctly read from/write to the local database and handle the sync queue logic.
*   **UI Tests:** Test critical user flows (viewing wardrobe, adding an item) under offline conditions to ensure the UI behaves as expected.

## 8. Security Considerations

*   **Local Data Encryption:** Sensitive user data stored locally (if any beyond standard app data) should be encrypted at rest. Flutter provides platform-level security features, but additional encryption libraries can be used if needed.
*   **Authentication Tokens:** Securely store authentication tokens (JWT from Supabase) using secure storage mechanisms (e.g., `flutter_secure_storage`).

## 9. Performance Considerations

*   **Database Indexing:** Properly index local database tables on frequently queried columns (e.g., `user_id`, `category` for clothing items) to ensure fast local reads.
*   **Batching Sync Requests:** Where possible, batch multiple sync operations (e.g., uploading several new items) into a single API request to reduce network overhead.
*   **Efficient Sync Algorithms:** Optimize the logic for processing the sync queue to minimize CPU and battery usage.

