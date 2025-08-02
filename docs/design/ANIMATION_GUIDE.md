# Aura Project Animation Guide (ANIMATION_GUIDE.md)

**Version:** 2.1

This document outlines the micro-interactions and animation principles for the Aura application. It aims to create a "smart assistant" feel, providing feedback, guiding the user, and making the experience delightful using Flutter's animation capabilities.

It is designed to be fully compliant with the visual identity and interaction patterns defined in `STYLE_GUIDE.md` and the strategic design scenarios outlined in `Aura Deneyimi_ Tasarım Rehberi.docx` and `Aura Deneyimi_Tasarlama Rehberi.pdf`.

## 1. Used Packages

*   `flutter_animate`: For simple entrance and transition animations.
*   `lottie`: For complex and character-driven animations (e.g., "Aura thinking", success animations). *See `Aura Deneyimi_Tasarlama Rehberi.pdf` pg. X for specific Lottie animation file recommendations.*
*   `shimmer`: For skeleton loading effects.

## 2. Core Animation Scenarios

### 2.1. AI Analysis ("Thinking" Moment)

*   **Purpose:** To make the user feel that the AI is processing.
*   **Implementation:** A `Lottie` animation and a friendly message like "Aura is thinking for you..." underneath.
*   **Location:** Recommendation loading screen, during style analysis.
*   **Duration and Curve:** 2000ms, repeating, `Curves.linear`.
*   **Accessibility Note:** A semantic announcement like "AI analysis in progress..." should be provided for screen readers.
*   **Note:** This animation scenario should be paired with the relevant UI component (typically a loading state).
*   **Design Reference:** Aligns with the "AI is Thinking" scenario described in `Aura Deneyimi_ Tasarım Rehberi.docx` (Section 2) and `Aura Deneyimi_Tasarlama Rehberi.pdf` (Section 2).

### 2.2. Success and Confirmation

*   **Purpose:** To give positive feedback to the user.
*   **Implementation:** A `Lottie` confetti or sparkling stars animation when an operation completes.
*   **Location:** When a clothing item is added, when the profile is updated.
*   **Duration and Curve:** 1500ms, `Curves.easeOut`.
*   **Note:** The animation should automatically disappear after completion.
*   **Related Component Note:** See `PrimaryButton`'s post-success state.
*   **Design Reference:** Aligns with the "Gardırobuna Kaydediliyor" (Saving to Wardrobe) scenario in `Aura Deneyimi_Tasarlama Rehberi.pdf` (Section 5), using `assets/animations/success_hanger.json`.

### 2.3. Cards Entering the Screen

*   **Purpose:** To make content appear gently instead of abruptly.
*   **Implementation:** "Fade in" and "slide up" effects using the `flutter_animate` package.
*   **Location:** List of recommendation cards, wardrobe contents.
*   **Duration and Curve:** 400ms, `Curves.easeOut`.
*   **Note:** A staggered animation can be applied for each card within a list.
*   **Related Component Note:** See `CustomCard`, `SwipeableCard`.
*   **Design Reference:** Aligns with the "Önerin Hazır!" (Recommendation Ready) scenario in `Aura Deneyimi_ Tasarım Rehberi.docx` (Section 3) and `Aura Deneyimi_Tasarlama Rehberi.pdf` (Section 3), using `flutter_animate` for `fadeIn` and `slideUp`.

### 2.4. Screen Transitions

*   **Purpose:** To strengthen the sense of context between screens.
*   **Implementation:**
    *   **Hero Animations:** For shared elements between screens (e.g., an item image transitioning from a list to a detail page). Use Flutter's built-in `Hero` widget.
    *   **Page Route Transitions:** Custom page transitions using `PageRouteBuilder` for unique entry/exit effects (e.g., slide, fade) with `Curves.easeInOut`.
*   **Duration and Curve (Guidelines):**
    *   **Hero Transition:** ~300ms, `Curves.easeInOut`.
    *   **Standard Page Transition:** ~300ms, `Curves.easeInOut`.

### 2.5. Button Press Feedback

*   **Purpose:** To acknowledge immediate user interaction.
*   **Implementation:** A subtle scale-down effect on press using `flutter_animate` or built-in Material button feedback.
*   **Location:** All primary, secondary, and text buttons.
*   **Duration and Curve:** ~100ms, `Curves.easeInOut`.
*   **Note:** Should be minimal and not distracting.

### 2.6. Menu Open/Close

*   **Purpose:** Smooth appearance/disappearance of menus or modal sheets.
*   **Implementation:** Slide or fade animations using `PageRouteBuilder` or built-in sheet transitions.
*   **Duration and Curve:** ~250ms, `Curves.easeInOut`.

### 2.7. Loading States (Skeleton/Shimmer)

*   **Purpose:** To indicate content is loading without freezing the UI, improving perceived performance.
*   **Implementation:** Use the `shimmer` package to create a "shine" effect over placeholder shapes that mimic the final content layout.
*   **Location:** Initial load of lists, image galleries, or complex recommendation views.
*   **Note:** Combine with actual loading progress if available.

