// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../internal/_tokens_adapter.dart';
import '../../internal/_button_motion.dart';
import '../../internal/m3e_base_button_state.dart';
import '../../style/button_tokens_adapter.dart';
import '../../style/m3e_button_decoration.dart';
import '../../style/m3e_button_enums.dart';
import '../../style/m3e_motion.dart';
import '../../internal/button_constants.dart';

const Alignment _kAlignmentCenter = Alignment.center;
const VisualDensity _kVisualDensityStandard = VisualDensity.standard;
const Duration _kDurationZero = Duration.zero;
const InteractiveInkFeatureFactory _kInkRippleSplashFactory =
    InkRipple.splashFactory;

// ---------------------------------------------------------------------------
// M3EToggleButton
// ---------------------------------------------------------------------------

/// Material 3 Expressive Toggle Button.
///
/// Morphs between round (unchecked) and square (checked) shapes.
/// Supports icon-only, icon+label, and label-only content.
///
/// ## Compose parity
///
/// In Compose, `EnlargeOnPressNode` animates a 0→1 progress value that the
/// parent `ButtonGroupMeasurePolicy` uses to compute compressed/expanded widths
/// at layout time — the button itself is completely unaware of compression.
/// We follow the same contract: **this widget knows nothing about being
/// squeezed**. All width changes are applied externally by `_AnimatedWidthToggle`
/// (a `SizedBox` around this widget). The internal padding and content always
/// use their natural values; `ClipRect` on the content Row handles the visual
/// crop when the external `SizedBox` is narrower than natural.
class M3EToggleButton extends StatefulWidget {
  const M3EToggleButton({
    super.key,
    required this.onCheckedChange,
    this.icon,
    this.checkedIcon,
    this.label,
    this.checkedLabel,
    this.checked,
    this.style = M3EButtonStyle.filled,
    this.size = M3EButtonSize.sm,
    this.enabled = true,
    this.isGroupConnected = false,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.decoration,
    this.mouseCursor,
    this.statesController,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.semanticLabel,
  });

  final Widget? icon;
  final Widget? checkedIcon;

  /// Optional text label. When set, button is content-width (not square).
  final Widget? label;

  /// Label shown when checked. Falls back to [label] when null.
  final Widget? checkedLabel;

  final bool? checked;
  final ValueChanged<bool> onCheckedChange;

  final M3EButtonStyle style;
  final M3EButtonSize size;
  final bool enabled;

  final bool isGroupConnected;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  /// Optional decoration that bundles styling properties together.
  ///
  /// When provided, decoration values take precedence over individual flat
  /// parameters (e.g. [backgroundColor], [foregroundColor], etc.).
  final M3EToggleButtonDecoration? decoration;

  /// Optional mouse cursor to show when hovering over the button.
  final MouseCursor? mouseCursor;

  // ── Decoration property helpers ───────────────────────────────────────────

  Color? get decorationBackgroundColor => decoration?.backgroundColor;
  Color? get decorationForegroundColor => decoration?.foregroundColor;
  Color? get decorationCheckedBackgroundColor =>
      decoration?.checkedBackgroundColor;
  Color? get decorationCheckedForegroundColor =>
      decoration?.checkedForegroundColor;
  BorderSide? get decorationBorderSide => decoration?.borderSide;
  M3EMotion? get decorationMotion => decoration?.motion;
  M3EHapticFeedback get decorationHaptic =>
      decoration?.haptic ?? M3EHapticFeedback.none;
  double? get decorationCheckedRadius => decoration?.checkedRadius;
  double? get decorationUncheckedRadius => decoration?.uncheckedRadius;
  double? get decorationPressedRadius => decoration?.pressedRadius;
  double? get decorationConnectedInnerRadius =>
      decoration?.connectedInnerRadius;

  final WidgetStatesController? statesController;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<bool>? onFocusChange;
  final String? semanticLabel;

  @override
  State<M3EToggleButton> createState() => _M3EToggleButtonState();
}

