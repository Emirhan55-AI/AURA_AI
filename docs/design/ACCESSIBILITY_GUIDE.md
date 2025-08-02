# Aura Project Accessibility Guide (ACCESSIBILITY_GUIDE.md)

**Version:** 2.1

This document outlines the accessibility principles and implementation guidelines for the Aura application. Ensuring the app is usable by everyone, including people with disabilities, is a fundamental requirement.

It aims to make the application perceptible, operable, understandable, and robust (POUR principles) according to the WCAG 2.1 AA standard.

## 1. Core Principles

Aura targets compliance with the **WCAG 2.1 AA** level of accessibility standards. This guide aims to achieve this target by utilizing Flutter's accessibility APIs.

### 1.1. Perceivable (Perceivable)

Information and user interface components must be presentable to users in ways they can perceive.

*   **Alternative Text:**
    *   Meaningful `semanticsLabel` or `label` properties must be provided for all images, icons, and visual elements.
    *   *Example:*
        ```dart
        Image.asset('assets/images/logo.png',
          semanticsLabel: 'Aura App Logo',
        )
        ```
*   **Color Contrast:**
    *   A minimum contrast ratio of **4.5:1** must be maintained between foreground (text, icons) and background colors.
    *   The colors defined in `STYLE_GUIDE.md` must be selected to meet this criterion.
*   **Color Blindness Simulation:**
    *   Interface simulations for different types of color blindness (Deuteranomaly, Protanopia, Tritanopia) should be performed using tools like Flutter Preview Tools or similar.
    *   Contrasts that are unsuitable for color blindness or indistinguishable visual cues should be identified and corrected.

### 1.2. Operable (Operable)

User interface components and navigation must be operable.

*   **Touch Targets:**
    *   All custom components and interactive elements must have a minimum touch area of **48x48 pixels**.
    *   *Note:* All components in `COMPONENT_LIST.md` must meet this criterion.
*   **Timing:**
    *   Content that is time-limited must either be controllable by the user or provide the user with the option to control the timing.

### 1.3. Understandable (Understandable)

Information and the operation of the user interface must be understandable.

*   **Consistent Navigation:**
    *   Navigation and interaction patterns must be consistent throughout the application.

### 1.4. Robust (Robust)

Content must be robust enough that it can be interpreted reliably by a wide variety of user agents, including assistive technologies.

*   **Semantic Structure:**
    *   Use Flutter's semantic widgets (`Semantics`, `MergeSemantics`, etc.) correctly to provide a logical structure for assistive technologies like screen readers.
*   **Meaningful Labels:**
    *   Ensure all interactive elements (buttons, links, form fields) have clear and descriptive labels (`semanticsLabel`).

## 2. Technical Implementation Guide

### 2.1. Using `Semantics` Widget

The `Semantics` widget is the primary tool for providing accessibility information in Flutter.

*   **Basic Usage:**
    ```dart
    Semantics(
      label: 'Delete item', // Descriptive label for screen readers
      hint: 'Double tap to delete this clothing item', // Action hint
      button: true, // Indicates this element behaves like a button
      child: IconButton(
        icon: Icon(Icons.delete),
        onPressed: _onDeletePressed,
        // The IconButton's tooltip can complement the Semantics label
      ),
    )
    ```
*   **Merging Semantics:**
    Sometimes, you want to group multiple widgets under a single semantic node.
    ```dart
    MergeSemantics(
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.yellow),
          Text('4.5'),
          Text('(120 reviews)'),
        ],
      ),
    )
    // This entire row can now be treated as a single semantic element, e.g., "Rating: 4.5 stars from 120 reviews".
    ```

### 2.2. Accessible Images

Always provide a `semanticsLabel` for `Image` widgets unless the image is purely decorative (in which case, it should be marked as such or excluded from the semantic tree).

*   **Decorative Image (Exclude from Semantics):**
    ```dart
    ExcludeSemantics(
      child: Image.asset('assets/images/divider_pattern.png'),
    )
    // Or, if the image itself is not important for understanding:
    Image.asset('...', excludeFromSemantics: true);
    ```

### 2.3. Accessible Forms