### 2.8. State Changes (e.g., Like/Unlike)

*   **Purpose:** To provide visual confirmation of state toggles.
*   **Implementation:** A quick scale or color change animation on the interactive element (e.g., heart icon).
*   **Location:** Like buttons on items, favorite toggles.
*   **Duration and Curve:** ~200ms, `Curves.easeInOut`.

## 3. Animation Principles & Best Practices

### 3.1. Purposeful Motion

*   Every animation must have a clear purpose: to provide feedback, guide attention, or enhance delight. Avoid animations purely for decoration ("eye candy").

### 3.2. Performance

*   Animations should enhance, not hinder, the user experience. Use lightweight animations for performance-critical areas (e.g., long lists).
*   If `MediaQuery.of(context).disableAnimations` is `true` (e.g., for users with motion sickness or accessibility settings), animations should either:
    *   Be simplified (e.g., `FadeIn` only with `flutter_animate`).
    *   Not auto-play (`Lottie` animations should require user interaction to start).

### 3.3. Consistency

*   Use consistent easing curves (`Curves.easeOut`, `Curves.easeInOut`) and durations for similar types of animations across the app.

### 3.4. Timing

*   **Fast (100-300ms):** Direct feedback (button presses, state changes).
*   **Medium (300-600ms):** Transitions (card entrances, screen transitions).
*   **Long (1000ms+):** Contextual moments (AI thinking, success celebrations). Ensure these are interruptible or skippable if appropriate.

## 4. Technical Implementation Guide

### 4.1. Using `flutter_animate`

*   Import: Add `import 'package:flutter_animate/flutter_animate.dart';` to your widget file.
*   Basic Usage:
    ```dart
    // Fade in a widget over 500 milliseconds
    Text('Hello').animate().fadeIn(duration: 500.ms);

    // Slide up and fade in
    MyCard().animate().slide().fadeIn();

    // Staggered animation for a list (example logic)
    ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return items[index]
            .animate(delay: (index * 100).ms) // Delay based on index
            .slideX(begin: 1) // Slide in from the right
            .fadeIn();
      },
    );
    ```
*   **Note:** Chain animations carefully to avoid jank.

### 4.2. Using `lottie`

*   Asset Management: Place `.json` Lottie files in the `assets/animations/` directory.
*   Basic Usage:
    ```dart
    // Load a Lottie animation from assets
    Lottie.asset('assets/animations/thinking.json');

    // Load from a network (ensure caching is handled)
    Lottie.network('https://example.com/animations/success.json');
    ```
*   **Note:** Lottie animations can be heavier. Monitor performance, especially on lower-end devices.
*   **Design Reference:** Specific Lottie files like `success_hanger.json` are recommended for certain scenarios (`Aura Deneyimi_Tasarlama Rehberi.pdf`).

### 4.3. Using `shimmer`

*   Basic Usage:
    ```dart
    // Wrap a placeholder widget with Shimmer
    Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 100.0,
        color: Colors.white, // Placeholder shape
      ),
    );
    ```

## 5. Animation Matrix

| Animation Type      | Duration (ms) | Curve           | Notes                                 |
| :------------------ | :------------ | :-------------- | :------------------------------------ |
| AI Analysis         | 2000+         | `Linear`        | Continuous, repeating                 |
| Success/Confirmation| 1000-1500     | `EaseOut`       | One-time                              |
| Card Entrance       | 300-500       | `EaseOut`       | Staggered applicable                  |
| Screen Transition (Hero) | 300      | `EaseInOut`     |                                       |
| Button Press        | 100           | `EaseInOut`     | Minimal scale change                  |
| Page Transition     | 300           | `EaseInOut`     | With `PageRouteBuilder`               |
| Menu Open/Close     | 250           | `EaseInOut`     |                                       |

## 6. Usage Notes

*   Animations should not slow the user down; they should speed up the perception of responsiveness.
*   Every animation must have a purpose. Avoid "decorative" animations.
*   Carefully use complex animations in performance-critical areas (e.g., long lists).
*   `.json` files for `Lottie` animations must be added to the `assets/animations/` folder.
*   Add `import 'package:flutter_animate/flutter_animate.dart';` to the widget tree for `flutter_animate` usage.
*   Animations in long lists or card grids should be started in a staggered manner. Recommended solution: Using `Interval` with `flutter_animate`.
*   If `MediaQuery.of(context).disableAnimations` is `true`:
    *   `flutter_animate` transitions should be limited to simpler effects (e.g., `FadeIn` only).
    *   `Lottie` animations should not autoplay; they should only be triggered by user interaction.
*   **Design Alignment:** All animations should reinforce the "smart, guiding, warm, personal" assistant personality of Aura as defined in `Aura Deneyimi_ Tasarım Rehberi.docx` and `Aura Deneyimi_Tasarlama Rehberi.pdf`.
