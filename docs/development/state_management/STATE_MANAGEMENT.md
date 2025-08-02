# Aura State Management Guide

This document outlines the state management strategy for the Aura Flutter application, which is based on **Riverpod v2**. It details the specific providers to use, when to use them, and how to manage state lifecycle effectively.

## 1. Why Riverpod v2?

Riverpod v2 was chosen for the following reasons:

*   **Compile-time Safety:** Errors related to provider usage are caught at compile time, reducing runtime issues.
*   **Testability:** Providers and their logic are easily unit-testable.
*   **Scalability:** It handles complex state dependencies and asynchronous operations well.
*   **Readability & Maintainability:** The syntax is clear, and the separation of concerns (logic in Notifiers/Providers, UI in Widgets) improves code structure.
*   **Modern Features:** Riverpod v2 introduces code generation (`@riverpod`), `AsyncNotifier` for complex async state, and better integration with Flutter's dev tools.

## 2. Core Concepts and Provider Types

### 2.1. `Provider`

*   **Purpose:** To provide a read-only value or an injected service (like a repository instance) that does not change.
*   **When to Use:**
    *   Injecting dependencies (e.g., `WardrobeRepository`).
    *   Providing a constant value derived from other providers or static data.
*   **Example:**
    ```dart
    // Define the provider
    final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
      return SupabaseWardrobeRepository(ref.read(supabaseClientProvider));
    });

    // Use in a Notifier or Widget
    final myNotifierProvider = NotifierProvider<MyNotifier, MyState>((ref) {
      final repo = ref.read(wardrobeRepositoryProvider); // Inject dependency
      return MyNotifier(repo);
    });
    ```

### 2.2. `StateProvider`

*   **Purpose:** To manage simple, synchronous state that can be directly modified from the UI (e.g., a `bool` for a toggle, a `String` for a filter).
*   **When to Use:**
    *   Simple UI flags (like `isLoading` for a small section).
    *   Temporary filter values.
*   **Example:**
    ```dart
    final isGridViewProvider = StateProvider<bool>((ref) => true);

    // In Widget
    Switch(
      value: ref.watch(isGridViewProvider),
      onChanged: (value) => ref.read(isGridViewProvider.notifier).state = value,
    );
    ```

### 2.3. `StateNotifierProvider` / `AsyncNotifierProvider`

