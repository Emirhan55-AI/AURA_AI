# Aura Project Responsiveness Guide (RESPONSIVENESS_GUIDE.md)

**Version:** 2.1

This document defines the responsiveness principles and Flutter application guide to ensure the Aura application behaves consistently and user-friendlyly across different screen sizes (small phones, large phones, tablets) and orientations (portrait/landscape).

## 1. Core Principles

*   **Mobile-First:** Design and develop for the smallest screen size first, then progressively enhance the layout and interactions for larger screens using breakpoints.
*   **Fluid Layouts:** Use flexible layout widgets like `LayoutBuilder`, `Expanded`, `Flexible`, `AspectRatio`, and responsive sizing units (e.g., `dp`, `sp` concepts adapted via `MediaQuery`) instead of fixed pixel dimensions wherever possible.
*   **Scalable Elements:** Ensure UI elements (buttons, cards, images) scale appropriately or rearrange themselves based on available screen width and height. Refer to `COMPONENT_LIST.md` for touch target sizes.
*   **Orientation Awareness:** Design layouts that adapt gracefully to both portrait and landscape orientations. Consider locking orientation for specific screens (e.g., camera view) only if absolutely necessary and justified.
*   **Accessibility (Accessibility):** Pay attention to accessibility principles (touch target, semantic labels). See `ACCESSIBILITY_GUIDE.md`.

## 2. Technical Implementation Guide

### 2.1. Using `MediaQuery`

`MediaQuery` is the primary tool for obtaining information about the current screen, such as size, orientation, and padding (e.g., status bar height).

*   **Accessing Screen Dimensions:**
    ```dart
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    ```
*   **Checking Orientation:**
    ```dart
    final orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.portrait) {
      // Portrait layout
    } else {
      // Landscape layout
    }
    ```
*   **Using Safe Areas:** Wrap content with `SafeArea` to respect notches, status bars, and navigation bars.
    ```dart
    SafeArea(
      child: MyContent(), // Content avoids system UI overlays
    )
    ```

### 2.2. Adaptive Layouts with `LayoutBuilder`

`LayoutBuilder` allows building layouts that adapt to the constraints of their parent widget, making them highly responsive.

*   **Example: Grid/List Switching:**
    ```dart
    LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Wide screen: Use a grid
          return GridView.builder(...);
        } else {
          // Narrow screen: Use a list
          return ListView.builder(...);
        }
      },
    )
    ```

### 2.3. Breakpoints

Define standard breakpoints to differentiate between screen sizes (phone, tablet). These are conceptual and based on `shortestSide`.

*   **Small Phone:** `shortestSide < 600 dp`
*   **Large Phone/Tablet:** `shortestSide >= 600 dp`
*   **Large Tablet:** `shortestSide >= 900 dp` (Can be further divided if needed)

*   **Implementation Example:**
    ```dart
    // In a utility class or provider
    class ScreenBreakpoints {
      static bool isSmallPhone(double shortestSide) => shortestSide < 600;
      static bool isLargePhoneOrTablet(double shortestSide) => shortestSide >= 600;
      static bool isLargeTablet(double shortestSide) => shortestSide >= 900;
    }

    // Usage in widget
    LayoutBuilder(
      builder: (context, constraints) {
        final shortestSide = constraints.maxWidth; // Simplified
        if (ScreenBreakpoints.isLargePhoneOrTablet(shortestSide)) {
          // Adjust layout for larger screens
        }
        // ... build UI
      },
    );
    ```

### 2.4. Responsive Typography

Text sizes should scale based on screen density and width. Use `TextStyle` from `Theme.of(context).textTheme` as a base, which are generally adaptive. Extra scaling can be applied using `MediaQuery` if needed.

*   **Preferred Method:**
    ```dart
    Text('Title', style: Theme.of(context).textTheme.headlineMedium);
    ```
*   **Custom Scaling (if necessary):**
    ```dart
    // Example: Slightly larger text on tablets
    double scaleFactor = 1.0;
    if (MediaQuery.of(context).size.shortestSide >= 600) {
      scaleFactor = 1.2;
    }
    Text(
      'Scaled Title',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize! * scaleFactor,
          ),
    );
    ```

### 2.5. Image Handling

Use `Image.asset` or `Image.network` with appropriate `width`, `height`, and `fit` properties. For different screen densities, provide multiple image assets (e.g., `1.0x`, `2.0x`, `3.0x`).

*   **Responsive Images:**
    ```dart
    // Let the image scale to fit its box while maintaining aspect ratio
    Image.asset(
      'assets/images/header_image.png',
      fit: BoxFit.cover, // Or BoxFit.contain, etc.
      width: double.infinity, // Take full width of parent
      // height can be set or allowed to adjust based on aspectRatio
    );
    ```

### 2.6. Platform-Specific Considerations

While Flutter is cross-platform, subtle differences might arise. Test on both Android and iOS simulators/devices.

*   **Status Bar/Navigation Bar:** Heights can vary slightly. `MediaQuery` and `SafeArea` handle this.
*   **Notch Support:** `SafeArea` is crucial for devices with notches.

## 3. Component Adaptation

Standard components defined in `COMPONENT_LIST.md` must behave responsively.

*   **Cards (`CustomCard`):** Adjust padding/margin and internal layout based on screen size.
*   **Buttons (`PrimaryButton`, etc.):** Maintain minimum touch target size (48x48 dp) regardless of screen size. Text size can scale slightly.
*   **Lists/Grids:** Use `SliverGridDelegateWithMaxCrossAxisExtent` for grids or `LayoutBuilder` to switch between list/grid views.

## 4. Testing Responsiveness

*   **Flutter DevTools:** Use the Device Preview feature to simulate various screen sizes and orientations.
*   **Physical Devices:** Test on actual devices of different sizes.
*   **Simulator/Emulator:** Use a range of simulated devices (iPhone SE, iPhone 14 Pro Max, various Android phones, iPad) in both portrait and landscape modes.
*   **Golden Tests:** For critical responsive UIs, consider using golden tests with different screen sizes/orientations to catch visual regressions.

## 5. Usage Notes

*   UI elements should never be designed with fixed widths/heights in logical pixels (e.g., `width: 300`) unless absolutely necessary for a very specific design constraint.
*   Always use `LayoutBuilder` or `MediaQuery` to make layout decisions based on available space.
*   `SafeArea` should wrap top-level screens to respect system UI overlays.
*   Orientation changes should be handled gracefully, preserving state where possible (e.g., using `AutomaticKeepAliveClientMixin` for pages in a `PageView`).
*   Accessibility (Accessibility) principles must be considered at every stage of the project. (See `ACCESSIBILITY_GUIDE.md`)
