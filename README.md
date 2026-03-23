# m3e_buttons

[![Flutter](https://img.shields.io/badge/Flutter-%230175C2?style=flat-square&logo=flutter)](https://flutter.dev)
[![Pub Version](https://img.shields.io/pub/v/m3e_buttons?style=flat-square)](https://pub.dev/packages/m3e_buttons)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)
[![Material 3 Expressive](https://img.shields.io/badge/Material%203-Expressive-purple?style=flat-square)](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)

> **Buttons the way they were meant to feel.** Spring-physics. Shape morphing. Five styles, five sizes, zero compromises.

![Jetpack Compose Inspiration](doc/jetpack-compose-example.gif)

Inspired by the [Jetpack Compose](https://developer.android.com/jetpack/compose) implementation of **Material 3 Expressive** buttons, `m3e_buttons` brings the same spring-driven shape animations, rich customisation model, and tactile responsiveness to Flutter — without writing a single line of animation code yourself.

This is **v0.0.1** — the initial release. Every API is documented, every animation is tuned, and every pixel is intentional.

---

## Why m3e_buttons?

Flutter's built-in buttons are solid, but they don't animate their shape on press. Material 3 Expressive changes that by specifying a spring-physics-based **radius squish** on press, a subtle **expansion on hover**, and a meaningful **shape morph** for toggle state. `m3e_buttons` implements all of that, faithfully, in pure Flutter.

- **Spring animations** — Radius, padding, and focus rings all animate with `motor`-backed spring physics.
- **Five styles** — `filled`, `tonal`, `elevated`, `outlined`, `text` — just like the spec.
- **Five size presets** — `xs`, `sm`, `md`, `lg`, `xl` — plus a fully custom `M3EButtonSize.custom(...)`.
- **Toggle buttons** — With icon/label swap animations and expressive checked-state shape morphing.
- **Connected toggle groups** — Neighbor-squish, single- and multi-select, overflow handling.
- **Split buttons** — Dual-segment with popup, bottom sheet, or your own custom menu.
- **Decoration-based styling** — No `ButtonStyle` juggling. One `M3EButtonDecoration` controls everything.
- **Haptic feedback** — Four levels, baked into the decoration model.

---

## Screenshots

| Button | Split Button | Toggle Button Group |
|--------|-------------|-------------------|
| ![M3E Button Example](doc/m3e-button-ex.gif) | ![Split Button Example](doc/split-button-ex.gif) | ![Connected Button Example](doc/connected-button-example.gif) |

### Interaction States

| Hovered — M3EButton | Focused — M3EButton | Focused — Toggle |
|---------------------|---------------------|-----------------|
| ![Hovered M3EButton](doc/hovered-m3ebutton.gif) | ![Focused M3EButton](doc/focused-m3ebutton.gif) | ![Focused Toggle](doc/focused-togglebutton.gif) |

| Split Button Menu | Hovered Split | Toggle Overflow |
|-------------------|--------------|----------------|
| ![Split Menu](doc/split-button-menu-ex.gif) | ![Hovered Split](doc/hovered-splitbutton.gif) | ![Toggle Overflow](doc/togglebutton-overflow.gif) |

---

## Installation

```bash
flutter pub add m3e_buttons
```

Or add it manually to `pubspec.yaml`:

```yaml
dependencies:
  m3e_buttons: ^0.0.1
```

Then import the package:

```dart
import 'package:m3e_buttons/m3e_buttons.dart';
```

---

## Quick Start

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
        // Standard action button
        M3EButton(
          label: const Text('Save'),
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        // Stateful toggle
        M3EToggleButton(
          icon: const Icon(Icons.favorite_border),
          checkedIcon: const Icon(Icons.favorite),
          onCheckedChange: (checked) {},
        ),
        const SizedBox(height: 12),
        // Split button with dropdown menu
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

---

## Components

---

### `M3EButton`

The standard single-action button. Five visual styles. Five sizes. Spring-animated radius squish on press, expansion on hover, and a focus ring that follows the animated shape.

![M3EButton Example](doc/m3e-button-ex.gif)

```dart
M3EButton(
  style: M3EButtonStyle.filled,
  size: M3EButtonSize.md,
  shape: M3EButtonShape.round,
  icon: const Icon(Icons.send),
  label: const Text('Send'),
  onPressed: () {},
)
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onPressed` | `VoidCallback?` | **required** | Called when pressed. Pass `null` to disable. |
| `label` | `Widget?` | `null` | Text label. At least one of `label` or `icon` must be provided. |
| `icon` | `Widget?` | `null` | Leading icon displayed before the label. |
| `style` | `M3EButtonStyle` | `filled` | Visual style — see [`M3EButtonStyle`](#m3ebuttonstyle). |
| `size` | `M3EButtonSize` | `sm` | Size preset — see [`M3EButtonSize`](#m3ebuttonsize). |
| `shape` | `M3EButtonShape` | `round` | Corner radius strategy — see [`M3EButtonShape`](#m3ebuttonshape). |
| `enabled` | `bool` | `true` | Disables the button when false (keeps it in the tree). |
| `decoration` | `M3EButtonDecoration?` | `null` | Decoration bundle for colors, radius, motion, haptics — see [`M3EButtonDecoration`](#m3ebuttondecoration). |
| `focusNode` | `FocusNode?` | `null` | External focus node for keyboard navigation. |
| `autofocus` | `bool` | `false` | Focuses the button on mount. |
| `onFocusChange` | `ValueChanged<bool>?` | `null` | Called when focus state changes. |
| `semanticLabel` | `String?` | `null` | Accessibility label, merged on top of the button's own semantics. |
| `mouseCursor` | `MouseCursor` | `SystemMouseCursors.click` | Cursor shown when hovering. |
| `onLongPress` | `VoidCallback?` | `null` | Called on long-press. |
| `onHover` | `ValueChanged<bool>?` | `null` | Called when hover state changes. |
| `enableFeedback` | `bool` | `true` | Whether to show a ripple/splash and native haptic on press. |
| `splashFactory` | `InteractiveInkFeatureFactory?` | `InkRipple.splashFactory` | Custom ink splash factory. |
| `statesController` | `WidgetStatesController?` | `null` | Programmatic control of pressed/hovered/focused states. |

---

### `M3EToggleButton`

A stateful toggle with expressive **shape morphing** between unchecked (round) and checked (square) states. Supports icon-only, icon + label, or label-only content, with smooth animated label transitions.

![Toggle Button Example](doc/toggle-button-ex.gif)

```dart
M3EToggleButton(
  icon: const Icon(Icons.bookmark_border),
  checkedIcon: const Icon(Icons.bookmark),
  label: const Text('Save'),
  checkedLabel: const Text('Saved'),
  decoration: const M3EToggleButtonDecoration(
    haptic: M3EHapticFeedback.light,
    motion: M3EMotion.expressiveSpatialDefault,
  ),
  onCheckedChange: (checked) {},
)
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onCheckedChange` | `ValueChanged<bool>` | **required** | Called when the toggle state changes. |
| `icon` | `Widget?` | `null` | Icon in unchecked state. |
| `checkedIcon` | `Widget?` | `null` | Icon in checked state. Falls back to `icon`. |
| `label` | `Widget?` | `null` | Text label (makes button content-width). |
| `checkedLabel` | `Widget?` | `null` | Label in checked state. Falls back to `label`. |
| `checked` | `bool?` | `null` | External checked state. `null` = internal state management. |
| `style` | `M3EButtonStyle` | `filled` | Visual style — see [`M3EButtonStyle`](#m3ebuttonstyle). |
| `size` | `M3EButtonSize` | `sm` | Size preset — see [`M3EButtonSize`](#m3ebuttonsize). |
| `enabled` | `bool` | `true` | Enables or disables the toggle. |
| `decoration` | `M3EToggleButtonDecoration?` | `null` | Full decoration bundle — see [`M3EToggleButtonDecoration`](#m3etogglebuttondecoration). |
| `focusNode` | `FocusNode?` | `null` | External focus node. |
| `autofocus` | `bool` | `false` | Focuses button on mount. |
| `onFocusChange` | `ValueChanged<bool>?` | `null` | Called when focus state changes. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |
| `mouseCursor` | `MouseCursor?` | `null` | Cursor on hover. |
| `onLongPress` | `VoidCallback?` | `null` | Called on long-press. |
| `onHover` | `ValueChanged<bool>?` | `null` | Called when hover changes. |
| `enableFeedback` | `bool` | `true` | Ripple and native haptic on press. |
| `splashFactory` | `InteractiveInkFeatureFactory?` | `InkRipple.splashFactory` | Custom ink splash factory. |
| `statesController` | `WidgetStatesController?` | `null` | Programmatic state control. |

> **Tip:** `isGroupConnected`, `isFirstInGroup`, and `isLastInGroup` are managed automatically when using `M3EToggleButtonGroup`. You don't need to set them manually.

---

### `M3EToggleButtonGroup`

A horizontal (or vertical) row of `M3EToggleButton`s with **neighbor-squish** animation — when a button is pressed, it expands and its neighbors compress. Supports single-select and multi-select modes, connected group layout, and overflow handling.

![Connected Group Example](doc/connected-button-example.gif)
![Overflow Example](doc/togglebutton-overflow.gif)

```dart
// Single-select connected group
M3EToggleButtonGroup(
  type: M3EButtonGroupType.connected,
  selectedIndex: _selected,
  onSelectedIndexChanged: (index) => setState(() => _selected = index),
  actions: const [
    M3EToggleButtonGroupAction(icon: Icon(Icons.format_bold), semanticLabel: 'Bold'),
    M3EToggleButtonGroupAction(icon: Icon(Icons.format_italic), semanticLabel: 'Italic'),
    M3EToggleButtonGroupAction(icon: Icon(Icons.format_underline), semanticLabel: 'Underline'),
  ],
)
```

```dart
// Multi-select standard group with labels
M3EToggleButtonGroup(
  selectedIndices: _selectedIndices,
  onSelectedIndicesChanged: (indices) => setState(() => _selectedIndices = indices),
  size: M3EButtonSize.md,
  neighborSquish: true,
  actions: [
    M3EToggleButtonGroupAction(icon: const Icon(Icons.music_note), label: const Text('Music')),
    M3EToggleButtonGroupAction(icon: const Icon(Icons.movie), label: const Text('Movies')),
    M3EToggleButtonGroupAction(icon: const Icon(Icons.book), label: const Text('Books')),
  ],
)
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `actions` | `List<M3EToggleButtonGroupAction>` | **required** | The list of button actions in the group. |
| `type` | `M3EButtonGroupType` | `standard` | `standard` (gaps) or `connected` (shared edges). |
| `shape` | `M3EButtonShape` | `round` | Corner radius strategy for all buttons. |
| `size` | `M3EButtonSize` | `sm` | Size preset for all buttons. |
| `style` | `M3EButtonStyle` | `filled` | Visual style for all buttons. |
| `density` | `M3EButtonGroupDensity` | `regular` | Spacing compactness: `regular` or `compact`. |
| `spacing` | `double?` | `null` | Custom spacing in logical pixels. Overrides `density`. |
| `direction` | `Axis` | `horizontal` | `horizontal` for rows, `vertical` for columns. |
| `selectedIndex` | `int?` | `null` | Controlled single-select state. |
| `selectedIndices` | `Set<int>?` | `null` | Controlled multi-select state. |
| `onSelectedIndexChanged` | `ValueChanged<int?>?` | `null` | Called on single-select change. Emits `null` when deselected. |
| `onSelectedIndicesChanged` | `ValueChanged<Set<int>>?` | `null` | Called on multi-select change. |
| `neighborSquish` | `bool` | `true` | Whether pressed button expands and neighbors compress. |
| `expandedRatio` | `double` | `0.15` | How much the pressed button expands relative to its natural width. |
| `haptic` | `M3EHapticFeedback` | `none` | Group-level haptic feedback level. |
| `enableFeedback` | `bool` | `true` | Ripple and native haptic across the group. |
| `decoration` | `M3EToggleButtonDecoration?` | `null` | Group-level decoration (per-action decoration takes precedence). |
| `semanticLabel` | `String?` | `null` | Accessibility label for the whole group. |
| `clipBehavior` | `Clip` | `none` | Clipping applied to the group container. |
| `overflow` | `M3EButtonGroupOverflow` | `scroll` | How to handle overflow. |
| `overflowIcon` | `Widget?` | `null` | Icon for overflow trigger buttons. |
| `overflowMenuStyle` | `M3EButtonGroupOverflowMenuStyle` | `popup` | `popup` or `bottomSheet` for overflow menus. |
| `overflowPopupDecoration` | `M3EOverflowPopupDecoration` | `M3EOverflowPopupDecoration()` | Styles the overflow popup. |
| `overflowBottomSheetDecoration` | `M3EOverflowBottomSheetDecoration` | `M3EOverflowBottomSheetDecoration()` | Styles the overflow bottom sheet. |
| `overflowStrategy` | `OverflowStrategy?` | `null` | Custom overflow strategy (overrides `overflow` enum). |

#### `M3EToggleButtonGroupAction`

Each action maps one-to-one to a button inside the group.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `icon` | `Widget?` | `null` | Icon in unchecked state. At least `icon` or `label` required. |
| `checkedIcon` | `Widget?` | `null` | Icon in checked state. Falls back to `icon`. |
| `label` | `Widget?` | `null` | Text label. Makes the button content-width. |
| `checkedLabel` | `Widget?` | `null` | Label in checked state. Falls back to `label`. |
| `checked` | `bool?` | `null` | Per-action controlled checked state. Do not use with group-level `selectedIndex`. |
| `enabled` | `bool` | `true` | Whether this action is enabled. |
| `decoration` | `M3EToggleButtonDecoration?` | `null` | Per-button decoration override. |
| `width` | `double?` | `null` | Fixed custom width overriding natural content width. |
| `focusNode` | `FocusNode?` | `null` | External focus node for this button. |
| `autofocus` | `bool` | `false` | Focuses this button on mount. |
| `onFocusChange` | `ValueChanged<bool>?` | `null` | Called when focus state changes. |
| `semanticLabel` | `String?` | `null` | Accessibility label for this action. |
| `enableFeedback` | `bool?` | `null` | Overrides group `enableFeedback` for this button. |

---

### `SplitButtonM3E<T>`

A dual-segment button — a primary action on the left, a chevron-triggered dropdown on the right. The trailing segment morphs to a circle when the menu is open on `md`, `lg`, and `xl` sizes.

![Split Button Example](doc/split-button-ex.gif)
![Split Button Menu](doc/split-button-menu-ex.gif)

```dart
SplitButtonM3E<String>(
  label: 'Sort',
  leadingIcon: Icons.sort,
  style: M3EButtonStyle.filled,
  size: M3EButtonSize.md,
  items: const [
    SplitButtonM3EItem(value: 'name', child: Text('By Name')),
    SplitButtonM3EItem(value: 'date', child: Text('By Date')),
    SplitButtonM3EItem(value: 'size', child: Text('By Size')),
  ],
  onSelected: (value) => print('Selected: $value'),
  onPressed: () => print('Primary action'),
  leadingTooltip: 'Sort',
  trailingTooltip: 'More sort options',
)
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `items` | `List<SplitButtonM3EItem<T>>?` | **required\*** | Menu items shown in the dropdown. |
| `onSelected` | `ValueChanged<T>?` | `null` | Called when a menu item is selected. |
| `onPressed` | `VoidCallback?` | `null` | Called when the leading segment is pressed. |
| `label` | `String?` | `null` | Text label on the leading segment. |
| `leadingIcon` | `IconData?` | `null` | Leading icon on the primary segment. |
| `size` | `M3EButtonSize` | `sm` | Size preset. |
| `shape` | `M3EButtonShape` | `round` | Corner radius strategy. |
| `style` | `M3EButtonStyle` | `filled` | Visual style. `text` is not supported. |
| `trailingAlignment` | `SplitButtonM3ETrailingAlignment` | `opticalCenter` | `opticalCenter` compensates for the chevron; `geometricCenter` makes both segments equal width. |
| `leadingTooltip` | `String?` | `null` | Tooltip for the leading segment. |
| `trailingTooltip` | `String?` | `null` | Tooltip for the trailing (chevron) segment. |
| `enabled` | `bool` | `true` | Disables both segments. |
| `menuBuilder` | `List<PopupMenuEntry<T>> Function(BuildContext)?` | `null` | Custom menu builder. Overrides `items`. |
| `decoration` | `M3ESplitButtonDecoration?` | `null` | Full decoration bundle. |
| `selectedValue` | `T?` | `null` | Currently selected value (for showing selection state in menu). |
| `onMultiSelected` | `void Function(Set<T>)?` | `null` | For multi-select mode. |
| `mouseCursor` | `MouseCursor?` | `null` | Cursor on hover. |
| `statesController` | `WidgetStatesController?` | `null` | Programmatic state control. |
| `focusNode` | `FocusNode?` | `null` | External focus node for the leading segment. |
| `autofocus` | `bool` | `false` | Focuses leading segment on mount. |
| `onFocusChange` | `ValueChanged<bool>?` | `null` | Called when leading segment focus changes. |
| `onLongPress` | `VoidCallback?` | `null` | Called on long-press of leading segment. |
| `onHover` | `ValueChanged<bool>?` | `null` | Called when hover changes. |
| `enableFeedback` | `bool` | `true` | Ripple and native haptic on press. |
| `splashFactory` | `InteractiveInkFeatureFactory?` | `InkRipple.splashFactory` | Custom ink splash factory. |

> \* Either `items` or `menuBuilder` must be provided.

#### `SplitButtonM3EItem<T>`

```dart
SplitButtonM3EItem<String>(
  value: 'edit',
  child: const Text('Edit'),
)
```

---

## Decoration System

All decoration classes are `@immutable` and support `copyWith` for incremental overrides. Pass `null` for any field to use the token defaults.

---

### `M3EButtonDecoration`

Applied to `M3EButton` via the `decoration` parameter.

```dart
M3EButton(
  decoration: M3EButtonDecoration(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
    motion: M3EMotion.expressiveSpatialFast,
    haptic: M3EHapticFeedback.medium,
    pressedRadius: 8.0,
    hoveredRadius: 20.0,
  ),
  label: const Text('Custom'),
  onPressed: () {},
)
```

| Field | Type | Description |
|-------|------|-------------|
| `backgroundColor` | `Color?` | Button fill color. |
| `foregroundColor` | `Color?` | Text and icon color. |
| `disabledBackgroundColor` | `Color?` | Background when disabled. |
| `disabledForegroundColor` | `Color?` | Foreground when disabled. |
| `borderSide` | `BorderSide?` | Custom border. |
| `borderRadius` | `BorderRadius?` | Fixed resting border radius (overrides token shape). |
| `motion` | `M3EMotion?` | Spring physics preset for animations. |
| `haptic` | `M3EHapticFeedback?` | Haptic feedback on press. |
| `size` | `M3EButtonSize?` | Override the size token (height, padding, icon size). |
| `hoveredRadius` | `double?` | Corner radius when hovered. |
| `pressedRadius` | `double?` | Corner radius during the press squish. |
| `mouseCursor` | `MouseCursor?` | Cursor on hover. |
| `overlayColor` | `WidgetStateProperty<Color?>?` | Custom overlay for pressed/hovered states. |
| `surfaceTintColor` | `WidgetStateProperty<Color?>?` | Surface tint (filled/tonal only). |

---

### `M3EToggleButtonDecoration`

Applied to `M3EToggleButton` or `M3EToggleButtonGroup` via the `decoration` parameter.

```dart
M3EToggleButton(
  decoration: M3EToggleButtonDecoration(
    backgroundColor: Colors.grey.shade200,
    foregroundColor: Colors.grey.shade700,
    checkedBackgroundColor: Colors.indigo,
    checkedForegroundColor: Colors.white,
    checkedRadius: 8.0,
    uncheckedRadius: 24.0,
    haptic: M3EHapticFeedback.light,
  ),
  icon: const Icon(Icons.star_border),
  checkedIcon: const Icon(Icons.star),
  onCheckedChange: (v) {},
)
```

| Field | Type | Description |
|-------|------|-------------|
| `backgroundColor` | `Color?` | Unchecked background color. |
| `foregroundColor` | `Color?` | Unchecked text/icon color. |
| `checkedBackgroundColor` | `Color?` | Background color when checked. |
| `checkedForegroundColor` | `Color?` | Text/icon color when checked. |
| `disabledBackgroundColor` | `Color?` | Background when disabled. |
| `disabledForegroundColor` | `Color?` | Foreground when disabled. |
| `borderSide` | `BorderSide?` | Custom border. |
| `motion` | `M3EMotion?` | Spring physics preset. |
| `haptic` | `M3EHapticFeedback?` | Haptic on press. |
| `checkedRadius` | `double?` | Corner radius in checked state. |
| `uncheckedRadius` | `double?` | Corner radius in unchecked state. |
| `pressedRadius` | `double?` | Corner radius during press squish. |
| `hoveredRadius` | `double?` | Corner radius when hovered. |
| `connectedInnerRadius` | `double?` | Inner corner radius for connected groups. |
| `connectedHoveredInnerRadius` | `double?` | Inner corner radius for hovered connected buttons. |
| `size` | `M3EButtonSize?` | Size token override. |
| `mouseCursor` | `MouseCursor?` | Cursor on hover. |
| `overlayColor` | `WidgetStateProperty<Color?>?` | Custom overlay color. |
| `surfaceTintColor` | `WidgetStateProperty<Color?>?` | Surface tint. |

---

### `M3ESplitButtonDecoration`

Applied to `SplitButtonM3E` via the `decoration` parameter.

```dart
SplitButtonM3E<String>(
  decoration: M3ESplitButtonDecoration(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
    trailingBackgroundColor: Colors.teal.shade700,
    menuBackgroundColor: Colors.teal.shade800,
    menuForegroundColor: Colors.white,
    haptic: M3EHapticFeedback.light,
  ),
  items: const [...],
  onSelected: (v) {},
  onPressed: () {},
)
```

Key fields include `backgroundColor`, `foregroundColor`, `trailingBackgroundColor`, `trailingForegroundColor`, `disabledBackgroundColor`, `disabledForegroundColor`, `borderSide`, `motion`, `haptic`, `gap`, `menuBackgroundColor`, `menuForegroundColor`, `leadingCustomSize`, `trailingCustomSize`, `trailingSelectedRadius`, `overlayColor`, and `surfaceTintColor`.

---

## Enums & Tokens

### `M3EButtonStyle`

| Value | Description |
|-------|-------------|
| `filled` | Solid primary-container background. Highest prominence. |
| `tonal` | Secondary-container tinted background. Medium prominence. |
| `elevated` | Surface color with a drop shadow. |
| `outlined` | Transparent background with a visible border. |
| `text` | No background or border. Lowest prominence. |

### `M3EButtonSize`

| Preset | Height | Description |
|--------|--------|-------------|
| `xs` | 32 dp | Compact, inline contexts. |
| `sm` | 40 dp | Standard default. |
| `md` | 56 dp | Prominent actions. |
| `lg` | 96 dp | Hero-level actions. |
| `xl` | 136 dp | Full-bleed, highly expressive. |
| `custom(...)` | Arbitrary | Override any dimension. |

```dart
// Custom size example
M3EButtonSize.custom(
  height: 48,
  hPadding: 20,
  iconSize: 20,
  iconGap: 8,
  width: 200,   // fixed width
)
```

### `M3EButtonShape`

| Value | Description |
|-------|-------------|
| `round` | Pill shape (`height / 2` radius). |
| `square` | Token-defined radius for the current size. |

### `M3EHapticFeedback`

| Value | Description |
|-------|-------------|
| `none` | No haptic (default). |
| `light` | Light tap. Good for subtle toggles. |
| `medium` | Standard button press feel. |
| `heavy` | Significant action confirmation. |

### `M3EButtonGroupType`

| Value | Description |
|-------|-------------|
| `standard` | Buttons with gaps; spacing set by `density`. |
| `connected` | Shared edges; inner corners animate on press. |

### `M3EButtonGroupDensity`

| Value | Description |
|-------|-------------|
| `regular` | Full token spacing. |
| `compact` | 75% of token spacing. |

### `M3EButtonGroupOverflow`

| Value | Description |
|-------|-------------|
| `none` | No overflow handling. |
| `scroll` | Scrollable along the main axis. |
| `menu` | Overflow items shown in a popup/bottom sheet trigger. |
| `experimentalPaging` | In-place window paging with back/forward triggers. |

---

## Motion System

`M3EMotion` configures the spring physics for button animations. Use presets or dial in exactly what you want with `M3EMotion.custom`.

```dart
M3EButtonDecoration(
  motion: M3EMotion.expressiveSpatialDefault,
)

// Or a fully custom spring
M3EButtonDecoration(
  motion: M3EMotion.custom(800, 0.65),
)
```

### Presets

| Preset | Stiffness | Damping | Best for |
|--------|-----------|---------|----------|
| `standardSpatialFast` | 1400 | 0.9 | Snappy shape animation |
| `standardSpatialDefault` | 700 | 0.9 | Balanced shape animation |
| `standardSpatialSlow` | 300 | 0.9 | Dramatic shape animation |
| `expressiveSpatialFast` | 800 | 0.6 | Bouncy, responsive feel |
| `expressiveSpatialDefault` | 380 | 0.8 | ✅ Default toggle motion |
| `expressiveSpatialSlow` | 200 | 0.8 | Very bouncy, dramatic |
| `standardEffectsFast` | 3800 | 1.0 | Instant effect snap |
| `standardEffectsDefault` | 1600 | 1.0 | Balanced effect animation |
| `standardEffectsSlow` | 800 | 1.0 | Relaxed effect animation |
| `standardOverflow` | 1600 | 0.85 | Overflow menu spring |
| `standardPopup` | 1000 | 0.6 | Popup menu bounce |

**`M3EMotion.custom(double stiffness, double damping)`**
- `stiffness` — Higher = faster/snappier spring.
- `damping` — 1.0 = critically damped (no overshoot). 0.5–0.8 = bouncy.

---

## Customization Recipes

### Icon-only button, extra large

```dart
M3EButton(
  size: M3EButtonSize.lg,
  icon: const Icon(Icons.add),
  onPressed: () {},
)
```

### Fully custom colors with `.copyWith`

```dart
final base = M3EButtonDecoration(
  backgroundColor: Colors.purple,
  foregroundColor: Colors.white,
);

M3EButton(
  decoration: base.copyWith(
    motion: M3EMotion.expressiveSpatialFast,
    haptic: M3EHapticFeedback.medium,
  ),
  label: const Text('Customized'),
  onPressed: () {},
)
```

### Connected toggle group — single select with custom motion

```dart
M3EToggleButtonGroup(
  type: M3EButtonGroupType.connected,
  size: M3EButtonSize.md,
  selectedIndex: _tab,
  onSelectedIndexChanged: (i) => setState(() => _tab = i),
  decoration: const M3EToggleButtonDecoration(
    motion: M3EMotion.expressiveSpatialFast,
    haptic: M3EHapticFeedback.light,
  ),
  actions: const [
    M3EToggleButtonGroupAction(icon: Icon(Icons.view_list)),
    M3EToggleButtonGroupAction(icon: Icon(Icons.grid_view)),
    M3EToggleButtonGroupAction(icon: Icon(Icons.map)),
  ],
)
```

### Overflow with bottom-sheet menu

```dart
M3EToggleButtonGroup(
  overflow: M3EButtonGroupOverflow.menu,
  overflowMenuStyle: M3EButtonGroupOverflowMenuStyle.bottomSheet,
  actions: [ /* many actions */ ],
  onSelectedIndexChanged: (i) {},
)
```

### Split button with a bottom sheet menu

```dart
SplitButtonM3E<int>(
  decoration: const M3ESplitButtonDecoration(
    menuStyle: SplitButtonMenuStyle.bottomSheet,
  ),
  items: const [
    SplitButtonM3EItem(value: 0, child: Text('Option A')),
    SplitButtonM3EItem(value: 1, child: Text('Option B')),
  ],
  onSelected: (v) {},
  onPressed: () {},
)
```

---

## Accessibility

- Provide `semanticLabel` when the visible icon or short text is ambiguous.
- Keep enabled and disabled states visually distinct — foreground and background contrast.
- Validate keyboard navigation on desktop/web; all buttons support `FocusNode` and `autofocus`.
- Prefer explicit labels for icon-only controls in production UIs.
- `M3EToggleButton` automatically exposes `checked` semantics to the accessibility tree.
- `M3EToggleButtonGroup` wraps the group in a semantic container with `semanticLabel`.

---

## Architecture

```
lib/
├── m3e_buttons.dart              ← Public API entry point
└── src/
    ├── components/
    │   ├── m3e_button/           ← M3EButton widget
    │   ├── m3e_toggle_button/    ← M3EToggleButton + M3EToggleButtonGroup
    │   └── m3e_split_button/     ← SplitButtonM3E
    ├── style/
    │   ├── m3e_button_enums.dart           ← M3EButtonStyle, M3EButtonSize, M3EButtonShape, M3EHapticFeedback
    │   ├── m3e_button_group_enums.dart     ← M3EButtonGroupType, M3EButtonGroupDensity, M3EButtonGroupOverflow
    │   ├── m3e_motion.dart                 ← M3EMotion presets + M3EMotion.custom
    │   ├── m3e_button_decoration.dart      ← M3EButtonDecoration, M3EToggleButtonDecoration
    │   ├── m3e_split_button_decoration.dart← M3ESplitButtonDecoration
    │   ├── m3e_button_overflow_decoration.dart
    │   └── button_tokens_adapter.dart      ← Material 3 token-to-pixel resolution
    ├── core/                     ← Shared utilities (ButtonGroupProvider, etc.)
    └── internal/                 ← Private animation, layout, and haptic helpers
```

> Only symbols re-exported from `package:m3e_buttons/m3e_buttons.dart` are stable public API.

---

## Development

Run the analyzer:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Run the example app:

```bash
cd example
flutter pub get
flutter run
```

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

---

## License

MIT License. See [LICENSE](LICENSE).

---

> 💡 Want more Material 3 Expressive components? Check out the full ecosystem at  
> **[pub.dev/packages/m3e_core](https://pub.dev/packages/m3e_core)**

---

**Radhe Radhe 🙏**
