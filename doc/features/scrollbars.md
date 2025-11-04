# Scrollbars

TrinaGrid provides extensive customization options for scrollbars, allowing you to create a better user experience, especially for desktop applications.

## Overview

Scrollbars in TrinaGrid can be customized through the `scrollbar` property in `TrinaGridConfiguration`, which provides a comprehensive set of options to control scrollbar appearance and behavior.

![scrollbars](https://raw.githubusercontent.com/doonfrs/trina_grid/refs/heads/main/doc/assets/scrollbars.gif)

## Basic Usage

By default, TrinaGrid shows scrollbars when needed, but they can be configured to always be visible:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    scrollbar: TrinaGridScrollbarConfig(
      isAlwaysShown: true, // Prevents scrollbars from fading out
    ),
  ),
)
```

## Advanced Scrollbar Customization

For more detailed control over the grid's scrollbars, you can use additional properties of `TrinaGridScrollbarConfig`:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    scrollbar: TrinaGridScrollbarConfig(
      // Visibility settings
      isAlwaysShown: true,    // Prevents scrollbars from fading out after scrolling stops
      thumbVisible: true,     // Whether the scrollbar thumb is visible at all
      showTrack: true,        // Whether to show the track background
      showHorizontal: true,   // Whether to show the horizontal scrollbar
      showVertical: true,     // Whether to show the vertical scrollbar
      
      // Appearance settings
      thickness: 8.0,                          // Thickness of the scrollbar
      minThumbLength: 40.0,                    // Minimum length of the scrollbar thumb
      thumbColor: Colors.blue.withOpacity(0.6), // Color of the scrollbar thumb
      trackColor: Colors.grey.withOpacity(0.2), // Color of the scrollbar track
      thumbHoverColor: Colors.blue.withOpacity(0.8), // Color when hovering over the thumb
      trackHoverColor: Colors.grey.withOpacity(0.3), // Color when hovering over the track
      isDraggable: true,                       // Enable scrollbar thumb dragging
    ),
  ),
)
```

## Configuration Options

### TrinaGridScrollbarConfig

The `TrinaGridScrollbarConfig` class provides the following key options for scrollbar customization:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `isAlwaysShown` | `bool` | `false` | If true, scrollbars remain visible all the time. If false, they appear during scrolling and fade out after about 3 seconds of inactivity. |
| `thumbVisible` | `bool` | `true` | Whether the scrollbar thumb is visible at all. If false, scrollbars won't show even during scrolling. |
| `showTrack` | `bool` | `true` | Whether to show the scrollbar track background. |
| `showHorizontal` | `bool` | `true` | Whether to show the horizontal scrollbar. |
| `showVertical` | `bool` | `true` | Whether to show the vertical scrollbar. |
| `thickness` | `double` | `8.0` | Thickness of the scrollbar. |
| `minThumbLength` | `double` | `40.0` | Minimum length of the scrollbar thumb. |
| `thumbColor` | `Color?` | `null` | Color of the scrollbar thumb (defaults to semi-transparent gray if null). |
| `trackColor` | `Color?` | `null` | Color of the scrollbar track (defaults to light gray if null). |
| `thumbHoverColor` | `Color?` | `null` | Color of the scrollbar thumb when hovered (defaults to a more opaque version of thumbColor if null). |
| `trackHoverColor` | `Color?` | `null` | Color of the scrollbar track when hovered (defaults to a more opaque version of trackColor if null). |
| `isDraggable` | `bool` | `true` | Whether scrollbar thumbs can be dragged with mouse or touch to scroll content. |
| `smoothScrolling` | `bool` | `true` | Whether to use smooth scrolling animation for mouse wheel input. When enabled, scrolling animates smoothly instead of jumping instantly. |

## Examples

### Always Visible Scrollbars

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    scrollbar: TrinaGridScrollbarConfig(
      isAlwaysShown: true,
    ),
  ),
)
```

### Custom Scrollbar Colors

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    scrollbar: TrinaGridScrollbarConfig(
      thumbColor: Colors.blue.withOpacity(0.6),
      trackColor: Colors.grey.withOpacity(0.2),
    ),
  ),
)
```

### Hiding Horizontal Scrollbar

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    scrollbar: TrinaGridScrollbarConfig(
      showHorizontal: false,
      showVertical: true,
    ),
  ),
)
```

### Completely Hiding Scrollbars

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    scrollbar: TrinaGridScrollbarConfig(
      thumbVisible: false,
    ),
  ),
)
```

### Thicker Scrollbars for Touch Devices

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    scrollbar: TrinaGridScrollbarConfig(
      thickness: 12.0,
      minThumbLength: 60.0,
    ),
  ),
)
```

### Disabling Scrollbar Dragging

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    scrollbar: TrinaGridScrollbarConfig(
      isDraggable: false, // Disable scrollbar thumb dragging
    ),
  ),
)
```

