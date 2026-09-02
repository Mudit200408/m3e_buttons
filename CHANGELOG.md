# 1.0.1
- buttons: preserve base token size names when custom action widths or heights are used
- toggle-button: prioritize checked-state radius over pressed-state radius for checked buttons
- buttons: add Material 3 Expressive FAB, extended FAB, and FAB menu APIs with token sizing, color roles, decoration overrides, and tests

# 1.0.0
- pubspec: migrate to standalone material_ui package for flutter 3.47
- pubspec: Update the minimum flutter SDK to 3.47.0

# 0.0.6
- toggle-button: expose alignment parameter in `M3EToggleButtonDecoration` and `styleFrom`
- toggle-button: add allowMultilineLabel flag to enable wrapping label content
- buttons: update label text style to match M3E typography specs [Contributed by @paul-ube]

## 0.0.5
- fixup: fix connected toggle button layout on mobile devices
- example: update connected button group demo and gradle properties

## 0.0.4
- toggle-button: Match the button colors to M3E color spec

## 0.0.3
- Add `borderRadius` parameter and make it double?.

## 0.0.2
- **Breaking Changes**:
    - **WidgetStateProperty Shift**: Most color/cursor parameters in decoration classes are now `WidgetStateProperty`.
    - **Parameter Removals**:
        - `size` removed from all Decoration classes (now managed by the widget's `size` parameter).
        - `disabledBackgroundColor` and `disabledForegroundColor` removed (use `backgroundColor` and `foregroundColor` with `WidgetStateProperty`).
        - `connectedHoveredInnerRadius` and `connectedPressedInnerRadius` removed from `M3EToggleButtonDecoration`.
    - **Renamed Components**:
        - `SplitButtonM3E` → `M3ESplitButton`
        - `SplitButtonM3EAction` → `M3ESplitButtonItem`
        - `SplitButtonM3EDecoration` → `M3ESplitButtonDecoration`
- **New Features**:
    - **Added specialized button classes**: `M3EElevatedButton`, `M3EFilledButton`, `M3EOutlinedButton`, `M3ETextButton`.
    - **New `.styleFrom()` helper**: Available on `M3EButtonDecoration` and `M3EToggleButtonDecoration` for simple flat color assignments.
    - **New ButtonStyle Parity**: Added `shadowColor`, `elevation`, `padding`, `minimumSize`, `fixedSize`, `maximumSize`, `alignment`, `visualDensity`, `tapTargetSize`, `splashFactory` to `M3EButtonDecoration`.
    - **Custom Layers**: Added `backgroundBuilder` and `foregroundBuilder` to `M3EButtonDecoration`.
- **Breaking Changes**:
    - `M3EButton`: Renamed `label` parameter to `child` for alignment with Flutter standards. Use `M3EButton.icon` for icon+label layouts.
    - `SplitButtonM3E` renamed to `M3ESplitButton`.
    - `SplitButtonM3EItem` renamed to `M3ESplitButtonItem`.
- **Performance**:
    - Optimized `M3EBaseButtonState` using `ValueNotifier` and `AnimatedBuilder` to minimize rebuilds during interaction animations.
- **Visuals**:
    - Fixed gradient background clipping during shape morphing.
    - Added `backgroundBuilder` and `foregroundBuilder` to `M3EButtonDecoration`.
- **Features**:
    - `M3EToggleButtonGroup` now supports advanced overflow handling (menu, popup) and label state transitions.
    - Full screen-reader support via `semanticLabel` and improved focus management.

## 0.0.1
- Initial Release
- Brings Material 3 Expressive buttons to Flutter with all the interaction animations
