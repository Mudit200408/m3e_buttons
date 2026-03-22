# m3e_buttons

[![Flutter](https://img.shields.io/badge/Flutter-%230175C2?style=flat-square&logo=flutter)](https://flutter.dev)
[![Pub Version](https://img.shields.io/pub/v/m3e_buttons?style=flat-square)](https://pub.dev/packages/m3e_buttons)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)

Material 3 Expressive button components for Flutter with spring motion, toggle groups, and split menus.

## Features

- Five button styles: filled, tonal, elevated, outlined, text.
- Five size presets plus custom sizing via M3EButtonSize.custom.
- Spring-based motion through M3EMotion presets and custom values.
- Toggle buttons and connected toggle groups.
- Split buttons with popup or bottom-sheet menus.
- Decoration-based customization for color, radius, motion, and haptics.

## Installation

```bash
flutter pub add m3e_buttons
```

Or in pubspec.yaml:

```yaml
dependencies:
  m3e_buttons: ^0.1.0
```

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        M3EButton(
          label: const Text('Save'),
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        M3EToggleButton(
          icon: const Icon(Icons.favorite_border),
          checkedIcon: const Icon(Icons.favorite),
          onCheckedChange: (checked) {},
        ),
        const SizedBox(height: 12),
        SplitButtonM3E<String>(
          label: 'Actions',
          leadingIcon: Icons.more_horiz,
          items: const [
            SplitButtonM3EItem(value: 'edit', child: Text('Edit')),
            SplitButtonM3EItem(value: 'share', child: Text('Share')),
          ],
          onSelected: (value) {},
          onPressed: () {},
        ),
      ],
    );
  }
}
```

## Public components

### M3EButton

Single action button for standard Material patterns.

Typical use:

```dart
M3EButton(
  style: M3EButtonStyle.filled,
  size: M3EButtonSize.md,
  icon: const Icon(Icons.send),
  label: const Text('Send'),
  onPressed: () {},
)
```

### M3EToggleButton

Stateful toggle with expressive radius morphing.

Typical use:

```dart
M3EToggleButton(
  icon: const Icon(Icons.bookmark_border),
  checkedIcon: const Icon(Icons.bookmark),
  decoration: const M3EToggleButtonDecoration(
    haptic: M3EHapticFeedback.light,
  ),
  onCheckedChange: (value) {},
)
```

### M3EToggleButtonGroup

Group container for single-select or multi-select toggle patterns.

Typical use:

```dart
M3EToggleButtonGroup(
  selectedIndex: 0,
  onSelectedIndexChanged: (index) {},
  actions: const [
    M3EToggleButtonGroupAction(icon: Icon(Icons.format_bold)),
    M3EToggleButtonGroupAction(icon: Icon(Icons.format_italic)),
  ],
)
```

### SplitButtonM3E

Dual-segment control with primary action and menu action.

Typical use:

```dart
SplitButtonM3E<String>(
  label: 'Sort',
  leadingIcon: Icons.sort,
  items: const [
    SplitButtonM3EItem(value: 'name', child: Text('Name')),
    SplitButtonM3EItem(value: 'date', child: Text('Date')),
  ],
  onSelected: (value) {},
  onPressed: () {},
)
```

## Customization model

- Use M3EButtonDecoration for shared button styling.
- Use M3EToggleButtonDecoration for toggle-specific checked state and group radius behavior.
- Use M3ESplitButtonDecoration for split-segment and menu styling.
- Use M3EMotion presets or M3EMotion.custom for spring tuning.

## Accessibility guidance

- Provide semanticLabel when the visible icon or short text is ambiguous.
- Keep enabled and disabled states visually distinct (foreground and background contrast).
- Validate keyboard operation for focusable controls in desktop/web targets.
- Prefer explicit labels for icon-only controls in production UIs.

## Architecture overview

- Public API entry point: lib/m3e_buttons.dart.
- Component layer: lib/src/components.
- Styling layer: lib/src/style.
- Internal implementation details: lib/src/internal.

Only public exports from package:m3e_buttons/m3e_buttons.dart are considered stable API.

## Testing

Run package tests:

```bash
flutter test
```

Run analyzer:

```bash
flutter analyze
```

Run the example app:

```bash
cd example
flutter pub get
flutter run
```

## Release checklist

- Follow the full process in RELEASE.md.
- Ensure CI is green for package and example checks.
- Run pub publish --dry-run before publishing.

## License

MIT License. See LICENSE.
