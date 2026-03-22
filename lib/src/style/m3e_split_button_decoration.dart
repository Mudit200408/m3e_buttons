import 'package:flutter/material.dart';

import 'm3e_button_decoration.dart';
import 'm3e_button_enums.dart';
import 'm3e_motion.dart';

enum SplitButtonMenuStyle { popup, bottomSheet, native }

enum SplitButtonSelectionMode { single, multiple }

@immutable
class M3ESplitButtonPopupDecoration {
  const M3ESplitButtonPopupDecoration({
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.border,
    this.offset = const Offset(0, 4),
    this.minWidth = 120,
    this.maxWidth = 280,
    this.maxHeight = 400,
    this.padding,
    this.motion = M3EMotion.standardPopup,
    this.selectedColor,
    this.selectedBorderRadius,
  });

  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;
  final Offset offset;
  final double minWidth;
  final double maxWidth;
  final double maxHeight;
  final EdgeInsetsGeometry? padding;
  final M3EMotion motion;
  final Color? selectedColor;
  final BorderRadius? selectedBorderRadius;

  M3ESplitButtonPopupDecoration copyWith({
    Color? backgroundColor,
    double? elevation,
    BorderRadius? borderRadius,
    Border? border,
    Offset? offset,
    double? minWidth,
    double? maxWidth,
    double? maxHeight,
    EdgeInsetsGeometry? padding,
    M3EMotion? motion,
    Color? selectedColor,
    BorderRadius? selectedBorderRadius,
  }) {
    return M3ESplitButtonPopupDecoration(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      offset: offset ?? this.offset,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      padding: padding ?? this.padding,
      motion: motion ?? this.motion,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedBorderRadius: selectedBorderRadius ?? this.selectedBorderRadius,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is M3ESplitButtonPopupDecoration &&
          backgroundColor == other.backgroundColor &&
          elevation == other.elevation &&
          borderRadius == other.borderRadius &&
          border == other.border &&
          offset == other.offset &&
          minWidth == other.minWidth &&
          maxWidth == other.maxWidth &&
          maxHeight == other.maxHeight &&
          padding == other.padding &&
          motion == other.motion &&
          selectedColor == other.selectedColor &&
          selectedBorderRadius == other.selectedBorderRadius;

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    elevation,
    borderRadius,
    border,
    offset,
    minWidth,
    maxWidth,
    maxHeight,
    padding,
    motion,
    selectedColor,
    selectedBorderRadius,
  );
}

@immutable
class M3ESplitButtonBottomSheetDecoration {
  const M3ESplitButtonBottomSheetDecoration({
    this.title,
    this.titlePadding,
    this.showDragHandle = true,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.motion = M3EMotion.expressiveSpatialDefault,
    this.selectionMode = SplitButtonSelectionMode.single,
    this.checkboxStyle,
  });

  final Widget? title;
  final EdgeInsetsGeometry? titlePadding;
  final bool showDragHandle;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final M3EMotion motion;
  final SplitButtonSelectionMode selectionMode;
  final M3ESplitButtonCheckboxStyle? checkboxStyle;

