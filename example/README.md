# m3e_buttons example

This app demonstrates the public APIs of m3e_buttons in realistic UI states.

## Run

```bash
cd example
flutter pub get
flutter run
```

## What is covered

- M3EButton: styles, sizes, shapes, haptics, motion, hover, long-press, ripple customization.
- M3EToggleButton: checked/unchecked visuals, labels, custom radii, controlled and uncontrolled state.
- M3EToggleButtonGroup: single and multi-select, connected layouts, overflow modes, custom overflow strategy.
- SplitButtonM3E: popup and bottom-sheet menus, menu customization, selected-item behavior.

## Main files

- example/lib/main.dart: app bootstrap and theme mode toggle.
- example/lib/screens/button_m3e_screen.dart: tabbed showcase for all major button components.
- example/lib/screens/tabs/split_button_tab.dart: focused split-button demos.
- example/lib/screens/tabs/button_helpers.dart: shared helper widgets used by tabs.

## Notes

- The example intentionally includes broad permutations of style and motion so behavior can be compared side-by-side.
- Internal package APIs are not required to use this app; all production usage should rely on package:m3e_buttons/m3e_buttons.dart exports.