### Custom Hover Colors

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    scrollbar: TrinaGridScrollbarConfig(
      thumbColor: Colors.blue.withOpacity(0.6),
      thumbHoverColor: Colors.blue.withOpacity(0.9),
      trackColor: Colors.grey.withOpacity(0.2),
      trackHoverColor: Colors.grey.withOpacity(0.4),
    ),
  ),
)
```

### Smooth Scrolling

**Enabled by Default** - TrinaGrid uses smooth scrolling for mouse wheel input by default, providing a polished user experience similar to macOS/iOS:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    scrollbar: TrinaGridScrollbarConfig(
      smoothScrolling: true, // Default, can be omitted
    ),
  ),
)
```

To disable smooth scrolling and use instant jumping (legacy behavior):

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    scrollbar: TrinaGridScrollbarConfig(
      smoothScrolling: false, // Instant scroll jumps
    ),
  ),
)
```

**How it works:**
- Mouse wheel scrolling animates smoothly to the target position
- Uses easing animation for natural deceleration
- Cancels automatically when you start dragging the scrollbar
- Responsive to direction changes while scrolling

## Scroll Physics

The `scrollPhysics` parameter allows you to customize the scrolling behavior of the grid beyond what the scrollbar configuration provides. This controls how the grid responds to user scrolling gestures and scroll commands.

### Basic Usage

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  scrollPhysics: const NeverScrollableScrollPhysics(),
)
```

### Available Scroll Physics

Flutter provides several built-in `ScrollPhysics` that you can use:

#### NeverScrollableScrollPhysics

Disables all scrolling in the grid. Useful when you want to display a fixed grid without scrolling capability.

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  scrollPhysics: const NeverScrollableScrollPhysics(),
)
```

#### ClampingScrollPhysics

Provides a clamping scroll effect (Android-style). The scroll position cannot go beyond the content bounds without resistance.

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  scrollPhysics: const ClampingScrollPhysics(),
)
```

#### BouncingScrollPhysics

Provides a bouncing scroll effect (iOS-style). The scroll can go slightly beyond the content bounds and bounces back.

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  scrollPhysics: const BouncingScrollPhysics(),
)
```

#### AlwaysScrollableScrollPhysics

Forces the grid to be scrollable even if the content fits within the viewport.

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  scrollPhysics: const AlwaysScrollableScrollPhysics(),
)
```

### Default Behavior

When `scrollPhysics` is not specified (or set to `null`), TrinaGrid uses the platform-specific default scroll physics from `MaterialScrollBehavior`:
- Android: Clamping scroll physics
- iOS/macOS: Bouncing scroll physics

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  // Uses platform-specific default
)
```

### Combining Scroll Physics

You can combine multiple scroll physics using the `applyTo` method for more complex behaviors:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  scrollPhysics: const BouncingScrollPhysics().applyTo(
    const AlwaysScrollableScrollPhysics(),
  ),
)
```

### Use Cases

**Disable scrolling for embedded grids:**
```dart
// Useful when the grid is inside a scrollable parent
TrinaGrid(
  columns: columns,
  rows: rows,
  scrollPhysics: const NeverScrollableScrollPhysics(),
)
```

**Force consistent platform behavior:**
```dart
// Always use iOS-style bouncing on all platforms
TrinaGrid(
  columns: columns,
  rows: rows,
  scrollPhysics: const BouncingScrollPhysics(),
)
```

**Customize overscroll behavior:**
```dart
// Prevent overscroll glow effect on Android
TrinaGrid(
  columns: columns,
  rows: rows,
  scrollPhysics: const ClampingScrollPhysics(),
)
```

## Best Practices

1. **Desktop Applications**: For desktop applications, consider setting `isAlwaysShown: true` to make scrollbars always visible, improving usability.

2. **Touch Devices**: For touch devices, consider using thicker scrollbars by increasing the `thickness` value.

3. **Consistent Styling**: Match scrollbar colors with your application's theme for a consistent look and feel.

4. **Accessibility**: Ensure scrollbars are visible enough for all users, especially those with visual impairments.

5. **Behavior Clarification**: Remember that:
   - `isAlwaysShown: true` makes scrollbars permanently visible (never fades out)
   - `isAlwaysShown: false` makes scrollbars appear during scrolling and fade out after about 3 seconds
   - `thumbVisible: false` completely hides scrollbars regardless of the `isAlwaysShown` setting

6. **Smooth Scrolling**: The smooth scrolling feature is enabled by default and provides a better user experience for mouse wheel users. Consider disabling it only if you have specific performance concerns or prefer instant scrolling behavior.

7. **Scroll Physics**: Choose appropriate scroll physics based on your use case:
   - Use `NeverScrollableScrollPhysics()` when the grid is inside a scrollable parent to prevent scroll conflicts
   - Use platform-specific physics (default) for the most native feel on each platform
   - Consider `AlwaysScrollableScrollPhysics()` if you need scrolling gestures to work even when content fits the viewport

## Limitations

- The scrollbar settings only apply to the grid's main scrollbars, not to any scrollable widgets inside cells.
- Some scrollbar properties might not be available on all platforms due to platform-specific implementations.

## Related Features

- [Column Freezing](column-freezing.md) - Learn how to freeze columns in place while scrolling horizontally
- [Frozen Rows](frozen-rows.md) - Learn how to freeze rows in place while scrolling vertically