*   **Purpose:** To manage complex state and handle asynchronous operations (like fetching data, submitting forms). `AsyncNotifierProvider` is the preferred choice for state involving `Future`s or `Stream`s.
*   **When to Use:**
    *   Fetching and displaying lists of data (e.g., user's wardrobe items).
    *   Handling form submission logic.
    *   Managing state with loading, data, and error statuses (often using `AsyncValue`).
*   **`AsyncNotifier` Lifecycle:** `AsyncNotifier` is specifically designed for `AsyncValue` state. It provides built-in methods like `guard` and `stream` to simplify async operations.
*   **Example (`AsyncNotifierProvider`):**
    ```dart
    import 'package:riverpod_annotation/riverpod_annotation.dart';
    import 'package:aura/core/domain/entities/clothing_item.dart';
    import 'package:aura/core/domain/repositories/wardrobe_repository.dart';

    part 'wardrobe_notifier.g.dart'; // Generated file

    @riverpod
    class WardrobeNotifier extends _$WardrobeNotifier {
      @override
      Future<List<ClothingItem>> build() async {
        // This is the initial state load
        final repository = ref.read(wardrobeRepositoryProvider);
        return repository.getAllItems();
      }

      Future<void> refresh() async {
        // Manually refresh the state
        final repository = ref.read(wardrobeRepositoryProvider);
        state = const AsyncValue.loading(); // Show loading
        state = await AsyncValue.guard(() => repository.getAllItems());
      }

      Future<void> addItem(ClothingItem newItem) async {
        // Add item logic
        state = const AsyncValue.loading();
        try {
          final repository = ref.read(wardrobeRepositoryProvider);
          await repository.addItem(newItem);
          // Re-fetch the list to update UI
          await refresh(); 
        } catch (e, st) {
          state = AsyncValue.error(e, st); // Show error
        }
      }
    }

    // Usage in Widget
    // final asyncWardrobeItems = ref.watch(wardrobeNotifierProvider);
    // asyncWardrobeItems.when(
    //    (items) => ListView.builder(...),
    //   loading: () => CircularProgressIndicator(),
    //   error: (err, stack) => Text('Error: $err'),
    // );
    ```

### 2.4. `.autoDispose`

*   **Purpose:** Automatically disposes of the provider when it's no longer being listened to. This is the **default and recommended** behavior to prevent memory leaks and stale state.
*   **When to Use:** Almost always. Unless you have a specific reason for a provider to live globally.
*   **How to Apply:**
    *   For code-generated providers (`@riverpod`), `.autoDispose` is the default unless `@Riverpod(keepAlive: true)` is used.
    *   For manual providers, append `.autoDispose` to the provider type:
        ```dart
        final myAutoDisposeProvider = StateProvider.autoDispose<int>((ref) => 0);
        ```

### 2.5. `@Riverpod(keepAlive: true)`

*   **Purpose:** Keeps the provider alive even when no widgets are listening. Its state persists.
*   **When to Use:**
    *   **Global App State:** Authentication status, current user profile, theme preference.
    *   **State that should not be lost:** Shopping cart items (if applicable), critical persistent UI state.
*   **Example:**
    ```dart
    // In a file like `lib/core/presentation/providers/auth_state_provider.dart`
    import 'package:riverpod_annotation/riverpod_annotation.dart';
    import 'package:supabase_flutter/supabase_flutter.dart';

    part 'auth_state_provider.g.dart';

    @Riverpod(keepAlive: true) // Keep alive because auth state is global
    class AuthState extends _$AuthState {
      @override
      String? build() {
        // Initial state: check if user is already logged in
        return ref.read(supabaseClientProvider).auth.currentSession?.user.id;
      }

      void login(String email, String password) async {
        // ... login logic ...
        // Update state on success
        state = userId; // Assuming login is successful and userId is obtained
      }

      void logout() async {
        // ... logout logic ...
        state = null; // Clear state
      }
    }
    ```

## 3. Provider Comparison Table

This table summarizes the key characteristics of the main provider types to help in decision-making.

| Provider Type           | Use Case                          | Handles Async? | Default Dispose Strategy | Typical `@riverpod` Annotation |
|------------------------|-----------------------------------|----------------|--------------------------|-------------------------------|
| `Provider`             | Read-only dependencies            | ❌             | Manual                   | `@riverpod`                   |
| `StateProvider`        | Simple, synchronous UI state      | ❌             | `autoDispose`            | `@riverpod`                   |
| `StateNotifierProvider`| Complex synchronous state/logic   | ❌             | `autoDispose`            | `@riverpod`                   |
| `AsyncNotifierProvider`| Complex asynchronous state/logic  | ✅             | `autoDispose`            | `@riverpod`                   |

## 4. File Organization and Naming Conventions

To maintain a clean and scalable structure, providers should be organized by feature and follow a consistent naming convention.

*   **Location:** Providers should be placed within the relevant feature directory.
    *   `lib/features/auth/providers/` for authentication related providers (e.g., `auth_state_provider.dart`).
    *   `lib/features/wardrobe/providers/` for wardrobe related providers (e.g., `wardrobe_notifier_provider.dart`).
    *   `lib/core/presentation/providers/` for global or shared providers (e.g., `supabase_client_provider.dart`, `app_theme_provider.dart`).
*   **Naming:**
    *   Provider files should generally end with `_provider.dart` or `_notifier_provider.dart`.
    *   The provider variable name should clearly indicate its purpose (e.g., `userProfileProvider`, `wardrobeItemsProvider`).

## 5. Code Generation

Riverpod v2 leverages code generation to reduce boilerplate and increase type safety. This is done using the `riverpod_generator` package and the `@riverpod` annotation.

*   **Setup:**
    1.  Add `riverpod_generator` and `build_runner` as dev dependencies in `pubspec.yaml`.
    2.  Create your provider file (e.g., `my_notifier_provider.dart`) and use the `@riverpod` annotation.
    3.  Run the build runner to generate the code.
*   **🛠️ Code Generation Commands:**
    *   To generate code once:
        ```bash
        flutter pub run build_runner build --delete-conflicting-outputs
        ```
    *   To watch for changes and auto-generate:
        ```bash
        flutter pub run build_runner watch --delete-conflicting-outputs
        ```

## 6. Advanced Concepts (Tips & Tricks)

### 6.1. Provider Scoping and Overrides

For testing or previewing components with specific state, you can override providers within a `ProviderScope`. This is incredibly useful for isolating tests or providing mock data.

*   **Example for Testing:**
    ```dart
    testWidgets('MyWidget displays user name', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider.overrideWith((ref) => FakeUser(name: 'Test User')),
          ],
          child: MyApp(), // Or the specific widget tree you are testing
        ),
      );

      // ... perform your test assertions ...
    });
    ```

### 6.2. Selective Watching for Performance

To prevent unnecessary rebuilds, you can use `select` to watch only a specific part of a provider's state.

*   **Example:**
    ```dart
    // Instead of watching the whole state object
    // final userState = ref.watch(userProfileProvider);
    
    // Watch only the 'name' field
    final userName = ref.watch(userProfileProvider.select((user) => user.name));
    ```

## 7. Best Practices

1.  **Favor `AsyncNotifierProvider`:** For any state involving data fetching or asynchronous operations, prefer `AsyncNotifierProvider` over `FutureProvider` or `StreamProvider` for better control and integration with `AsyncValue`.
2.  **Use `ref.read()` for Dependency Injection:** Use `ref.read()` inside a provider's `build` method or a Notifier's method to inject dependencies like repositories or other providers. Avoid using `ref.read()` inside the `build` method of a `StatelessWidget` for anything other than calling a provider; prefer `ref.watch()` for UI updates.
3.  **Use `ref.watch()` for UI Reactivity:** Use `ref.watch()` in the `build` method of a widget or inside other providers to listen to a provider's state and rebuild/react when it changes.
4.  **Use `ref.listen()` for Side Effects:** Use `ref.listen()` to trigger side effects (like navigation or showing a SnackBar) in response to state changes.
    ```dart
    ref.listen<AsyncValue<void>>(someActionProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
      }
    });
    ```
5.  **Leverage Code Generation (`@riverpod`):** Use the `riverpod_generator` package and the `@riverpod` annotation to reduce boilerplate and improve type safety. This is especially useful for `AsyncNotifier` and `Notifier`.
6.  **Organize Providers:** Place providers close to the features or layers they belong to. For global state (like auth), place them in a central location (e.g., `core/presentation/providers`).

## 8. Common Patterns

*   **Loading/Data/Error Handling:** Use `AsyncValue` with `when` or `whenData` methods in conjunction with `AsyncNotifierProvider` to elegantly handle different states of an asynchronous operation.
*   **Form State Management:** Use a `StateNotifier` or `AsyncNotifier` to manage the state of a form, including field values, validation errors, and submission status.
*   **Caching:** Riverpod's built-in caching (when not using `autoDispose` or when a provider is actively listened to) can prevent unnecessary re-fetches of data. Combine with Supabase's local persistence or Hive for more advanced caching if needed.


