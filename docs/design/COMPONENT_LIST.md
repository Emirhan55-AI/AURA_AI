# Aura Project Common Components (COMPONENT_LIST.md)

**Version:** 2.1

This document lists the core and common user interface (UI) components used in the Aura application. The purpose of each component, its appearance, behavior, and usage scenario are specified here. It should be developed in accordance with the style guide (`STYLE_GUIDE.md`) and theme architecture (`THEME_ARCHITECTURE.md`).

## 1. Core Components

### 1.1. PrimaryButton

*   **Purpose:** Used for primary actions (e.g., "Continue", "Save", "Sign In").
*   **Style:**
    *   Background Color: `Theme.of(context).colorScheme.primary`
    *   Text Color: `Theme.of(context).colorScheme.onPrimary`
    *   Corner Radius: `BorderRadius.circular(12.0)`
    *   Elevation: Standard Material 3 elevation (e.g., 1 resting, 3 pressed)
    *   Text Style: `Theme.of(context).textTheme.labelLarge` (Uses `Inter` from dual-font strategy)
*   **States:**
    *   `Enabled`: Default style.
    *   `Disabled`: Reduced opacity (e.g., 38%), desaturated colors.
    *   `Loading`: Shows a `CircularProgressIndicator` inside, hides text, disables button interaction.
    *   `Pressed/Hover/Focused`: Visual feedback according to Material 3 guidelines (e.g., elevation change, color tint).
*   **Accessibility:**
    *   Minimum Touch Target Size: 48x48 pixels.
    *   Semantic Label: Should be provided if the button only contains an icon or if the text is not descriptive enough.
*   **Usage (Example):**
    ```dart
    PrimaryButton(
      text: 'Save',
      onPressed: _onSavePressed,
      isLoading: false, // Pass state from controller/notifier
    )
    ```
*   **Note:** Should be based on Material 3 `FilledButton` and customized.

### 1.2. SecondaryButton

*   **Purpose:** Used for secondary actions that are less important than primary ones (e.g., "Cancel", "Later").
*   **Style:**
    *   Border: `outlined` variant of `ButtonStyle`, using `Theme.of(context).colorScheme.outline`.
    *   Text Color: `Theme.of(context).colorScheme.primary`.
    *   Corner Radius: `BorderRadius.circular(12.0)`.
    *   Text Style: `Theme.of(context).textTheme.labelLarge` (Uses `Inter` from dual-font strategy).
*   **States:** Similar to `PrimaryButton`.
*   **Accessibility:**
    *   Minimum Touch Target Size: 48x48 pixels.
*   **Usage (Example):**
    ```dart
    SecondaryButton(
      text: 'Cancel',
      onPressed: _onCancelPressed,
    )
    ```
*   **Note:** Should be based on Material 3 `OutlinedButton` and customized.

### 1.3. TextButton (Tertiary Action)

*   **Purpose:** Used for tertiary actions, often within dialogs or lists (e.g., "Learn More", "Skip").
*   **Style:**
    *   Text Color: `Theme.of(context).colorScheme.primary`.
    *   Text Style: `Theme.of(context).textTheme.labelLarge` (Uses `Inter` from dual-font strategy).
    *   No background or border in default state.
*   **States:** Visual feedback on press/hover (e.g., background ripple).
*   **Accessibility:**
    *   Minimum Touch Target Size: 48x48 pixels (padding might be needed).
*   **Usage (Example):**
    ```dart
    TextButton(
      onPressed: _onLearnMorePressed,
      child: Text('Learn More'),
    )
    ```
*   **Note:** Use standard Material 3 `TextButton`.

### 1.4. CustomCard

*   **Purpose:** Displays distinct pieces of related content, such as clothing items or outfit suggestions.
*   **Style:**
    *   Background Color: `Theme.of(context).colorScheme.surface`.
    *   Elevation: Standard Material 3 card elevation.
    *   Shape: Rounded rectangle with `BorderRadius.circular(16.0)`.
    *   Margin/Padding: Standard spacing around and within the card.
*   **States:**
    *   `Default`: Standard appearance.
    *   `Selected`: Visual highlight (e.g., border color change, slight elevation increase).
    *   `Pressed/Hover`: Feedback (e.g., ripple, shadow change).
*   **Accessibility:**
    *   Semantic Properties: Use `Semantics` widget if the card represents a tappable entity.
    *   Focus Handling: Ensure keyboard navigability if interactive.
*   **Usage (Example):**
    ```dart
    CustomCard(
      isSelected: item.isSelected, // State from provider/controller
      onTap: () => _onItemTapped(item.id),
      child: Column(
        // ... content like image, title, etc.
      ),
    )
    ```
