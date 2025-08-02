# Aura Project Onboarding Flow Guide (ONBOARDING_FLOW.md)

**Version:** 2.1

This document details the structure, user flow, and design principles of the Aura application's onboarding process. The goal is to introduce the app's value proposition in an engaging way and collect initial user preferences to personalize the experience.

It aims to familiarize the new user with the application in a fun, guided, and interactive way, giving the feeling of a "warm digital style assistant".

This approach, particularly the detailed style discovery, is designed to align with the strategic concept of "positive friction" as seen in services like Stitch Fix, where a slightly more involved initial setup aims to build user investment and gather rich data for superior personalization (as discussed in `AURA PROJESİ - NİHAİ TASARIM VE STRATEJİ DÖKÜMANI (V3.0 - Tam Metin).docx`).

## 1. Overall Flow Structure

The onboarding flow consists of two main sections:

1.  **Welcome and Introduction:** Introduction to the application and user authentication (if applicable).
2.  **Style Discovery:** Gamified questions to learn the user's style preferences.

## 2. Detailed Flow Steps

### 2.1. Welcome Screens (`PageView`)

*   **Component:** `PageView`.
*   **Flow:** Three full-screen, swipeable pages presenting the app's value proposition to the user. These pages will contain illustrations reflecting Aura's warm visual identity and short, effective texts:
    *   "Meet Aura, your personal style assistant."
    *   "Discover the potential of your wardrobe."
    *   "Let's find your style with personalized combinations."
*   **Navigation:**
    *   **Indicators:** Step indicators (e.g., `smooth_page_indicator`).
    *   **Buttons:** "Next" and "Back" buttons at the bottom.
*   **Skip Option:** A "Skip Onboarding" option (e.g., in the app bar) should be available, allowing users to bypass the process. This should lead to assigning a default style profile (see section 6).

### 2.2. Style Discovery (Gamified Questions)

*   **Component:** A series of interactive questions presented in a gamified manner.
*   **Question Types:**
    *   **Image Selection:** Present users with sets of images (e.g., outfits, color palettes, mood boards) and ask them to select their preferences (e.g., "Which style suits you better?", "Pick your favorite colors").
    *   **Text-Based Choices:** Offer concise text options for preferences (e.g., "Your shopping style?", Options: "Trendy", "Classic", "Budget-Conscious").
    *   **Interactive Sliders:** For nuanced preferences like "How formal is your style?" (Scale: Casual ↔ Formal).
*   **Presentation Formats:**
    *   `PageView`: For sequential questions.
    *   `CardSwiper` (e.g., `flutter_card_swiper`): Tinder-like swiping left/right to approve/reject suggestions.
    *   `SingleChildScrollView` + `Column`: For questions requiring vertical scrolling.
*   **Progress Indication:** A clear progress indicator (e.g., "Question 3 of 10") helps manage user expectations.
*   **Data Collection:** Answers are collected and stored temporarily in the onboarding state (see section 5).

### 2.3. Completion & Transition

*   **Final Step:** A celebratory screen thanking the user (e.g., "Great! Aura is ready to assist you.").
*   **Action:** Redirect the user to the main application (e.g., `WardrobeHomeScreen`).
*   **Persistence:** Mark onboarding as complete in persistent storage (e.g., `shared_preferences`). Set a flag like `onboarding_complete = true`.

## 3. UI/UX Principles

*   **Visual Identity:** Fully aligned with `STYLE_GUIDE.md` (colors, fonts, components).
*   **Micro-interactions:** Subtle animations (e.g., `flutter_animate` for page transitions, `Lottie` for celebration) enhance the experience. See `ANIMATION_GUIDE.md`.
*   **Accessibility:**
    *   **Semantic Labels:** All interactive elements (buttons, swiper cards) must have clear `semanticsLabel`s.
    *   **Color Contrast:** Ensure text and background colors meet WCAG AA standards (4.5:1). Refer to `STYLE_GUIDE.md`.
    *   **Touch Targets:** Minimum touch target size for buttons and interactive elements is 48x48 pixels.
*   **Responsive Design:** The onboarding flow must adapt gracefully to different screen sizes (phones, tablets) and orientations. See `RESPONSIVENESS_GUIDE.md`.

## 4. Skipping Onboarding

*   **Option:** Provide a clear way to skip the onboarding process (e.g., a "Skip" button in the app bar).
*   **Outcome:** If skipped, assign a default style profile to the user. This profile should be balanced to offer general recommendations.
    *   **Default Profile Example (Dart Snippet):**
        ```dart
        const defaultStyleProfile = {
          "mood": "neutral",
          "style": "casual",
          "colors": ["beige", "gray"],
          "budget": "medium"
        };
        ```
*   **Navigation:** The user is directed to the main application screen. Recommendations will initially be general and exploratory.
*   **Revisiting:** The user should be able to return to the onboarding process later, perhaps from Profile settings or an in-app prompt.

## 5. State Management

*   **Purpose:** Temporarily store user choices made during the onboarding process.
*   **Recommended Approach:** Use a state management solution like `StateNotifierProvider` (Riverpod) or a similar approach.
*   **Example (Dart Snippet using Riverpod):**
    ```dart
    final onboardingStateProvider = StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
      return OnboardingController();
    });

    // Controller manages state like:
    // class OnboardingState {
    //   final int currentStep;
    //   final Map<String, dynamic> userPreferences; // Stores answers
    //   final bool isComplete;
    //   // ...
    // }
    ```
*   **Key State Values:**
    *   `currentStep`: The step the user is currently on.
    *   `userPreferences`: A map/object holding the user's answers.
    *   `isSkipped`: Boolean flag if the user skipped the process.

## 6. Replaying Onboarding

*   **Requirement:** The onboarding flow might need to be restarted at the user's request (e.g., for testing, or if the user wants to redefine preferences).
*   **Implementation:**
    *   Clear persistence data (e.g., remove `onboarding_complete` and `onboarding_skipped` flags from `SharedPreferences`).
    *   Navigate the user back to the onboarding flow.
    *   **Example (Dart Snippet):**
        ```dart
        // Clear persistence data
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('onboarding_complete');
        await prefs.remove('onboarding_skipped');

        // Navigate to onboarding
        // context.go('/onboarding'); // Using GoRouter
        // Navigator.pushNamed(context, '/onboarding'); // Using standard Navigator
        ```

## 7. Technical Implementation Notes

*   **Location:** The onboarding flow should be developed within the `lib/src/presentation/features/onboarding/` directory.
*   **Navigation:** `PageView` is recommended as it gives the user a sense of control and presents information step-by-step. `Stepper` can feel cumbersome on mobile screens.
*   **Assets:** Question content and images should be added to the `assets/onboarding/` folder.
*   **Data Storage:** User selections should be stored using the state management approach defined above and potentially persisted locally (e.g., `shared_preferences`) for resilience.
*   **Accessibility (Accessibility) Principles:**
    *   Ensure all buttons and selectable elements have appropriate `semanticsLabel`s.
    *   Color contrasts must meet WCAG standards.
    *   Touch targets must be a minimum of 48x48 pixels.
