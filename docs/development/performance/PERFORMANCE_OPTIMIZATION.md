# Aura Performance Optimization Guide

This document outlines strategies and techniques for optimizing the performance of the Aura application, with a primary focus on the Flutter frontend. It covers widget rebuild optimization, image handling, memory management, and other key areas to ensure a smooth and responsive user experience.

## Table of Contents

1.  [Overview](#1-overview)
    *   [1.1. Key Performance Goals](#11-key-performance-goals)
    *   [1.2. Measuring Performance Goals](#12-measuring-performance-goals)
2.  [Widget Rebuild Optimization](#2-widget-rebuild-optimization)
    *   [2.1. Use `const` Constructors](#21-use-const-constructors)
    *   [2.2. Leverage `const` for Lists and Spacing](#22-leverage-const-for-lists-and-spacing)
    *   [2.3. Optimize `ListView` and `GridView`](#23-optimize-listview-and-gridview)
    *   [2.4. Isolate Heavy UI Logic in `build`](#24-isolate-heavy-ui-logic-in-build)
    *   [2.5. Use `select` for Fine-Grained Listening](#25-use-select-for-fine-grained-listening)
    *   [2.6. Avoid Deeply Nested Widgets](#26-avoid-deeply-nested-widgets)
    *   [2.7. Widget Rebuild Optimization Checklist](#27-widget-rebuild-optimization-checklist)
3.  [Image Handling](#3-image-handling)
    *   [3.1. Image Caching](#31-image-caching)
    *   [3.2. Image Resizing](#32-image-resizing)
    *   [3.3. Loading Placeholders (Shimmer)](#33-loading-placeholders-shimmer)
    *   [3.4. Image Handling Checklist](#34-image-handling-checklist)
4.  [Memory Management](#4-memory-management)
    *   [4.1. Disposing of Resources](#41-disposing-of-resources)
    *   [4.2. Weak References for Caching (Advanced)](#42-weak-references-for-caching-advanced)
    *   [4.3. Monitoring Memory Usage](#43-monitoring-memory-usage)
5.  [Asynchronous Operations](#5-asynchronous-operations)
    *   [5.1. Use `FutureBuilder` and `StreamBuilder` Appropriately](#51-use-futurebuilder-and-streambuilder-appropriately)
    *   [5.2. Background Computation](#52-background-computation)
6.  [Network Optimization](#6-network-optimization)
    *   [6.1. Caching API Responses](#61-caching-api-responses)
    *   [6.2. Batching Requests](#62-batching-requests)
    *   [6.3. Pagination](#63-pagination)
7.  [Startup Time Optimization](#7-startup-time-optimization)
    *   [7.1. Lazy Loading](#71-lazy-loading)
    *   [7.2. Code Splitting (Advanced)](#72-code-splitting-advanced)
8.  [Profiling and Monitoring](#8-profiling-and-monitoring)
    *   [8.1. Flutter DevTools - Performance Profiling Workflow](#81-flutter-devtools---performance-profiling-workflow)
    *   [8.2. Real Device Testing](#82-real-device-testing)
9.  [Conclusion & Next Steps](#9-conclusion--next-steps)

## 1. Overview

Performance optimization is critical for maintaining a high-quality user experience in Aura. Users expect fast load times, smooth interactions, and minimal battery drain. This guide provides actionable recommendations aligned with best practices and insights from documents like `Performans Optimizasyonu ve Bellek Yönetimi.pdf` and `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf`.

### 1.1. Key Performance Goals

Based on `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf` and general mobile app best practices:

*   **Frame Rate:** Target a consistent 60 Frames Per Second (FPS) for smooth animations and scrolling.
*   **Frame Budget:** Each frame must be rendered in **~16.67 milliseconds (ms)** (1000ms / 60fps ≈ 16.67ms). Exceeding this budget causes "jank" or stuttering.
*   **Cold Startup Time:** < 2 seconds.
*   **Warm Startup Time:** Faster than cold start.
*   **Efficient Resource Usage:** Minimize CPU and memory consumption to prolong battery life and prevent app crashes.

### 1.2. Measuring Performance Goals

It's crucial to measure these goals to track progress and identify bottlenecks. Here's an example of how these metrics might be tracked:

| Metric | Target | Example Measurement | Status | Notes |
| :--- | :--- | :--- | :--- | :--- |
| Cold Startup Time | < 2s | 1.8s | ✅ Good | Measured on mid-range device |
| FPS (Home Screen scroll) | 60fps | ~55fps | ⚠️ Needs Optimization | Jank observed during fast scrolls |
| Heap Memory (idle) | < 120MB | 98MB | ✅ Good | Monitored via DevTools |
| ListView.builder Frame Time | < 16.67ms | 12ms avg | ✅ Good | For items with images |

## 2. Widget Rebuild Optimization

Minimizing unnecessary widget rebuilds is fundamental to Flutter performance.

### 2.1. Use `const` Constructors

*   **Principle:** For widgets whose properties do not change, use `const` constructors. This allows Flutter to reuse the same widget instance instead of creating a new one each time its parent rebuilds.
*   **Where to Apply:** UI elements with static content, like `Text`, `Icon`, custom components in `COMPONENT_LIST.md` (e.g., `PrimaryButton` when properties are static), and items within lists that don't change frequently.
*   **Example:**
    ```dart
    // Good
    const Text('Stil Asistanı'),
    const Icon(Icons.add),
    const PrimaryButton(label: 'Kaydet'), // Assuming label and onPressed are static

    // Less optimal if these values don't change
    Text('Stil Asistanı'),
    Icon(Icons.add),
    PrimaryButton(label: 'Kaydet'),
    ```

### 2.2. Leverage `const` for Lists and Spacing

*   **Principle:** Use `const` for lists of widgets and spacing widgets (`SizedBox`, `Padding`) when their properties are fixed.
*   **Example:**
    ```dart
    Column(
      children: const [
        Text('Başlık'),
        SizedBox(height: 16.0), // Const SizedBox
        Text('Alt Başlık'),
      ],
    );
    ```

### 2.3. Optimize `ListView` and `GridView`

*   **Use `ListView.builder`/`GridView.builder`:** For long lists, always use the `.builder` constructor. It creates items lazily (on-demand) as they scroll into view, significantly reducing memory usage and initial build time compared to creating all items upfront.
*   **`itemExtent` (if applicable):** If all items in a `ListView` have the same fixed height, use the `itemExtent` property. This removes the need for Flutter to calculate the position of every item, speeding up layout.
*   **`cacheExtent`:** Adjust the `cacheExtent` property to control how far ahead (and behind) ListView pre-builds items. The default is usually good, but tuning it based on item complexity and scroll behavior can help.
*   **Example (from `sayfalar ve detayları.pdf` - WardrobeHomeScreen):**
    ```dart
    // Efficient for potentially large wardrobe lists
    ListView.builder(
      itemCount: clothingItems.length,
      itemBuilder: (context, index) {
        final item = clothingItems[index];
        return ClothingItemCard(item: item); // See 2.4 for optimizing this widget
      },
    );
    ```

### 2.4. Isolate Heavy UI Logic in `build`

*   **Principle:** Avoid performing heavy computations (e.g., filtering large lists, complex string manipulations) directly inside the `build` method. The `build` method can be called frequently, and heavy work here will cause jank.
*   **Solution:** Move such logic to the `application` or `domain` layer, or compute values within your Riverpod `Notifier`/`AsyncNotifier` state and expose the pre-computed result to the UI.
*   **Example (from `sayfalar ve detayları.pdf` - WardrobeHomeScreen filtering/sorting):**
    ```dart
    // Inside WardrobeNotifier (AsyncNotifier)
    // Bad (in build method)
    // final filteredItems = state.items.where((item) => item.category == selectedCategory).toList();

    // Good (in Notifier)
    List<ClothingItem> _filterAndSortItems(List<ClothingItem> items) {
      // Perform filtering and sorting logic here
      var filtered = items;
      if (state.selectedCategory != null) {
        filtered = filtered.where((item) => item.category == state.selectedCategory).toList();
      }
      // ... sorting logic ...
      return filtered;
    }

    // In UI (Presentation Layer)
    final filteredItems = ref.watch(wardrobeNotifierProvider.select((value) {
      // Assuming the notifier already provides the filtered list
      if (value is WardrobeLoaded) {
        return value.items; // This list is already filtered/sorted by the notifier
      }
      return const <ClothingItem>[];
    }));
    ```

### 2.5. Use `select` for Fine-Grained Listening

*   **Principle:** By default, `ref.watch(provider)` rebuilds the widget whenever *any part* of the provider's state changes. Use `select` to listen only to specific parts of the state, reducing unnecessary rebuilds.
*   **Beyond `select`:** For `AsyncNotifierProvider` and `AsyncValue`, consider using `AsyncValue.when` or `AsyncValue.whenData` directly in the widget tree to handle loading/data/error states efficiently without triggering rebuilds for the entire widget subtree on every state change within the `AsyncValue`.
*   **Example (from `sayfalar ve detayları.pdf` - WardrobeHomeScreen grid/list view toggle):**
    ```dart
    // Bad - Rebuilds if any part of wardrobe state changes (e.g., item list, search term)
    // final wardrobeState = ref.watch(wardrobeNotifierProvider);

    // Good - Only rebuilds if isGridView changes
    final isGridView = ref.watch(wardrobeNotifierProvider.select((value) => value.isGridView));
    ```

### 2.6. Avoid Deeply Nested Widgets

*   **Principle:** Excessively deep widget trees can slow down the build process. Break down complex UIs into smaller, reusable custom widgets.
*   **Benefit:** This also improves code readability and maintainability.

### 2.7. Widget Rebuild Optimization Checklist

| Technique | When to Use | Notes |
| :--- | :--- | :--- |
| `const` Constructors | Static widgets | Reduces object allocation |
| `const` Lists/Spacing | Fixed UI elements | Improves layout efficiency |
| `ListView.builder` | Long lists | Lazy loading, memory efficient |
| `itemExtent` | Fixed-height list items | Faster item positioning |
| Move logic out of `build` | Heavy computations | Prevents jank |
| `select` | Partial state listening | Reduces rebuilds |
| Break down deep trees | Complex UIs | Improves build performance & readability |

## 3. Image Handling

Images are often a major source of performance bottlenecks.

### 3.1. Image Caching

*   **Tool:** Use `cached_network_image` package.
*   **Purpose:** Caches downloaded images in memory and on disk. Subsequent requests for the same image URL load instantly from cache, avoiding repeated network calls and decoding.
*   **Usage:**
    ```dart
    CachedNetworkImage(
      imageUrl: clothingItem.imageUrl,
      placeholder: (context, url) => const CircularProgressIndicator(), // Shimmer effect is better, see 3.3
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.cover,
    );
    ```

### 3.2. Image Resizing

*   **Principle:** Never load full-resolution images if they are displayed at a much smaller size. Download appropriately sized thumbnails from your backend (Supabase Storage) whenever possible.
*   **Backend:** Ensure your FastAPI service (or Supabase Functions) generates and serves thumbnails for common display sizes (e.g., list thumbnails, detail view images).
*   **Frontend:** If backend resizing isn't feasible, consider client-side resizing libraries, but this should be a last resort as it consumes CPU/memory on the device.

### 3.3. Loading Placeholders (Shimmer)

*   **Tool:** Use `shimmer` package.
*   **Purpose:** Provides a better user experience than a simple `CircularProgressIndicator`. A shimmer effect over a rough outline of the image/content indicates that content is loading, making the app feel faster and more polished. (See `Flutter ile Aura İçin Kişisel ve Sıcak Material 3 UIUX Rehberi.pdf` - Mikro Etkileşimler)
*   **Usage (based on `Aura Deneyimi_ Tasarım Rehberi.docx` - Mikro Etkileşimler):**
    ```dart
    CachedNetworkImage(
      imageUrl: clothingItem.imageUrl,
      placeholder: (context, url) => Shimmer.fromColors(
             baseColor: Colors.grey[300]!,
             highlightColor: Colors.grey[100]!,
             child: Container(color: Colors.white), // Rough shape of the image
           ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.cover,
    );
    ```

### 3.4. Image Handling Checklist

| Technique | Tool | Notes |
| :--- | :--- | :--- |
| Network Image Caching | `cached_network_image` | Essential for lists |
| Thumbnail Usage | Backend-generated | Reduces download & decode time |
| Shimmer Placeholders | `shimmer` | Better UX than spinners |
| Avoid Full-Res | Backend/Client resize | Prevents memory bloat |

## 4. Memory Management

Efficient memory usage prevents app crashes and ensures smooth performance, especially on lower-end devices.

### 4.1. Disposing of Resources

*   **Controllers and Listeners:** Always dispose of resources like `AnimationController`, `TextEditingController`, `StreamSubscription` in the `dispose()` method of `StatefulWidget`s.
*   **Example:**
    ```dart
    class _MyScreenState extends State<MyScreen> {
      late TextEditingController _controller;
      late StreamSubscription _subscription;

      @override
      void initState() {
        super.initState();
        _controller = TextEditingController();
        _subscription = someStream.listen((data) { /* handle data */ });
      }

      @override
      void dispose() {
        _controller.dispose();
        _subscription.cancel(); // Important!
        super.dispose();
      }

      // ... build method ...
    }
    ```

### 4.2. Weak References for Caching (Advanced)

*   **Concept:** For in-memory caches of large objects (not typically needed with `cached_network_image`'s disk cache), consider using data structures or patterns that allow the garbage collector to reclaim memory when under pressure. Dart/Flutter doesn't have direct "weak references" like some other languages, but techniques like `Expando` or LRU caches with careful size limits are relevant.

### 4.3. Monitoring Memory Usage

*   **Tools:** Use Flutter DevTools' Memory tab to profile your app's memory consumption. Look for memory leaks (objects that accumulate over time without being garbage collected) and excessive memory usage peaks.

## 5. Asynchronous Operations

Handling async operations efficiently prevents UI blocking.

### 5.1. Use `FutureBuilder` and `StreamBuilder` Appropriately

*   **Purpose:** These widgets handle the state (loading, data, error) of asynchronous operations seamlessly within the widget tree.
*   **Caution:** Avoid placing `FutureBuilder`/`StreamBuilder` high up in the widget tree if their data doesn't change frequently, as they can cause unnecessary rebuilds of their subtree. Place them closer to where the data is actually used.

### 5.2. Background Computation

*   **Isolates:** For extremely CPU-intensive tasks (rare in typical mobile UI logic, but maybe in some AI preprocessing if done client-side), consider using `Isolate`s to move the work off the main UI thread. This is an advanced topic.

## 6. Network Optimization

Reducing network calls and optimizing their efficiency is key.

### 6.1. Caching API Responses

*   **Riverpod Cache:** Leverage Riverpod's built-in caching with `.autoDispose` (default) and `keepAlive` where appropriate. For data that doesn't change frequently, let Riverpod hold the data in memory.
*   **HTTP Caching Headers:** Ensure your Supabase REST API and FastAPI endpoints use appropriate HTTP caching headers (`Cache-Control`, `ETag`) so that HTTP clients (`dio`) can potentially avoid re-fetching data if it hasn't changed.

### 6.2. Batching Requests

*   **Principle:** Combine multiple related API calls into a single request when possible (e.g., fetching a user's profile, wardrobe count, and notification count together on app startup) to reduce network round trips.

### 6.3. Pagination

*   **Principle:** Implemented correctly in `ListView.builder` (see 2.3) to load data in chunks, reducing initial load time and memory footprint.

## 7. Startup Time Optimization

Reducing the time it takes for the app to become interactive.

### 7.1. Lazy Loading

*   **Concept:** Defer the initialization of non-critical features/services until they are actually needed. For example, if a specific AI feature is rarely used, don't initialize its dependencies at app startup.
*   **Implementation:** Initialize heavy services or load large data sets in the background after the main UI is rendered, or only when the relevant screen is first accessed.

### 7.2. Code Splitting (Advanced)

*   **Concept:** While Flutter doesn't do traditional code-splitting like web apps, the concept of modularizing features and loading them on demand is relevant in a monorepo/package structure (`ARCHITECTURE.md`).

## 8. Profiling and Monitoring

Continuously measure performance to identify bottlenecks.

### 8.1. Flutter DevTools - Performance Profiling Workflow

Use Flutter DevTools to analyze and optimize your app's performance. Here's a step-by-step workflow:

1.  **Run in Profile Mode:** Start your app in profile mode (`flutter run --profile`) or release mode (`flutter run --release`) for accurate performance data. Debug mode performance is not representative.
2.  **Open DevTools:** Run `flutter pub global run devtools` or click the DevTools icon in your IDE.
3.  **Connect to App:** Connect DevTools to your running app.
4.  **Navigate to Performance Tab:** Select the "Performance" tab in DevTools.
5.  **Start Recording:** Click the "Record" button.
6.  **Perform Actions:** Interact with your app, focusing on areas you suspect might be slow (e.g., scrolling a list, opening a screen with many images).
7.  **Stop Recording:** Click "Stop" to finish the recording.
8.  **Analyze the Timeline:**
    *   **Frame Chart:** Look for frames that exceed the 16.67ms budget. These are represented by red bars.
    *   **Bottom-Up/Call Tree:** Identify which functions are consuming the most time.
    *   **Raster/Build Times:** See how long UI building and rendering take.
9.  **Identify Jank:** Focus on the red "jank" frames. Drill down to see which widgets or methods are causing the delay.
10. **Optimize:** Apply the appropriate optimization techniques from this guide based on your findings.
11. **Repeat:** Re-run the profiler after making changes to verify the improvements.

### 8.2. Real Device Testing

*   **Importance:** Always test performance on a variety of real devices, especially mid to low-range ones, not just high-end simulators.

## 9. Conclusion & Next Steps

This guide provides a comprehensive set of strategies to enhance the performance of the Aura application. Implementing these techniques can lead to significant improvements in user experience, with smoother interactions, faster load times, and reduced battery consumption.

**Recommended Next Steps:**

1.  **Profile Critical Screens:** Use Flutter DevTools to analyze the performance of key screens (e.g., `WardrobeHomeScreen`, `StyleAssistantScreen`) and identify specific bottlenecks.
2.  **Apply Relevant Techniques:** Based on the profiling results, apply the optimization techniques outlined in this guide.
3.  **Measure Again:** Re-profile after implementing changes to quantify the improvements.
4.  **Iterate:** Performance optimization is an ongoing process. Regularly revisit and refine your approach as the application evolves.

By following this guide and continuously monitoring performance, you can ensure that Aura remains fast, responsive, and delightful to use.


