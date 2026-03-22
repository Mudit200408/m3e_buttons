import 'package:flutter/material.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

import 'button_helpers.dart';

class SplitButtonTab extends StatelessWidget {
  const SplitButtonTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ButtonHeader('Styles', tt),
          ButtonSub('All five emphasis styles from M3EButtonStyle.', cs, tt),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SplitButtonM3E<String>(
                style: M3EButtonStyle.filled,
                label: 'Filled',
                leadingIcon: Icons.save_rounded,
                items: const [
                  SplitButtonM3EItem(value: 'save', child: Text('Save')),
                  SplitButtonM3EItem(value: 'save_as', child: Text('Save As')),
                  SplitButtonM3EItem(value: 'export', child: Text('Export')),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
              SplitButtonM3E<String>(
                style: M3EButtonStyle.tonal,
                label: 'Tonal',
                leadingIcon: Icons.share_rounded,
                items: const [
                  SplitButtonM3EItem(value: 'share', child: Text('Share')),
                  SplitButtonM3EItem(value: 'copy', child: Text('Copy Link')),
                  SplitButtonM3EItem(value: 'email', child: Text('Email')),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
              SplitButtonM3E<String>(
                style: M3EButtonStyle.elevated,
                label: 'Elevated',
                leadingIcon: Icons.upload_rounded,
                items: const [
                  SplitButtonM3EItem(value: 'upload', child: Text('Upload')),
                  SplitButtonM3EItem(
                    value: 'cloud',
                    child: Text('Cloud Upload'),
                  ),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
              SplitButtonM3E<String>(
                style: M3EButtonStyle.outlined,
                label: 'Outlined',
                items: const [
                  SplitButtonM3EItem(value: 'option1', child: Text('Option 1')),
                  SplitButtonM3EItem(value: 'option2', child: Text('Option 2')),
                  SplitButtonM3EItem(value: 'option3', child: Text('Option 3')),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
              SplitButtonM3E<String>(
                style: M3EButtonStyle.text,
                label: 'Text',
                leadingIcon: Icons.info_outline_rounded,
                items: const [
                  SplitButtonM3EItem(value: 'info', child: Text('Info')),
                  SplitButtonM3EItem(value: 'help', child: Text('Help')),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
              const SplitButtonM3E<String>(
                label: 'Disabled',
                items: [
                  SplitButtonM3EItem(value: 'a', child: Text('Option A')),
                ],
                enabled: false,
              ),
            ],
          ),

          ButtonHeader('Sizes', tt),
          ButtonSub('Five sizes from XS to XL.', cs, tt),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SplitButtonM3E<String>(
                size: M3EButtonSize.xs,
                style: M3EButtonStyle.tonal,
                label: 'XS',
                items: const [
                  SplitButtonM3EItem(value: 'xs1', child: Text('XS Option 1')),
                  SplitButtonM3EItem(value: 'xs2', child: Text('XS Option 2')),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
              SplitButtonM3E<String>(
                size: M3EButtonSize.sm,
                style: M3EButtonStyle.tonal,
                label: 'SM',
                items: const [
                  SplitButtonM3EItem(value: 'sm1', child: Text('SM Option 1')),
                  SplitButtonM3EItem(value: 'sm2', child: Text('SM Option 2')),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
              SplitButtonM3E<String>(
                size: M3EButtonSize.md,
                style: M3EButtonStyle.tonal,
                label: 'MD',
                items: const [
                  SplitButtonM3EItem(value: 'md1', child: Text('MD Option 1')),
                  SplitButtonM3EItem(value: 'md2', child: Text('MD Option 2')),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
              SplitButtonM3E<String>(
                size: M3EButtonSize.lg,
                style: M3EButtonStyle.tonal,
                label: 'LG',
                items: const [
                  SplitButtonM3EItem(value: 'lg1', child: Text('LG Option 1')),
                  SplitButtonM3EItem(value: 'lg2', child: Text('LG Option 2')),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
              SplitButtonM3E<String>(
                size: M3EButtonSize.xl,
                style: M3EButtonStyle.tonal,
                label: 'XL',
                items: const [
                  SplitButtonM3EItem(value: 'xl1', child: Text('XL Option 1')),
                  SplitButtonM3EItem(value: 'xl2', child: Text('XL Option 2')),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
            ],
          ),

          ButtonHeader('Shapes', tt),
          ButtonSub('Round (default) vs Square with spring motion.', cs, tt),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SplitButtonM3E<String>(
                shape: M3EButtonShape.round,
                label: 'Round',
                items: const [
                  SplitButtonM3EItem(
                    value: 'r1',
                    child: Text('Round Option 1'),
                  ),
                  SplitButtonM3EItem(
                    value: 'r2',
                    child: Text('Round Option 2'),
                  ),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
              SplitButtonM3E<String>(
                shape: M3EButtonShape.square,
                label: 'Square',
                items: const [
                  SplitButtonM3EItem(
                    value: 's1',
                    child: Text('Square Option 1'),
                  ),
                  SplitButtonM3EItem(
                    value: 's2',
                    child: Text('Square Option 2'),
                  ),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
            ],
          ),

          ButtonHeader('Leading Content', tt),
          ButtonSub('Icon only, label only, or icon + label.', cs, tt),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SplitButtonM3E<String>(
                label: 'With Icon',
                leadingIcon: Icons.settings_rounded,

                items: const [
                  SplitButtonM3EItem(
                    value: 'settings',
                    child: Text('Settings'),
                  ),
                  SplitButtonM3EItem(
                    value: 'preferences',
                    child: Text('Preferences'),
                  ),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
              SplitButtonM3E<String>(
                leadingIcon: Icons.add_rounded,
                items: const [
                  SplitButtonM3EItem(value: 'add1', child: Text('Add Item')),
                  SplitButtonM3EItem(value: 'add2', child: Text('Add Another')),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
              SplitButtonM3E<String>(
                label: 'Label Only',
                items: const [
                  SplitButtonM3EItem(value: 'opt1', child: Text('Option 1')),
                  SplitButtonM3EItem(value: 'opt2', child: Text('Option 2')),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
            ],
          ),

          ButtonHeader('Custom Decoration', tt),
          ButtonSub(
            'Background, foreground, trailing, and menu colors.',
            cs,
            tt,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SplitButtonM3E<String>(
                decoration: M3ESplitButtonDecoration(
                  backgroundColor: cs.primaryContainer,
                  foregroundColor: cs.onPrimaryContainer,
                  haptic: M3EHapticFeedback.light,
                ),
                label: 'Custom BG',
                leadingIcon: Icons.palette_rounded,
                items: const [
                  SplitButtonM3EItem(value: 'color1', child: Text('Color 1')),
                  SplitButtonM3EItem(value: 'color2', child: Text('Color 2')),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
              SplitButtonM3E<String>(
                decoration: M3ESplitButtonDecoration(
                  trailingBackgroundColor: cs.errorContainer,
                  trailingForegroundColor: cs.onErrorContainer,
                  haptic: M3EHapticFeedback.heavy,
                ),
                label: 'Custom Trailing',
                items: const [
                  SplitButtonM3EItem(value: 't1', child: Text('Trailing 1')),
                  SplitButtonM3EItem(value: 't2', child: Text('Trailing 2')),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
            ],
          ),

          ButtonHeader('Custom Size', tt),
          ButtonSub(
            'leadingCustomSize and trailingCustomSize overrides.',
            cs,
            tt,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SplitButtonM3E<String>(
                decoration: M3ESplitButtonDecoration(
                  leadingCustomSize: M3EButtonSize.custom(
                    height: 52,
                    hPadding: 28,
                  ),
                ),
                label: 'Leading Custom',
                items: const [
                  SplitButtonM3EItem(value: 'c1', child: Text('Custom 1')),
                  SplitButtonM3EItem(value: 'c2', child: Text('Custom 2')),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
              SplitButtonM3E<String>(
                decoration: M3ESplitButtonDecoration(
                  trailingCustomSize: M3EButtonSize.custom(width: 60),
                ),
                label: 'Trailing Custom',
                items: const [
                  SplitButtonM3EItem(value: 'tc1', child: Text('Trailing 1')),
                  SplitButtonM3EItem(value: 'tc2', child: Text('Trailing 2')),
                ],
                onPressed: () {},
                onSelected: (_) {},
              ),
            ],
          ),

          ButtonHeader('Menu Styles', tt),
          ButtonSub(
            'Three menu display options: popup (default), bottomSheet, and native.',
            cs,
            tt,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SplitButtonM3E<String>(
                style: M3EButtonStyle.filled,
                label: 'Popup (Default)',
                leadingIcon: Icons.arrow_drop_down_rounded,
                items: const [
                  SplitButtonM3EItem(
                    value: 'p1',
                    child: Text('Popup Option 1'),
                  ),
                  SplitButtonM3EItem(
                    value: 'p2',
                    child: Text('Popup Option 2'),
                  ),
                  SplitButtonM3EItem(
                    value: 'p3',
                    child: Text('Popup Option 3'),
                  ),
                ],
                onPressed: () {},
                onSelected: (value) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Selected: $value')));
                },
              ),
              SplitButtonM3E<String>(
                decoration: const M3ESplitButtonDecoration(
                  menuStyle: SplitButtonMenuStyle.bottomSheet,
                ),
                style: M3EButtonStyle.filled,
                label: 'Bottom Sheet',
                leadingIcon: Icons.keyboard_arrow_down_rounded,
                items: const [
                  SplitButtonM3EItem(
                    value: 'bs1',
                    child: Text('Sheet Option 1'),
                  ),
                  SplitButtonM3EItem(
                    value: 'bs2',
                    child: Text('Sheet Option 2'),
                  ),
                  SplitButtonM3EItem(
                    value: 'bs3',
                    child: Text('Sheet Option 3'),
                  ),
                ],
                onPressed: () {},
                onSelected: (value) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Selected: $value')));
                },
              ),
              SplitButtonM3E<String>(
                decoration: const M3ESplitButtonDecoration(
                  menuStyle: SplitButtonMenuStyle.native,
                ),
                style: M3EButtonStyle.filled,
                label: 'Native',
                leadingIcon: Icons.menu_rounded,
                items: const [
                  SplitButtonM3EItem(
                    value: 'n1',
                    child: Text('Native Option 1'),
                  ),
                  SplitButtonM3EItem(
                    value: 'n2',
                    child: Text('Native Option 2'),
                  ),
                  SplitButtonM3EItem(
                    value: 'n3',
                    child: Text('Native Option 3'),
                  ),
                ],
                onPressed: () {},
                onSelected: (value) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Selected: $value')));
                },
              ),
            ],
          ),

          ButtonHeader('Popup Customization', tt),
          ButtonSub(
            'Custom spring physics and styling for the popup menu.',
            cs,
            tt,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SplitButtonM3E<String>(
                decoration: M3ESplitButtonDecoration(
                  popupDecoration: M3ESplitButtonPopupDecoration(
                    motion: M3EMotion.custom(200, 0.6),
                    elevation: 8,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                style: M3EButtonStyle.tonal,
                label: 'Bouncy',
                leadingIcon: Icons.sports_basketball_rounded,
                items: const [
                  SplitButtonM3EItem(value: 'b1', child: Text('Bouncy 1')),
                  SplitButtonM3EItem(value: 'b2', child: Text('Bouncy 2')),
                ],
                onPressed: () {},
                onSelected: (value) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Selected: $value')));
                },
              ),
              SplitButtonM3E<String>(
                decoration: M3ESplitButtonDecoration(
                  popupDecoration: M3ESplitButtonPopupDecoration(
                    motion: M3EMotion.custom(600, 0.95),
                    elevation: 2,
                  ),
                ),
                style: M3EButtonStyle.tonal,
                label: 'Snappy',
                leadingIcon: Icons.flash_on_rounded,
                items: const [
                  SplitButtonM3EItem(value: 's1', child: Text('Snappy 1')),
                  SplitButtonM3EItem(value: 's2', child: Text('Snappy 2')),
                ],
                onPressed: () {},
                onSelected: (value) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Selected: $value')));
                },
              ),
            ],
          ),

          ButtonHeader('Bottom Sheet Customization', tt),
          ButtonSub(
            'Custom title and drag handle for the bottom sheet.',
            cs,
            tt,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SplitButtonM3E<String>(
                decoration: M3ESplitButtonDecoration(
                  menuStyle: SplitButtonMenuStyle.bottomSheet,
                  bottomSheetDecoration: M3ESplitButtonBottomSheetDecoration(
                    title: Text('Select Action'),
                    motion: M3EMotion.custom(1200, 0.8),
                    showDragHandle: true,
                  ),
                ),
                style: M3EButtonStyle.tonal,
                label: 'With Title',
                leadingIcon: Icons.folder_open_rounded,
                items: const [
                  SplitButtonM3EItem(value: 'f1', child: Text('Open File')),
                  SplitButtonM3EItem(value: 'f2', child: Text('Open Folder')),
                  SplitButtonM3EItem(value: 'f3', child: Text('Open Recent')),
                ],
                onPressed: () {},
                onSelected: (value) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Selected: $value')));
                },
              ),
              SplitButtonM3E<String>(
                decoration: const M3ESplitButtonDecoration(
                  menuStyle: SplitButtonMenuStyle.bottomSheet,
                  bottomSheetDecoration: M3ESplitButtonBottomSheetDecoration(
                    showDragHandle: false,
                  ),
                ),
                style: M3EButtonStyle.tonal,
                label: 'No Handle',
                leadingIcon: Icons.list_rounded,
                items: const [
                  SplitButtonM3EItem(value: 'l1', child: Text('List Item 1')),
                  SplitButtonM3EItem(value: 'l2', child: Text('List Item 2')),
                  SplitButtonM3EItem(value: 'l3', child: Text('List Item 3')),
                ],
                onPressed: () {},
                onSelected: (value) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Selected: $value')));
                },
              ),
            ],
          ),

          ButtonHeader('With MenuBuilder', tt),
          ButtonSub('Custom PopupMenuEntry via menuBuilder callback.', cs, tt),
          const SizedBox(height: 12),
          SplitButtonM3E<String>(
            style: M3EButtonStyle.filled,
            label: 'Custom Menu',
            leadingIcon: Icons.more_horiz_rounded,
            items: const [
              SplitButtonM3EItem(value: 'edit', child: Text('Edit')),
              SplitButtonM3EItem(value: 'delete', child: Text('Delete')),
              SplitButtonM3EItem(value: 'share', child: Text('Share')),
            ],
            menuBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Delete'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Share'),
                  ],
                ),
              ),
            ],
            onPressed: () {},
            onSelected: (value) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Selected: $value')));
            },
          ),

          ButtonHeader('Selection State', tt),
          ButtonSub(
            'Popup shows highlighted selected item with selectedColor.',
            cs,
            tt,
          ),
          const SizedBox(height: 12),
          _SelectionStateExample(),
          const SizedBox(height: 24),

          ButtonHeader('Multi-Select Bottom Sheet', tt),
          ButtonSub(
            'Bottom sheet with checkbox style for selecting multiple options.',
            cs,
            tt,
          ),
          const SizedBox(height: 12),
          _MultiSelectExample(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _SelectionStateExample extends StatefulWidget {
  @override
  State<_SelectionStateExample> createState() => _SelectionStateExampleState();
}

class _SelectionStateExampleState extends State<_SelectionStateExample> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SplitButtonM3E<String>(
          decoration: M3ESplitButtonDecoration(
            popupDecoration: M3ESplitButtonPopupDecoration(
              selectedColor: cs.primaryContainer,
              selectedBorderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
          ),
          style: M3EButtonStyle.filled,
          label: _selectedValue ?? 'Select',
          selectedValue: _selectedValue,
          items: const [
            SplitButtonM3EItem(value: 'save', child: Text('Save')),
            SplitButtonM3EItem(value: 'save_as', child: Text('Save As')),
            SplitButtonM3EItem(value: 'export', child: Text('Export')),
          ],
          onPressed: () {},
          onSelected: (value) {
            setState(() => _selectedValue = value);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Selected: $value')));
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Current selection: ${_selectedValue ?? 'none'}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _MultiSelectExample extends StatefulWidget {
  @override
  State<_MultiSelectExample> createState() => _MultiSelectExampleState();
}

class _MultiSelectExampleState extends State<_MultiSelectExample> {
  final Set<String> _selectedDevices = {};

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SplitButtonM3E<String>(
          decoration: M3ESplitButtonDecoration(
            menuStyle: SplitButtonMenuStyle.bottomSheet,
            bottomSheetDecoration: M3ESplitButtonBottomSheetDecoration(
              title: const Text('Select Devices'),
              selectionMode: SplitButtonSelectionMode.multiple,
              checkboxStyle: M3ESplitButtonCheckboxStyle(
                activeColor: cs.primary,
                checkColor: cs.onPrimary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          style: M3EButtonStyle.filled,
          label: _selectedDevices.isEmpty
              ? 'Install App'
              : 'Install to ${_selectedDevices.length} Devices',
          leadingIcon: Icons.install_desktop_rounded,
          items: const [
            SplitButtonM3EItem(value: 'phone', child: Text('Phone')),
            SplitButtonM3EItem(value: 'tablet', child: Text('Tablet')),
            SplitButtonM3EItem(value: 'tv', child: Text('TV')),
            SplitButtonM3EItem(value: 'watch', child: Text('Watch')),
          ],
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Installing app...')));
          },
          onMultiSelected: (devices) {
            setState(() => _selectedDevices.clear());
            if (devices.isNotEmpty) {
              setState(() => _selectedDevices.addAll(devices));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Installing to: ${devices.join(", ")}')),
              );
            }
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Selected: ${_selectedDevices.isEmpty ? 'none' : _selectedDevices.join(", ")}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