Form fields must be correctly labeled and provide error feedback.

*   **Using `InputDecorator` and `FormField`:**
    Flutter's built-in form widgets (`TextField`, `DropdownButtonFormField`, etc.) usually handle basic accessibility. Ensure labels are provided.
    ```dart
    TextFormField(
      decoration: InputDecoration(
        labelText: 'Email Address', // This provides a semantic label
        hintText: 'Enter your email',
      ),
      validator: (value) {
        if (value == null || value.isEmpty || !value.contains('@')) {
          // Return an error message. This is often announced by screen readers.
          return 'Please enter a valid email address.';
        }
        return null;
      },
      // keyboardType, textInputAction, etc. also contribute to accessibility
    );
    ```

### 2.4. Accessible Navigation

Ensure that all interactive elements can be reached and activated using a keyboard or other assistive device (e.g., switch control).

*   **Focus Management:**
    Flutter handles basic focus traversal, but custom focus logic might be needed for complex UIs. Use `Focus` and `FocusScope` widgets.
*   **Skip Links (Optional but Helpful):**
    For screens with complex layouts, providing a "skip to main content" link can improve navigation for screen reader users. This can be implemented using `Semantics` and focus management.

### 2.5. Testing Accessibility

*   **Flutter DevTools:** Use the Flutter Inspector's "Accessibility" view to examine the semantic tree and identify potential issues.
*   **Platform-Specific Tools:**
    *   **Android:** Use Accessibility Scanner.
    *   **iOS:** Use Xcode's Accessibility Inspector.
*   **Automated Testing:** Incorporate accessibility checks into unit/widget tests using packages like `flutter_test`'s `meetsGuideline` API.
    ```dart
    testWidgets('PrimaryButton has sufficient tap target size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PrimaryButton(text: 'Test', onPressed: () {}),
            ),
          ),
        ),
      );

      final SemanticsNode buttonNode = tester.getSemantics(find.byType(ElevatedButton));
      // Example check using meetsGuideline (conceptual, actual API might vary)
      // expect(buttonNode, meetsGuideline(androidTapTargetGuideline));
    });
    ```
*   **Manual Testing:** Test the application using screen readers (TalkBack on Android, VoiceOver on iOS) and other assistive technologies.

## 3. Tools and Libraries

*   **Flutter DevTools:** For inspecting the semantic tree and performance/a11y audits.
*   **Platform-Specific Tools:** Accessibility Scanner (Android), Xcode Accessibility Inspector (iOS).
*   **Code Level:** `package:flutter/semantics.dart` (`Semantics`, `SemanticsService` classes).
*   **Testing:** Accessibility Guideline API (`meetsGuideline`) for minimum size and contrast tests. Tap target checks (`androidTapTargetGuideline`, `iOSTapTargetGuideline`) and labeling checks (`labeledTapTargetGuideline`) tests help maintain accessibility standards.

## 4. Performance, Maintenance, and Testing Recommendations

*   **Performance:** Accessibility support generally adds a slight overhead (additional semantic nodes) to the UI layout. It usually doesn't affect performance significantly; however, in very deeply nested widget structures, semantic tree construction time might take milliseconds. Regularly profile your app.
*   **Maintenance:** Keep accessibility considerations in mind during code reviews. Use a checklist covering items like button labels, alternative text, etc.
*   **Testing:** Integrate accessibility tests regularly:
    *   Use `meetsGuideline` in Flutter tests to add checks for target size, labels, and contrast.
    *   Apply an accessibility checklist during code reviews (button labels, alternative text, etc.).
    *   In the CI stage, automated scanners can add warnings for low contrast or scaling issues.

## 5. Usage Notes

*   When developing a new component, the principles of this guide and `STYLE_GUIDE.md` must be taken into account.
*   `semanticsLabel`, `hint`, `tooltip` properties must not be omitted for interactive or informative elements.
*   Color selections must adhere to `STYLE_GUIDE.md` and contrast ratios must be checked.
*   Touch targets must adhere to the 48x48 pixel standard.
*   Accessibility is not an "extra feature" but a fundamental user experience principle and must be considered at every stage of the project.
