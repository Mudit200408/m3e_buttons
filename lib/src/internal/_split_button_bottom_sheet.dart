import 'package:flutter/material.dart';
import 'button_constants.dart';

import '../components/m3e_split_button/split_button.dart';
import '../style/m3e_split_button_decoration.dart';

Future<Object?> showSplitButtonBottomSheet<T>({
  required BuildContext context,
  required List<SplitButtonM3EItem<T>> items,
  required M3ESplitButtonBottomSheetDecoration decoration,
  required Color foregroundColor,
  required double iconSize,
  FocusNode? callerFocusNode,
  Set<T>? selectedValues,
}) {
  if (decoration.selectionMode == SplitButtonSelectionMode.multiple) {
    return _showMultiSelectBottomSheet<T>(
      context: context,
      items: items,
      decoration: decoration,
      foregroundColor: foregroundColor,
      iconSize: iconSize,
      callerFocusNode: callerFocusNode,
      initialSelectedValues: selectedValues,
    );
  }

  return _showSingleSelectBottomSheet<T>(
    context: context,
    items: items,
    decoration: decoration,
    foregroundColor: foregroundColor,
    iconSize: iconSize,
    callerFocusNode: callerFocusNode,
  );
}

Future<T?> _showSingleSelectBottomSheet<T>({
  required BuildContext context,
  required List<SplitButtonM3EItem<T>> items,
  required M3ESplitButtonBottomSheetDecoration decoration,
  required Color foregroundColor,
  required double iconSize,
  FocusNode? callerFocusNode,
}) {
  final keyboardActivated = callerFocusNode?.hasFocus ?? false;

  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: decoration.showDragHandle,
    backgroundColor: decoration.backgroundColor,
    elevation: decoration.elevation,
    shape: decoration.shape,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);

      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (decoration.title != null)
                Padding(
                  padding:
                      decoration.titlePadding ??
                      const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: DefaultTextStyle.merge(
                    style: theme.textTheme.titleMedium,
                    child: decoration.title!,
                  ),
                ),
              for (int i = 0; i < items.length; i++)
                _buildBottomSheetItem(
                  context: sheetContext,
                  item: items[i],
                  foregroundColor: foregroundColor,
                  iconSize: iconSize,
                  autofocus:
                      keyboardActivated &&
                      items[i].enabled &&
                      i == items.indexWhere((e) => e.enabled),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

Future<List<T>?> _showMultiSelectBottomSheet<T>({
  required BuildContext context,
  required List<SplitButtonM3EItem<T>> items,
  required M3ESplitButtonBottomSheetDecoration decoration,
  required Color foregroundColor,
  required double iconSize,
  FocusNode? callerFocusNode,
  Set<T>? initialSelectedValues,
}) {
  final keyboardActivated = callerFocusNode?.hasFocus ?? false;

  return showModalBottomSheet<List<T>>(
    context: context,
    showDragHandle: decoration.showDragHandle,
    backgroundColor: decoration.backgroundColor,
    elevation: decoration.elevation,
    shape: decoration.shape,
    isScrollControlled: true,
    builder: (sheetContext) {
      return _MultiSelectBottomSheet<T>(
        context: sheetContext,
        items: items,
        decoration: decoration,
        foregroundColor: foregroundColor,
        iconSize: iconSize,
        initialSelectedValues: initialSelectedValues,
        keyboardActivated: keyboardActivated,
      );
    },
  );
}

class _MultiSelectBottomSheet<T> extends StatefulWidget {
  const _MultiSelectBottomSheet({
    required this.context,
    required this.items,
    required this.decoration,
    required this.foregroundColor,
    required this.iconSize,
    required this.keyboardActivated,
    this.initialSelectedValues,
  });

  final BuildContext context;
  final List<SplitButtonM3EItem<T>> items;
  final M3ESplitButtonBottomSheetDecoration decoration;
  final Color foregroundColor;
  final double iconSize;
  final bool keyboardActivated;
  final Set<T>? initialSelectedValues;

  @override
  State<_MultiSelectBottomSheet<T>> createState() =>
      _MultiSelectBottomSheetState<T>();
}

class _MultiSelectBottomSheetState<T>
    extends State<_MultiSelectBottomSheet<T>> {
  late Set<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = Set<T>.from(widget.initialSelectedValues ?? {});
  }

  void _toggleValue(T value) {
    setState(() {
      if (_selectedValues.contains(value)) {
        _selectedValues.remove(value);
      } else {
        _selectedValues.add(value);
      }
    });
  }

  void _onDone() {
    Navigator.of(context).pop(_selectedValues.toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.decoration.title != null)
            Padding(
              padding:
                  widget.decoration.titlePadding ??
                  const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: DefaultTextStyle.merge(
                style: theme.textTheme.titleMedium,
                child: widget.decoration.title!,
              ),
            ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < widget.items.length; i++)
                    _buildMultiSelectItem(
                      context: context,
                      item: widget.items[i],
                      isSelected: _selectedValues.contains(
                        widget.items[i].value,
                      ),
                      checkboxStyle: widget.decoration.checkboxStyle,
                      autofocus:
                          widget.keyboardActivated &&
                          widget.items[i].enabled &&
                          i == widget.items.indexWhere((e) => e.enabled),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(<T>[]),
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _onDone,
                  child: Text(
                    _selectedValues.isEmpty
                        ? 'Done'
                        : 'Done (${_selectedValues.length})',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectItem({
    required BuildContext context,
    required SplitButtonM3EItem<T> item,
    required bool isSelected,
    M3ESplitButtonCheckboxStyle? checkboxStyle,
    bool autofocus = false,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final effectiveColor = item.enabled
        ? widget.foregroundColor
        : widget.foregroundColor.withValues(
            alpha: ButtonConstants.kDisabledForegroundAlpha,
          );

    Widget child;
    if (item.child is IconData) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.child as IconData,
            size: widget.iconSize,
            color: effectiveColor,
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              item.child.toString(),
              style: theme.textTheme.bodyLarge?.copyWith(color: effectiveColor),
            ),
          ),
        ],
      );
    } else if (item.child is Widget) {
      child = item.child as Widget;
    } else {
      child = Text(
        item.child.toString(),
        style: theme.textTheme.bodyLarge?.copyWith(color: effectiveColor),
      );
    }

    final activeColor = checkboxStyle?.activeColor ?? cs.primary;
    final checkColor = checkboxStyle?.checkColor ?? cs.onPrimary;
    final borderRadius =
        checkboxStyle?.borderRadius ?? BorderRadius.circular(4);

    return InkWell(
      autofocus: autofocus,
      onTap: item.enabled ? () => _toggleValue(item.value) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isSelected,
                onChanged: item.enabled
                    ? (_) => _toggleValue(item.value)
                    : null,
                activeColor: activeColor,
                checkColor: checkColor,
                shape: RoundedRectangleBorder(borderRadius: borderRadius),
                side: BorderSide(
                  color: effectiveColor.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

Widget _buildBottomSheetItem<T>({
  required BuildContext context,
  required SplitButtonM3EItem<T> item,
  required Color foregroundColor,
  required double iconSize,
  bool autofocus = false,
}) {
  final theme = Theme.of(context);

  final Color effectiveColor = item.enabled
      ? foregroundColor
      : foregroundColor.withValues(
          alpha: ButtonConstants.kDisabledForegroundAlpha,
        );

  Widget child;
  if (item.child is IconData) {
    child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(item.child as IconData, size: iconSize, color: effectiveColor),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            item.child.toString(),
            style: theme.textTheme.bodyLarge?.copyWith(color: effectiveColor),
          ),
        ),
      ],
    );
  } else if (item.child is Widget) {
    child = item.child as Widget;
  } else {
    child = Text(
      item.child.toString(),
      style: theme.textTheme.bodyLarge?.copyWith(color: effectiveColor),
    );
  }

  return InkWell(
    autofocus: autofocus,
    onTap: item.enabled ? () => Navigator.of(context).pop(item.value) : null,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: child,
    ),
  );
}