  M3ESplitButtonBottomSheetDecoration copyWith({
    Widget? title,
    EdgeInsetsGeometry? titlePadding,
    bool? showDragHandle,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    M3EMotion? motion,
    SplitButtonSelectionMode? selectionMode,
    M3ESplitButtonCheckboxStyle? checkboxStyle,
  }) {
    return M3ESplitButtonBottomSheetDecoration(
      title: title ?? this.title,
      titlePadding: titlePadding ?? this.titlePadding,
      showDragHandle: showDragHandle ?? this.showDragHandle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      shape: shape ?? this.shape,
      motion: motion ?? this.motion,
      selectionMode: selectionMode ?? this.selectionMode,
      checkboxStyle: checkboxStyle ?? this.checkboxStyle,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is M3ESplitButtonBottomSheetDecoration &&
          title == other.title &&
          titlePadding == other.titlePadding &&
          showDragHandle == other.showDragHandle &&
          backgroundColor == other.backgroundColor &&
          elevation == other.elevation &&
          shape == other.shape &&
          motion == other.motion &&
          selectionMode == other.selectionMode &&
          checkboxStyle == other.checkboxStyle;

  @override
  int get hashCode => Object.hash(
    title,
    titlePadding,
    showDragHandle,
    backgroundColor,
    elevation,
    shape,
    motion,
    selectionMode,
    checkboxStyle,
  );
}

@immutable
class M3ESplitButtonCheckboxStyle {
  const M3ESplitButtonCheckboxStyle({
    this.activeColor,
    this.checkColor,
    this.borderRadius,
  });

  final Color? activeColor;
  final Color? checkColor;
  final BorderRadius? borderRadius;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is M3ESplitButtonCheckboxStyle &&
          activeColor == other.activeColor &&
          checkColor == other.checkColor &&
          borderRadius == other.borderRadius;

  @override
  int get hashCode => Object.hash(activeColor, checkColor, borderRadius);
}

/// Styling overrides for [M3ESplitButton].
///
/// Extends [M3EButtonDecoration] to add split-button-specific styling
/// options for the leading segment, trailing segment, and menu.
///
/// All fields are optional; null means "use the token default for this style
/// and size". Combine with [copyWith] to build incremental overrides.
///
/// This class is `@immutable`. Create a new instance (or use [copyWith])
/// rather than modifying an existing one. Equality is value-based so the
/// same logical decoration produces a stable layout signature.
///
/// ## Example
/// ```dart
/// M3ESplitButton(
///   decoration: M3ESplitButtonDecoration(
///     trailingBackgroundColor: Colors.red,
///     leadingCustomSize: M3EButtonSize.custom(width: 150),
///   ),
///   items: [...],
///   onPressed: () {},
/// )
/// ```
///
/// See also:
/// - [M3EButtonDecoration] for standard button styling
/// - [M3EButtonSize] for size override options
@immutable
class M3ESplitButtonDecoration extends M3EButtonDecoration {
  /// Background color for the trailing (menu trigger) segment.
  ///
  /// When null, uses the same background color as the leading segment
  /// (determined by [M3EButtonDecoration.backgroundColor] or the style).
  final Color? trailingBackgroundColor;

  /// Foreground color for the trailing (menu trigger) segment.
  ///
  /// When null, uses the same foreground color as the leading segment
  /// (determined by [M3EButtonDecoration.foregroundColor] or the style).
  final Color? trailingForegroundColor;

  /// Background color for the dropdown menu.
  ///
  /// When null, uses the same background color as the button container,
  /// or [ColorScheme.surfaceContainerHigh] for transparent buttons.
  final Color? menuBackgroundColor;

  /// Foreground color for the dropdown menu items.
  ///
  /// When null, uses the same foreground color as the button,
  /// or [ColorScheme.onSurface] for transparent buttons.
  final Color? menuForegroundColor;

  /// Color for the visual divider between leading and trailing segments.
  ///
  /// When null, no explicit divider color is set (uses Material default).
  final Color? dividerColor;

  /// Custom size overrides for the leading segment.
  ///
  /// When provided, these values override the default measurements for
  /// the specified [M3EButtonSize] for the leading action area.
  final M3EButtonSize? leadingCustomSize;

  /// Custom size overrides for the trailing (menu trigger) segment.
  ///
  /// When provided, these values override the default measurements for
  /// the trailing segment's width and padding.
  final M3EButtonSize? trailingCustomSize;

  /// Corner radius when the trailing segment is selected/open.
  ///
  /// For round shape buttons, this defaults to half the button height
  /// (creating a pill/circle shape). For square shapes, this controls
  /// the corner radius during selection.
  final double? trailingSelectedRadius;

  /// Gap between the leading and trailing segments.
  ///
  /// When null, uses the token default (typically 2-4dp depending on style).
  final double? gap;

  /// Menu display style when using `items` parameter.
  ///
  /// - [SplitButtonMenuStyle.popup]: Spring-animated dropdown (default)
  /// - [SplitButtonMenuStyle.bottomSheet]: Modal bottom sheet
  /// - [SplitButtonMenuStyle.native]: Standard Flutter showMenu
  final SplitButtonMenuStyle menuStyle;

  /// Decoration for the spring-animated popup menu.
  ///
  /// Use to customize background, elevation, border radius, and spring physics.
  /// Only used when [menuStyle] is [SplitButtonMenuStyle.popup].
  final M3ESplitButtonPopupDecoration? popupDecoration;

  /// Decoration for the bottom sheet menu.
  ///
  /// Use to customize title, drag handle, background, and shape.
  /// Only used when [menuStyle] is [SplitButtonMenuStyle.bottomSheet].
  final M3ESplitButtonBottomSheetDecoration? bottomSheetDecoration;

  const M3ESplitButtonDecoration({
    super.backgroundColor,
    super.foregroundColor,
    super.disabledBackgroundColor,
    super.disabledForegroundColor,
    super.borderSide,
    super.borderRadius,
    super.haptic,
    super.mouseCursor,
    this.trailingBackgroundColor,
    this.trailingForegroundColor,
    this.menuBackgroundColor,
    this.menuForegroundColor,
    this.dividerColor,
    this.leadingCustomSize,
    this.trailingCustomSize,
    this.trailingSelectedRadius,
    this.gap,
    this.menuStyle = SplitButtonMenuStyle.popup,
    this.popupDecoration,
    this.bottomSheetDecoration,
    super.hoveredRadius,
    super.pressedRadius,
    super.size,
  });

  @override
  M3ESplitButtonDecoration copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? disabledBackgroundColor,
    Color? disabledForegroundColor,
    BorderSide? borderSide,
    BorderRadius? borderRadius,
    M3EMotion? motion,
    M3EHapticFeedback? haptic,
    MouseCursor? mouseCursor,
    Color? trailingBackgroundColor,
    Color? trailingForegroundColor,
    Color? menuBackgroundColor,
    Color? menuForegroundColor,
    Color? dividerColor,
    M3EButtonSize? leadingCustomSize,
    M3EButtonSize? trailingCustomSize,
    double? trailingSelectedRadius,
    double? gap,
    SplitButtonMenuStyle? menuStyle,
    M3ESplitButtonPopupDecoration? popupDecoration,
    M3ESplitButtonBottomSheetDecoration? bottomSheetDecoration,
    double? hoveredRadius,
    double? pressedRadius,
    M3EButtonSize? size,
  }) {
    return M3ESplitButtonDecoration(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
      disabledForegroundColor:
          disabledForegroundColor ?? this.disabledForegroundColor,
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
      haptic: haptic ?? this.haptic,
      mouseCursor: mouseCursor ?? this.mouseCursor,
      trailingBackgroundColor:
          trailingBackgroundColor ?? this.trailingBackgroundColor,
      trailingForegroundColor:
          trailingForegroundColor ?? this.trailingForegroundColor,
      menuBackgroundColor: menuBackgroundColor ?? this.menuBackgroundColor,
      menuForegroundColor: menuForegroundColor ?? this.menuForegroundColor,
      dividerColor: dividerColor ?? this.dividerColor,
      leadingCustomSize: leadingCustomSize ?? this.leadingCustomSize,
      trailingCustomSize: trailingCustomSize ?? this.trailingCustomSize,
      trailingSelectedRadius:
          trailingSelectedRadius ?? this.trailingSelectedRadius,
      gap: gap ?? this.gap,
      menuStyle: menuStyle ?? this.menuStyle,
      popupDecoration: popupDecoration ?? this.popupDecoration,
      bottomSheetDecoration:
          bottomSheetDecoration ?? this.bottomSheetDecoration,
      hoveredRadius: hoveredRadius ?? this.hoveredRadius,
      pressedRadius: pressedRadius ?? this.pressedRadius,
      size: size ?? this.size,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is M3ESplitButtonDecoration &&
          backgroundColor == other.backgroundColor &&
          foregroundColor == other.foregroundColor &&
          disabledBackgroundColor == other.disabledBackgroundColor &&
          disabledForegroundColor == other.disabledForegroundColor &&
          borderSide == other.borderSide &&
          borderRadius == other.borderRadius &&
          haptic == other.haptic &&
          mouseCursor == other.mouseCursor &&
          trailingBackgroundColor == other.trailingBackgroundColor &&
          trailingForegroundColor == other.trailingForegroundColor &&
          menuBackgroundColor == other.menuBackgroundColor &&
          menuForegroundColor == other.menuForegroundColor &&
          dividerColor == other.dividerColor &&
          leadingCustomSize == other.leadingCustomSize &&
          trailingCustomSize == other.trailingCustomSize &&
          trailingSelectedRadius == other.trailingSelectedRadius &&
          gap == other.gap &&
          menuStyle == other.menuStyle &&
          popupDecoration == other.popupDecoration &&
          bottomSheetDecoration == other.bottomSheetDecoration &&
          hoveredRadius == other.hoveredRadius &&
          pressedRadius == other.pressedRadius &&
          size == other.size;

  @override
  int get hashCode => Object.hashAll([
    backgroundColor,
    foregroundColor,
    disabledBackgroundColor,
    disabledForegroundColor,
    borderSide,
    borderSide,
    borderRadius,
    haptic,
    mouseCursor,
    trailingBackgroundColor,
    trailingForegroundColor,
    menuBackgroundColor,
    menuForegroundColor,
    dividerColor,
    leadingCustomSize,
    trailingCustomSize,
    trailingSelectedRadius,
    gap,
    menuStyle,
    popupDecoration,
    bottomSheetDecoration,
    hoveredRadius,
    pressedRadius,
    size,
  ]);
}