class _M3EToggleButtonState extends State<M3EToggleButton>
    with M3EBaseButtonState<M3EToggleButton> {
  late bool _localChecked;
  late M3EButtonTokensAdapter _tokens;
  late M3EButtonMeasurements _measurements;

  Widget? _cachedIcon;
  Widget? _cachedLabel;
  bool _cachedIconChecked = false;
  bool _cachedLabelChecked = false;

  bool get _isChecked => widget.checked ?? _localChecked;
  bool get _hasLabel => _isChecked
      ? (widget.checkedLabel != null || widget.label != null)
      : widget.label != null;

  Widget? get _effectiveIcon {
    final checked = _isChecked;
    if (_cachedIconChecked == checked && _cachedIcon != null) {
      return _cachedIcon;
    }
    _cachedIconChecked = checked;
    _cachedIcon = checked ? (widget.checkedIcon ?? widget.icon) : widget.icon;
    return _cachedIcon;
  }

  Widget? get _effectiveLabel {
    final checked = _isChecked;
    if (_cachedLabelChecked == checked && _cachedLabel != null) {
      return _cachedLabel;
    }
    _cachedLabelChecked = checked;
    _cachedLabel = checked
        ? (widget.checkedLabel ?? widget.label)
        : widget.label;
    return _cachedLabel;
  }

  @override
  M3EButtonSize get buttonSize => widget.size;

  @override
  WidgetStatesController? get externalStatesController =>
      widget.statesController;

  @override
  FocusNode? get externalFocusNode => widget.focusNode;

  @override
  M3EMotion? get effectiveMotion => widget.decorationMotion;

  @override
  void initState() {
    super.initState();
    _localChecked = widget.checked ?? false;
    initBaseButtonState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tokens = M3EButtonTokensAdapter(context);
    _tokens.didChangeDependencies();
    _updateMeasurements();
    updateLabelStyle(context);
    updateSpringMotion();
  }

  void _updateMeasurements() {
    _measurements = _tokens.measurements(widget.size);
  }

  @override
  void didUpdateWidget(covariant M3EToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    handleStatesControllerUpdate(
      oldWidget.statesController,
      widget.statesController,
    );
    handleFocusNodeUpdate(oldWidget.focusNode, widget.focusNode);
    if (widget.checked != null && oldWidget.checked != widget.checked) {
      _localChecked = widget.checked!;
    }
    if (oldWidget.size != widget.size) {
      _updateMeasurements();
    }
    if (oldWidget.size != widget.size ||
        oldWidget.checked != widget.checked ||
        oldWidget.decoration?.foregroundColor !=
            widget.decoration?.foregroundColor ||
        oldWidget.decoration?.checkedForegroundColor !=
            widget.decoration?.checkedForegroundColor ||
        oldWidget.style != widget.style) {
      updateLabelStyle(context);
    }
    if (widget.decoration?.motion != oldWidget.decoration?.motion) {
      updateSpringMotion();
    }
    if (widget.icon != oldWidget.icon ||
        widget.checkedIcon != oldWidget.checkedIcon ||
        widget.label != oldWidget.label ||
        widget.checkedLabel != oldWidget.checkedLabel) {
      _cachedIcon = null;
      _cachedLabel = null;
    }
  }

  void _handleTap() {
    if (!widget.enabled) return;
    if (widget.decorationHaptic != M3EHapticFeedback.none) {
      switch (widget.decorationHaptic) {
        case M3EHapticFeedback.light:
          HapticFeedback.lightImpact();
        case M3EHapticFeedback.medium:
          HapticFeedback.mediumImpact();
        case M3EHapticFeedback.heavy:
          HapticFeedback.heavyImpact();
        case M3EHapticFeedback.none:
          break;
      }
    }
    final newChecked = !_isChecked;
    if (widget.checked == null) setState(() => _localChecked = newChecked);
    widget.onCheckedChange(newChecked);
  }

  @override
  Widget build(BuildContext context) {
    final m = _measurements;
    final checked = _isChecked;

    final double halfHeight = m.height / 2;
    final double squareRad = _tokens.squareRadius(widget.size);
    final double pressRad = _tokens.pressedRadius(widget.size);
    final BorderRadius fullyRound = BorderRadius.circular(halfHeight);
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    final double outerRad = halfHeight;
    final double innerRad =
        widget.decorationConnectedInnerRadius ??
        ButtonGroupTokens.kConnectedInnerRadius;
    final double pressInnerRad =
        widget.decorationPressedRadius ??
        ButtonGroupTokens.kConnectedPressedInnerRadius;

    final bool freezeStart = widget.isFirstInGroup;
    final bool freezeEnd = widget.isLastInGroup;
    final bool freezeLeft = isRtl ? freezeEnd : freezeStart;
    final bool freezeRight = isRtl ? freezeStart : freezeEnd;

    final BorderRadius restingShape = widget.decorationUncheckedRadius != null
        ? BorderRadius.circular(widget.decorationUncheckedRadius!)
        : fullyRound;
    final BorderRadius squareShape = BorderRadius.circular(
      widget.decorationCheckedRadius ?? squareRad,
    );
    final BorderRadius pressSquish = BorderRadius.circular(
      widget.decorationPressedRadius ?? pressRad,
    );

    final double hPad = _hasLabel ? m.hPadding : m.hPadding / 2;

    return buildAnimatedContent(
      builder: (context, pressed, hovered, focused) {
        final BorderRadius targetRadius;
        final effectivelyEnabled = widget.enabled;
        if (widget.isGroupConnected) {
          final BorderRadius restingRadius = BorderRadiusDirectional.horizontal(
            start: Radius.circular(widget.isFirstInGroup ? outerRad : innerRad),
            end: Radius.circular(widget.isLastInGroup ? outerRad : innerRad),
          ).resolve(Directionality.of(context));

          final BorderRadius pressRadius = BorderRadiusDirectional.horizontal(
            start: Radius.circular(
              widget.isFirstInGroup ? outerRad : pressInnerRad,
            ),
            end: Radius.circular(
              widget.isLastInGroup ? outerRad : pressInnerRad,
            ),
          ).resolve(Directionality.of(context));

          final double hoverInnerRad =
              widget.decoration?.connectedHoveredInnerRadius ??
              _tokens.connectedHoveredInnerRadius();
          final BorderRadius hoverRadius = BorderRadiusDirectional.horizontal(
            start: Radius.circular(
              widget.isFirstInGroup ? outerRad : hoverInnerRad,
            ),
            end: Radius.circular(
              widget.isLastInGroup ? outerRad : hoverInnerRad,
            ),
          ).resolve(Directionality.of(context));

          targetRadius = (effectivelyEnabled && pressed)
              ? pressRadius
              : (effectivelyEnabled && hovered)
              ? hoverRadius
              : checked
              ? fullyRound
              : restingRadius;
        } else {
          final BorderRadius hoverShape =
              widget.decoration?.hoveredRadius != null
              ? BorderRadius.circular(widget.decoration!.hoveredRadius!)
              : BorderRadius.circular(_tokens.hoveredRadius(widget.size));

          targetRadius = (effectivelyEnabled && pressed)
              ? pressSquish
              : (effectivelyEnabled && hovered)
              ? hoverShape
              : checked
              ? squareShape
              : restingShape;
        }

        Widget core = RepaintBoundary(
          child: RadiusAndPaddingMotion(
            motion: springMotion,
            internalLeft: hPad,
            internalRight: hPad,
            internalTop: 0,
            internalBottom: 0,
            targetRadius: targetRadius,
            freezeTopLeft: widget.isGroupConnected ? freezeLeft : false,
            freezeBottomLeft: widget.isGroupConnected ? freezeLeft : false,
            freezeTopRight: widget.isGroupConnected ? freezeRight : false,
            freezeBottomRight: widget.isGroupConnected ? freezeRight : false,
            builder: (animatedPadding, animatedRadius) {
              final buttonCore = _buildCore(m, animatedPadding, animatedRadius);
              return FocusRing(
                focused: focused,
                radius: animatedRadius,
                child: buttonCore,
              );
            },
          ),
        );

        final fixedWidth = widget.size.width;
        if (fixedWidth != null) core = SizedBox(width: fixedWidth, child: core);

        return core;
      },
    );
  }

  Widget _buildCore(
    M3EButtonMeasurements m,
    EdgeInsets internalPadding,
    BorderRadius animatedRadius,
  ) {
    final checked = _isChecked;
    final double minW = _hasLabel ? 0 : m.height;

    final buttonShape = WidgetStateProperty.all<OutlinedBorder>(
      RoundedRectangleBorder(borderRadius: animatedRadius),
    );
    final padding = WidgetStateProperty.all<EdgeInsetsGeometry>(
      internalPadding,
    );

    final style = _buildButtonStyle(checked, minW, buttonShape, padding);

    final Widget content = _buildContent(m, checked);

    final VoidCallback? onPressed = widget.enabled ? _handleTap : null;

    Widget button;
    switch (widget.style) {
      case M3EButtonStyle.filled:
        button = FilledButton(
          style: style,
          onPressed: onPressed,
          statesController: statesController,
          focusNode: effectiveFocusNode,
          autofocus: widget.autofocus,
          onFocusChange: widget.onFocusChange,
          child: content,
        );
      case M3EButtonStyle.tonal:
        button = FilledButton.tonal(
          style: style,
          onPressed: onPressed,
          statesController: statesController,
          focusNode: effectiveFocusNode,
          autofocus: widget.autofocus,
          onFocusChange: widget.onFocusChange,
          child: content,
        );
      case M3EButtonStyle.elevated:
        button = ElevatedButton(
          style: style,
          onPressed: onPressed,
          statesController: statesController,
          focusNode: effectiveFocusNode,
          autofocus: widget.autofocus,
          onFocusChange: widget.onFocusChange,
          child: content,
        );
      case M3EButtonStyle.outlined:
        button = OutlinedButton(
          style: style,
          onPressed: onPressed,
          statesController: statesController,
          focusNode: effectiveFocusNode,
          autofocus: widget.autofocus,
          onFocusChange: widget.onFocusChange,
          child: content,
        );
      case M3EButtonStyle.text:
        button = TextButton(
          style: style,
          onPressed: onPressed,
          statesController: statesController,
          focusNode: effectiveFocusNode,
          autofocus: widget.autofocus,
          onFocusChange: widget.onFocusChange,
          child: content,
        );
    }

    return Semantics(
      label: widget.semanticLabel,
      checked: _isChecked,
      child: button,
    );
  }

  ButtonStyle _buildButtonStyle(
    bool checked,
    double minW,
    WidgetStateProperty<OutlinedBorder> buttonShape,
    WidgetStateProperty<EdgeInsetsGeometry> padding,
  ) {
    final tokens = _tokens;
    final cs = tokens.c;

    final Color bgColor;
    final Color fgColor;

    switch (widget.style) {
      case M3EButtonStyle.filled:
        bgColor = checked
            ? (widget.decorationCheckedBackgroundColor ?? cs.primary)
            : (widget.decorationBackgroundColor ?? cs.surfaceContainerHighest);
        fgColor = checked
            ? (widget.decorationCheckedForegroundColor ?? cs.onPrimary)
            : (widget.decorationForegroundColor ?? cs.onSurfaceVariant);
        break;

      case M3EButtonStyle.elevated:
        bgColor = checked
            ? (widget.decorationCheckedBackgroundColor ?? cs.primary)
            : (widget.decorationBackgroundColor ?? cs.surface);
        fgColor = checked
            ? (widget.decorationCheckedForegroundColor ?? cs.onPrimary)
            : (widget.decorationForegroundColor ?? cs.primary);
        break;

      case M3EButtonStyle.tonal:
        bgColor = checked
            ? (widget.decorationCheckedBackgroundColor ?? cs.secondaryContainer)
            : (widget.decorationBackgroundColor ?? cs.surfaceContainerHighest);
        fgColor = checked
            ? (widget.decorationCheckedForegroundColor ??
                  cs.onSecondaryContainer)
            : (widget.decorationForegroundColor ?? cs.onSurfaceVariant);
        break;

      case M3EButtonStyle.outlined:
        bgColor = checked
            ? (widget.decorationCheckedBackgroundColor ?? cs.secondaryContainer)
            : (widget.decorationBackgroundColor ?? Colors.transparent);
        fgColor = checked
            ? (widget.decorationCheckedForegroundColor ??
                  cs.onSecondaryContainer)
            : (widget.decorationForegroundColor ?? cs.onSurface);
        break;

      case M3EButtonStyle.text:
        bgColor = widget.decorationBackgroundColor ?? Colors.transparent;
        fgColor = checked
            ? (widget.decorationCheckedForegroundColor ?? cs.primary)
            : (widget.decorationForegroundColor ?? cs.onSurface);
        break;
    }

    final bool transparent =
        widget.style == M3EButtonStyle.outlined ||
        widget.style == M3EButtonStyle.text;

    final outlineColor = widget.style == M3EButtonStyle.outlined
        ? (widget.decorationForegroundColor ?? tokens.outline())
        : null;

    return ButtonStyle(
      alignment: _kAlignmentCenter,
      textStyle: WidgetStateProperty.all(labelStyle),
      minimumSize: WidgetStateProperty.all(Size(minW, _measurements.height)),
      padding: padding,
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return widget.decoration?.disabledForegroundColor ??
              cs.onSurface.withValues(
                alpha: ButtonConstants.kDisabledForegroundAlpha,
              );
        }
        return fgColor;
      }),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          if (widget.decoration?.disabledBackgroundColor != null) {
            return widget.decoration!.disabledBackgroundColor!;
          }
          return transparent
              ? Colors.transparent
              : cs.onSurface.withValues(
                  alpha: ButtonConstants.kDisabledBackgroundAlpha,
                );
        }
        return transparent ? Colors.transparent : bgColor;
      }),
      shape: buttonShape,
      elevation: WidgetStateProperty.resolveWith((states) {
        return tokens.elevation(widget.style, states);
      }),
      side: outlineColor != null
          ? WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return BorderSide(
                  color: cs.onSurface.withValues(
                    alpha: ButtonConstants.kDisabledOutlineAlpha,
                  ),
                  width: 1,
                );
              }
              return BorderSide(color: outlineColor, width: 1);
            })
          : WidgetStateProperty.all(BorderSide.none),
      mouseCursor: WidgetStatePropertyAll<MouseCursor?>(
        widget.decoration?.mouseCursor ??
            widget.mouseCursor ??
            SystemMouseCursors.click,
      ),
      animationDuration: _kDurationZero,
      visualDensity: _kVisualDensityStandard,
      splashFactory: _kInkRippleSplashFactory,
    );
  }

  /// Builds icon-only, icon+label, or label-only content.
  ///
  /// The button always renders at its natural preferred size. Any
  /// neighbor-squish compression is applied externally by `_AnimatedWidthToggle`.
  ///
  /// The content row uses a `SizedBox(height: m.height)` + `FittedBox` wrapper
  /// so Flutter measures it at natural width first, then clips it to the
  /// squeezed width without overflow assertions. The same path is used by the
  /// offstage measurer so measured widths match visible output.
  Widget _buildContent(M3EButtonMeasurements m, bool checked) {
    final Widget? effectiveIcon = _effectiveIcon;
    final Widget? effectiveLabel = _effectiveLabel;

    if (effectiveIcon == null && effectiveLabel == null) {
      return const SizedBox.shrink();
    }

    Widget? iconWidget;
    if (effectiveIcon != null) {
      iconWidget = RepaintBoundary(
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: m.height / 3,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
          softWrap: false,
          child: IconTheme.merge(
            data: IconThemeData(size: m.iconSize),
            child: effectiveIcon,
          ),
        ),
      );
    }

    Widget? labelWidget;
    if (effectiveLabel != null) {
      labelWidget = DefaultTextStyle.merge(
        maxLines: 1,
        softWrap: false,
        child: effectiveLabel,
      );
    }

    final Widget naturalRow;
    if (iconWidget != null && labelWidget != null) {
      naturalRow = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          SizedBox(width: m.iconGap.toDouble()),
          labelWidget,
        ],
      );
    } else {
      naturalRow = iconWidget ?? labelWidget!;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) {
          return naturalRow;
        }
        return SizedBox(
          height: m.height,
          child: FittedBox(
            fit: BoxFit.none,
            alignment: _kAlignmentCenter,
            clipBehavior: Clip.hardEdge,
            child: naturalRow,
          ),
        );
      },
    );
  }
}