*   **Note:** Should be based on Material 3 `Card` and customized. *This component inherits base styles from the Material 3 `Card` theme defined in `THEME_ARCHITECTURE.md` and adds specific Aura styling (e.g., border radius, default elevation).*

### 1.5. TagChip

*   **Purpose:** Represents compact elements, like tags for clothing items or selectable filters.
*   **Style:**
    *   Background Color (Unselected): `Theme.of(context).colorScheme.surfaceVariant`.
    *   Background Color (Selected): `Theme.of(context).colorScheme.secondaryContainer`.
    *   Text Color: `Theme.of(context).colorScheme.onSurface` or `onSecondaryContainer`.
    *   Shape: Stadium shape or rounded rectangle (e.g., `BorderRadius.circular(8.0)`).
*   **States:**
    *   `Unselected`: Default style.
    *   `Selected`: Distinct background/text color.
    *   `Disabled`: Reduced opacity.
*   **Accessibility:**
    *   Minimum Touch Target Size: Ensure the chip itself or its padding meets 48x48px.
    *   Semantic Label: Describe the chip's purpose/value.
*   **Usage (Example):**
    ```dart
    TagChip(
      label: 'Vintage',
      isSelected: isTagSelected('Vintage'), // State check
      onSelected: (bool selected) {
        // Update state in provider/controller
      },
    )
    ```
*   **Note:** Can leverage Material 3 `ChoiceChip` or `InputChip` with custom theming.

### 1.6. StyledTextField

*   **Purpose:** Allows users to input text with a consistent look and feel.
*   **Style:**
    *   Decoration: Standard Material 3 `InputDecoration`.
    *   Focused Border Color: `Theme.of(context).colorScheme.primary`.
    *   Hint Text Style: `Theme.of(context).textTheme.bodyMedium` with reduced opacity (e.g., 60%).
    *   Label Style: `Theme.of(context).textTheme.bodyMedium`.
*   **States:**
    *   `Enabled`: Default style.
    *   `Focused`: Highlighted border.
    *   `Error`: Red border, error text display.
    *   `Disabled`: Reduced opacity.
*   **Accessibility:**
    *   Labels: Use `labelText` or wrap with `Semantics` for clear labeling.
    *   Error Messages: Associate error text with the field for screen readers.
*   **Usage (Example):**
    ```dart
    StyledTextField(
      controller: _textEditingController, // From state management
      labelText: 'Item Name',
      hintText: 'e.g., Blue Jeans',
      errorText: state.errorMessage, // From AsyncValue/Notifier state
      onChanged: (value) {
        // Update state/provider
      },
    )
    ```
*   **Note:** Wrapper around `TextField` or `TextFormField` with consistent decoration and validation wiring.

## 2. Accessibility Compliance

*   **WCAG 2.1 AA Standards:** All components listed in `COMPONENT_LIST.md` must adhere to the Web Content Accessibility Guidelines (WCAG) 2.1 AA level or higher.
*   **Semantic Labels:** Every interactive or informative element must have a clear and concise `semanticsLabel` or be constructed using widgets that inherently provide semantic meaning (e.g., `Text`, `Button`).
*   **Color Contrast:** The visual presentation of text and images of text MUST have a contrast ratio of at least 4.5:1 against the background. All color combinations defined in `STYLE_GUIDE.md` and used by these components MUST meet this criterion.
*   **Touch Targets:** The minimum size for touch targets (buttons, icons, selection boxes) is 48x48 pixels. (All components in `COMPONENT_LIST.md` must meet this criterion).
*   **Timing:** Content that is time-limited MUST either be controllable by the user or provide the user with the option to control the timing.
*   **Understandable:** Navigation and interaction patterns MUST be consistent throughout the application.

## 3. Understandable Interaction Patterns

*   **Consistent Navigation:** Navigation and interaction patterns MUST be consistent throughout the application.
*   **Predictable Outcomes:** User actions SHOULD lead to predictable outcomes. Visual feedback (e.g., loading indicators, state changes) MUST be provided.
*   **Clear Error Handling:** Error messages MUST be clear, specific, and guide the user towards resolution. Error states MUST be visually distinct (e.g., using `error` color from `STYLE_GUIDE.md`).

## 4. Usage Notes

*   When developing a new component, the principles of this guide and `STYLE_GUIDE.md` MUST be taken into account.
*   Properties like `semanticsLabel`, `tooltip` MUST NOT be omitted.
*   Color selections MUST adhere to `STYLE_GUIDE.md` and contrast ratios MUST be checked.
*   Touch targets MUST adhere to the standards in `COMPONENT_LIST.md`.
*   Accessibility (Accessibility) principles are not an "extra feature" but a fundamental user experience principle and MUST be considered at every stage of the project.
