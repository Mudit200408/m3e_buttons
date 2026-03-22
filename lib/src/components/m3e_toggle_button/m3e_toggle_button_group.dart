// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:m3e_buttons/m3e_buttons.dart';
import 'package:m3e_buttons/src/core/m3e_button_group_provider.dart';
import 'package:m3e_buttons/src/internal/_tokens_adapter.dart';
import 'package:m3e_buttons/src/internal/button_constants.dart';
import 'package:motor/motor.dart';

// ---------------------------------------------------------------------------
// M3EToggleButtonGroupAction
// ---------------------------------------------------------------------------

/// Intent for moving focus to the next button in the group.
class _MoveFocusIntent extends Intent {
  final int direction;
  const _MoveFocusIntent(this.direction);
}

/// Declarative description of a single toggle button inside [M3EToggleButtonGroup].
///
/// Each action maps one-to-one to an [M3EToggleButton]. The group manages the
/// checked state; actions declare only the content and per-button overrides.
///
/// ## Content
///
/// At least one of [icon] or [label] must be provided. [checkedIcon] and
/// [checkedLabel] override the displayed content when the button is checked;
/// they fall back to [icon] and [label] when null.
///
/// ## State management
///
/// Do **not** set [checked] when the group uses [M3EToggleButtonGroup.selectedIndex]
/// or [M3EToggleButtonGroup.selectedIndices]. Use the group-level selection props
/// for controlled state. Setting per-action [checked] alongside group-controlled
/// selection will trigger an assertion in debug mode.
///
/// ## Per-button customisation
///
/// Pass [decoration] to override colors, motion, or radii for this specific
/// button. Group-level decoration values serve as defaults; per-action decoration
/// takes precedence.
class M3EToggleButtonGroupAction {
  const M3EToggleButtonGroupAction({
    this.icon,
    this.checkedIcon,
    this.label,
    this.checkedLabel,
    this.checked,
    this.enabled = true,
    this.decoration,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.semanticLabel,
  }) : assert(
         icon != null || label != null,
         'M3EToggleButtonGroupAction must have either an icon or a label.',
       );

  /// Icon shown in the **unchecked** state.
  final Widget? icon;

  /// Icon shown in the **checked** state. Falls back to [icon] when null.
  final Widget? checkedIcon;

  /// Optional text label shown alongside the icon (or alone if no icon).
  ///
  /// When set, the button is wider than its height (content-driven width).
  /// The neighbor-squish animation still works correctly; widths are measured
  /// after the first frame.
  final Widget? label;

  /// Label shown when checked. Falls back to [label] when null.
  final Widget? checkedLabel;

  /// External checked state (controlled). Leave null to let the group manage.
  final bool? checked;

  final bool enabled;

  /// Optional decoration that bundles styling properties together.
  ///
  /// When provided, decoration values take precedence over individual flat
  /// parameters (e.g. [backgroundColor], [foregroundColor], etc.).
  final M3EToggleButtonDecoration? decoration;

  // ── Effective value helpers ──────────────────────────────────────────────

  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<bool>? onFocusChange;
  final String? semanticLabel;
}

// ---------------------------------------------------------------------------
// M3EToggleButtonGroup
// ---------------------------------------------------------------------------

/// A horizontal (or vertical) row of [M3EToggleButton]s with optional
/// neighbor-squish animation and connected-group shape morphing.
///
/// ## Group types
/// - **standard** — buttons are spaced apart. When [neighborSquish] is true
///   the pressed button widens and its neighbors compress.
/// - **connected** — buttons share borders with no gap. Inner corners squish
///   on press and expand to a pill on selection.
///
/// ## Labeled toggle buttons
///
/// Each action can optionally carry a [M3EToggleButtonGroupAction.label] widget.
/// When a label is present the button displays: icon + gap + label.
///
/// The neighbor-squish animation is fully supported for labeled buttons.
/// Widths are measured after the first frame; on the first frame no
/// animation is applied (buttons size freely from content).
///
/// ```dart
/// M3EToggleButtonGroup(
///   actions: [
///     M3EToggleButtonGroupAction(
///       icon: const Icon(Icons.format_bold),
///       label: const Text('Bold'),
///       onCheckedChange: (v) {},
///     ),
///   ],
/// )
/// ```
///
/// ## Neighbor squish opt-out
///
/// Set `neighborSquish: false` to disable the width expansion entirely.
class M3EToggleButtonGroup extends StatefulWidget {
  const M3EToggleButtonGroup({
    super.key,
    required this.actions,
    this.type = M3EButtonGroupType.standard,
    this.shape = M3EButtonShape.round,
    this.size = M3EButtonSize.sm,
    this.style = M3EButtonStyle.filled,
    this.density = M3EButtonGroupDensity.regular,
    this.spacing,
    this.direction = Axis.horizontal,

    /// When set, exactly one button is checked at a time.
    this.selectedIndex,

    /// When set, multiple buttons can be checked at the same time.
    this.selectedIndices,

    /// Called when any button's selection state changes.
    /// Emits the next selected index, or `null` when the current selection is
    /// toggled off. Only used when [selectedIndices] is not set.
    this.onSelectedIndexChanged,

    /// Called when any button's selection state changes in multi-select mode.
    /// Emits the new set of selected indices.
    this.onSelectedIndicesChanged,

    /// Whether the two neighbors of a pressed button compress while it expands.
    /// Defaults to `true`. Set to `false` to opt out.
    this.neighborSquish = true,

    /// How many logical pixels the pressed button grows (and each neighbor
    /// shrinks by half). Defaults to 8 dp.
    this.expandBy = 8.0,

    this.haptic = M3EHapticFeedback.none,

    this.decoration,

    this.semanticLabel,

    /// Optional clipping applied to the group container.
    this.clipBehavior = Clip.none,
    this.overflow = M3EButtonGroupOverflow.scroll,
    this.overflowIcon,
    this.overflowDropdownDecoration = const M3EOverflowDropdownDecoration(),
    this.overflowBottomSheetDecoration =
        const M3EOverflowBottomSheetDecoration(),
    this.overflowMenuStyle = M3EButtonGroupOverflowMenuStyle.dropdown,

    /// Custom overflow strategy for advanced use cases.
    ///
    /// When provided, this takes precedence over the [overflow] enum value.
    /// Use this to implement custom overflow behavior that isn't covered by
    /// the built-in options (none, scroll, menu, paging).
    ///
    /// See [OverflowStrategy] for details on implementing custom strategies.
    ///
    /// ## Example
    /// ```dart
    /// class MyCustomOverflow extends OverflowStrategy {
    ///   const MyCustomOverflow();
    ///
    ///   @override
    ///   String get id => 'my-custom';
    ///
    ///   @override
    ///   Widget buildLayout({...}) { ... }
    ///
    ///   @override
    ///   Widget? buildOverflowTrigger({...}) { ... }
    ///
    ///   @override
    ///   Future<int?> showOverflowMenu({...}) { ... }
    /// }
    ///
    /// M3EToggleButtonGroup(
    ///   actions: [...],
    ///   overflowStrategy: const MyCustomOverflow(),
    /// )
    /// ```
    this.overflowStrategy,
  });

  final List<M3EToggleButtonGroupAction> actions;

  final M3EButtonGroupType type;
  final M3EButtonShape shape;
  final M3EButtonSize size;
  final M3EButtonStyle style;
  final M3EButtonGroupDensity density;
  final double? spacing;
  final Axis direction;

  final int? selectedIndex;
  final Set<int>? selectedIndices;
  final ValueChanged<int?>? onSelectedIndexChanged;
  final ValueChanged<Set<int>>? onSelectedIndicesChanged;

  final bool neighborSquish;
  final double expandBy;

  final M3EHapticFeedback haptic;

  /// Optional group-level decoration that bundles styling properties together.
  ///
  /// When provided, decoration values take precedence over individual flat
  /// parameters (e.g. [backgroundColor], [foregroundColor], etc.).
  final M3EToggleButtonDecoration? decoration;

  // ── Effective value helpers ──────────────────────────────────────────────

  final String? semanticLabel;

  /// Clip behavior for the group container. Defaults to [Clip.none].
  final Clip clipBehavior;

  /// Overflow management behavior when [direction] is constrained.
  final M3EButtonGroupOverflow overflow;

  /// Icon for overflow triggers when [overflow] is menu or paging.
  final Widget? overflowIcon;

  /// Decoration for the overflow dropdown menu.
  final M3EOverflowDropdownDecoration overflowDropdownDecoration;

  /// Decoration for the overflow bottom sheet.
  final M3EOverflowBottomSheetDecoration overflowBottomSheetDecoration;

  /// How to display the overflow menu when [overflow] == menu.
  final M3EButtonGroupOverflowMenuStyle overflowMenuStyle;

  /// Custom overflow strategy for advanced use cases.
  ///
  /// When provided, this takes precedence over the [overflow] enum value.
  /// Use this to implement custom overflow behavior.
  final OverflowStrategy? overflowStrategy;

  bool get _connected => type == M3EButtonGroupType.connected;

  @override
  State<M3EToggleButtonGroup> createState() => _M3EToggleButtonGroupState();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _M3EToggleButtonGroupState extends State<M3EToggleButtonGroup> {
  late List<WidgetStatesController> _controllers;
  late List<FocusNode?> _focusNodes;
  late int _layoutSignature;
  late int _focusNodeSignature;
  late final M3EButtonGroupOverflowController _overflowController;
  int? _lastOverflowSelectionIndex;

  final ValueNotifier<int?> _pressedIndexNotifier = ValueNotifier<int?>(null);
  final ValueNotifier<int?> _focusedIndexNotifier = ValueNotifier<int?>(null);
  double _pressProgress = 0.0;
  bool _isWaitingForRelease = false;
  Duration? _releaseDeadline;

  // P0-8: Directionality read once per build and reused by every
  // _buildButton call — avoids N InheritedWidget lookups per frame.
  bool _isRtl = false;

  // Generation counter to ensure asynchronous remeasure callbacks do not
  // apply stale measurements if the actions or layout have since changed.
  int _measurementGeneration = 0;

  // Track currently focused index for keyboard navigation
  int _focusedIndex = 0;

  /// One GlobalKey per action slot for unchecked state measurement.
  late List<GlobalKey> _uncheckedKeys;

  /// One GlobalKey per action slot for checked state measurement.
  late List<GlobalKey> _checkedKeys;

  /// Measured natural widths indexed by action slot.
  late List<double?> _measuredUncheckedWidths;
  late List<double?> _measuredCheckedWidths;

  /// True when any action in the current actions list has a label.
  bool _hasAnyLabel = false;

  /// Cached height used as the fallback natural size for icon-only buttons
  /// before measurement completes. Recomputed in [didChangeDependencies] and
  /// when [widget.size] change in [didUpdateWidget].
  double _iconOnlyNaturalSizeCache =
      M3EButtonSize.sm.height ?? 40.0; // sm token height default

  // ── Measurer isolation controllers ───────────────────────────────────────
  //
  // Inert WidgetStatesControllers injected into the offstage label-measurer
  // buttons. Because no listeners are attached to these controllers, press/hover
  // events in the measurer never fire notifications that propagate into
  // _M3EToggleButtonGroupState and cause spurious remeasure cycles.
  List<WidgetStatesController>? _measurerUncheckedControllers;
  List<WidgetStatesController>? _measurerCheckedControllers;

  bool get _supportsAnimatedSquish =>
      widget.direction == Axis.horizontal &&
      !widget._connected &&
      widget.neighborSquish;

  bool get _needsLabelMeasurement => _supportsAnimatedSquish && _hasAnyLabel;

  bool _computeHasAnyLabel() => widget.actions.any(
    (action) => action.label != null || action.checkedLabel != null,
  );

  bool _needsDistinctCheckedMeasurement(M3EToggleButtonGroupAction action) {
    return action.checkedLabel != null || action.checkedIcon != null;
  }

  void _initMeasurementState() {
    _uncheckedKeys = List.generate(widget.actions.length, (_) => GlobalKey());
    _checkedKeys = List.generate(widget.actions.length, (_) => GlobalKey());
    _measuredUncheckedWidths = List.filled(widget.actions.length, null);
    _measuredCheckedWidths = List.filled(widget.actions.length, null);
    // Reset stable overflow sentinel — layout changed, old extents are stale.
    _overflowController.stableAllOverflowMeasured.value = false;
    // Recreate isolated measurer controllers for the new action count.
    _disposeMeasurerControllers();
    _initMeasurerControllers();
  }

  void _initMeasurerControllers() {
    _measurerUncheckedControllers = List.generate(
      widget.actions.length,
      (_) => WidgetStatesController(), // empty, no listeners added
    );
    _measurerCheckedControllers = List.generate(
      widget.actions.length,
      (_) => WidgetStatesController(),
    );
  }

  void _disposeMeasurerControllers() {
    if (_measurerUncheckedControllers != null) {
      for (final c in _measurerUncheckedControllers!) {
        c.dispose();
      }
      _measurerUncheckedControllers = null;
    }
    if (_measurerCheckedControllers != null) {
      for (final c in _measurerCheckedControllers!) {
        c.dispose();
      }
      _measurerCheckedControllers = null;
    }
  }

  bool _isMeasured(int index) {
    return _measuredUncheckedWidths[index] != null &&
        _measuredCheckedWidths[index] != null;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  late List<M3EToggleButtonDecoration> _cachedDecorations;

  @override
  void initState() {
    super.initState();
    _overflowController = M3EButtonGroupOverflowController();
    _overflowController.stableAllOverflowMeasured.addListener(
      _handleOverflowChange,
    );
    assert(() {
      final hasControlledGroup =
          widget.onSelectedIndexChanged != null ||
          widget.onSelectedIndicesChanged != null;
      if (!hasControlledGroup) return true;
      for (final action in widget.actions) {
        if (action.checked != null) {
          throw FlutterError(
            'M3EToggleButtonGroup: Do not set action.checked when the group uses '
            'onSelectedIndexChanged or onSelectedIndicesChanged.\n'
            'Use selectedIndex / selectedIndices on the group instead. '
            'Mixing per-action checked state with group-controlled selection '
            'produces undefined behavior.',
          );
        }
      }
      return true;
    }(), '');
    _layoutSignature = _computeLayoutSignature(widget);
    _focusNodeSignature = _computeFocusNodeSignature(widget.actions);
    _initControllers();
    _initFocusNodes();
    _hasAnyLabel = _computeHasAnyLabel();
    _updateDecorations();
    _initMeasurementState();
    _scheduleMeasurementIfNeeded();
  }

  void _handleOverflowChange() {
    if (mounted) setState(() {});
  }

  void _updateDecorations() {
    _cachedDecorations = List.generate(widget.actions.length, (i) {
      final action = widget.actions[i];
      return M3EToggleButtonDecoration(
        size: action.decoration?.size ?? widget.decoration?.size,
        backgroundColor:
            action.decoration?.backgroundColor ??
            widget.decoration?.backgroundColor,
        foregroundColor:
            action.decoration?.foregroundColor ??
            widget.decoration?.foregroundColor,
        checkedBackgroundColor:
            action.decoration?.checkedBackgroundColor ??
            widget.decoration?.checkedBackgroundColor,
        checkedForegroundColor:
            action.decoration?.checkedForegroundColor ??
            widget.decoration?.checkedForegroundColor,
        borderSide:
            action.decoration?.borderSide ?? widget.decoration?.borderSide,
        motion: action.decoration?.motion ?? widget.decoration?.motion,
        haptic:
            action.decoration?.haptic ??
            widget.decoration?.haptic ??
            widget.haptic,
        checkedRadius:
            action.decoration?.checkedRadius ??
            widget.decoration?.checkedRadius,
        uncheckedRadius:
            action.decoration?.uncheckedRadius ??
            widget.decoration?.uncheckedRadius,
        pressedRadius:
            action.decoration?.pressedRadius ??
            widget.decoration?.pressedRadius,
        connectedInnerRadius:
            action.decoration?.connectedInnerRadius ??
            widget.decoration?.connectedInnerRadius,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIconOnlyNaturalSizeCache();
    // Re-measure only when text scale / locale changes — label pixel widths differ.
    _scheduleMeasurementIfNeeded();
  }

  /// Resolves the token height for an icon-only button and caches it.
  /// Called from [didChangeDependencies] (theme/scale change) and from
  /// [didUpdateWidget] when [size] changes.
  void _updateIconOnlyNaturalSizeCache() {
    final tokens = M3EButtonTokensAdapter(context);
    tokens.didChangeDependencies();
    final m = tokens.measurements(
      _mapSize(widget.size),
      override: widget.decoration?.size,
    );
    _iconOnlyNaturalSizeCache = m.height;
  }

  @override
  void didUpdateWidget(covariant M3EToggleButtonGroup old) {
    super.didUpdateWidget(old);
    assert(() {
      final hasControlledGroup =
          widget.onSelectedIndexChanged != null ||
          widget.onSelectedIndicesChanged != null;
      if (hasControlledGroup) {
        for (final action in widget.actions) {
          if (action.checked != null) {
            throw FlutterError(
              'M3EToggleButtonGroup: Do not set action.checked when the group uses '
              'onSelectedIndexChanged or onSelectedIndicesChanged.\n'
              'Use selectedIndex / selectedIndices on the group instead. '
              'Mixing per-action checked state with group-controlled selection '
              'produces undefined behavior.',
            );
          }
        }
      }
      return true;
    }(), '');
    final bool actionsIdentityChanged = !identical(old.actions, widget.actions);
    final bool maybeScalarLayoutChanged = _didScalarLayoutFieldsChange(
      old,
      widget,
    );

    final nextLayoutSignature =
        (actionsIdentityChanged || maybeScalarLayoutChanged)
        ? _computeLayoutSignature(widget)
        : _layoutSignature;
    final nextFocusNodeSignature = actionsIdentityChanged
        ? _computeFocusNodeSignature(widget.actions)
        : _focusNodeSignature;
    final bool lengthChanged = old.actions.length != widget.actions.length;
    final bool layoutChanged = nextLayoutSignature != _layoutSignature;
    final bool focusNodesChanged =
        nextFocusNodeSignature != _focusNodeSignature;

    if (lengthChanged) {
      _disposeControllers();
      _initControllers();
      _pressedIndexNotifier.value = null;
    }
    if (lengthChanged || focusNodesChanged) {
      _disposeFocusNodes();
      _initFocusNodes();
    }
    if (lengthChanged || layoutChanged) {
      _measurementGeneration++;
      _hasAnyLabel = _computeHasAnyLabel();
      _updateDecorations();
      _initMeasurementState();
      _scheduleMeasurementIfNeeded();
    }
    if (old.size != widget.size ||
        old.decoration?.size != widget.decoration?.size) {
      _updateIconOnlyNaturalSizeCache();
    }
    if (_overflowController.windowStartIndex.value >= widget.actions.length) {
      _overflowController.windowStartIndex.value = 0;
    }
    if (widget.selectedIndex != _lastOverflowSelectionIndex) {
      _lastOverflowSelectionIndex = null;
    }
    _layoutSignature = nextLayoutSignature;
    _focusNodeSignature = nextFocusNodeSignature;
    // NOTE: Do NOT re-trigger measurement on every rebuild.
    // Measurement only re-runs when actions length changes (above) or when
    // didChangeDependencies fires (text scale / locale). Re-measuring on every
    // setState would read widths from inside _AnimatedWidthToggle's SizedBox
    // constraint, causing the naturalSize to grow with each tap.
  }

  @override
  void dispose() {
    _overflowController.stableAllOverflowMeasured.removeListener(
      _handleOverflowChange,
    );
    _overflowController.dispose();
    _pressedIndexNotifier.dispose();
    _focusedIndexNotifier.dispose();
    _disposeControllers();
    _disposeFocusNodes();
    _disposeMeasurerControllers();
    super.dispose();
  }

  // ── Measurement ───────────────────────────────────────────────────────────
  //
  // IMPORTANT: _buttonKeys are attached to buttons rendered INSIDE the Offstage
  // measurer row (see build()), which is unconstrained. This guarantees we always
  // measure the button's true natural width — never the animated SizedBox width.
  // If keys were inside _AnimatedWidthToggle, re-measurement after a press would
  // read the expanded width, causing naturalSize to grow with every tap.

  void _measureButtonWidths(int generation) {
    if (!mounted || generation != _measurementGeneration) return;
    bool anyChanged = false;
    for (int i = 0; i < widget.actions.length; i++) {
      final action = widget.actions[i];
      if (action.label == null && action.checkedLabel == null) {
        continue;
      }

      // Measure Unchecked
      final ctxU = _uncheckedKeys[i].currentContext;
      final renderU = ctxU?.findRenderObject() as RenderBox?;
      if (renderU != null && renderU.hasSize) {
        final measured = renderU.size.width;
        if (_measuredUncheckedWidths[i] != measured) {
          _measuredUncheckedWidths[i] = measured;
          anyChanged = true;
        }
      }

      if (!_needsDistinctCheckedMeasurement(action)) {
        final resolved =
            _measuredUncheckedWidths[i] ?? _iconOnlyNaturalSizeCache;
        if (_measuredCheckedWidths[i] != resolved) {
          _measuredCheckedWidths[i] = resolved;
          anyChanged = true;
        }
        continue;
      }

      // Measure Checked
      final ctxC = _checkedKeys[i].currentContext;
      final renderC = ctxC?.findRenderObject() as RenderBox?;
      if (renderC != null && renderC.hasSize) {
        final measured = renderC.size.width;
        if (_measuredCheckedWidths[i] != measured) {
          _measuredCheckedWidths[i] = measured;
          anyChanged = true;
        }
      }
    }
    if (anyChanged && mounted && generation == _measurementGeneration) {
      setState(() {
        // Promote the stable sentinel once all extents are available so that
        // subsequent interaction-driven rebuilds (press / hover) never cause
        // the overflow layout to regress to the scrollable fallback.
        if (_allOverflowExtentsMeasured()) {
          _overflowController.stableAllOverflowMeasured.value = true;
        }
      });
    }
  }

  void _scheduleMeasurementIfNeeded() {
    if (_needsLabelMeasurement) {
      final gen = _measurementGeneration;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _measureButtonWidths(gen),
      );
    }
  }

  // ── Controllers / FocusNodes ──────────────────────────────────────────────

  void _initControllers() {
    _controllers = List.generate(widget.actions.length, (i) {
      final c = WidgetStatesController();
      c.addListener(() => _onButtonStateChanged(i, c));
      return c;
    });
  }

  void _disposeControllers() {
    for (final c in _controllers) {
      c.dispose();
    }
    _controllers.clear();
  }

  void _initFocusNodes() {
    _focusNodes = List<FocusNode?>.generate(widget.actions.length, (i) {
      final actionNode = widget.actions[i].focusNode;
      if (actionNode != null) {
        return null;
      }

      final internalNode = FocusNode(
        debugLabel: 'M3EToggleButtonGroup Button $i',
      );
      return internalNode;
    });
  }

  void _disposeFocusNodes() {
    for (final node in _focusNodes) {
      node?.dispose();
    }
    _focusNodes.clear();
  }

  int _computeFocusNodeSignature(List<M3EToggleButtonGroupAction> actions) {
    int hash = 0;
    for (final action in actions) {
      hash = Object.hash(hash, action.focusNode);
    }
    return hash;
  }

  int _computeLayoutSignature(M3EToggleButtonGroup group) {
    int actionsHash = 0;
    for (final action in group.actions) {
      actionsHash = Object.hash(actionsHash, _actionLayoutSignature(action));
    }

    final styleHash = Object.hash(
      group.type,
      group.shape,
      group.size,
      group.style,
      group.density,
      group.decoration,
    );

    return Object.hash(
      group.direction,
      group.neighborSquish,
      group.expandBy,
      group.overflow,
      group.overflowMenuStyle,
      styleHash,
      actionsHash,
    );
  }

  int _actionLayoutSignature(M3EToggleButtonGroupAction action) {
    return Object.hash(
      _widgetContentHash(action.icon),
      _widgetContentHash(action.checkedIcon),
      _widgetContentHash(action.label),
      _widgetContentHash(action.checkedLabel),
      action.enabled,
      action.decoration,
    );
  }

  int _widgetContentHash(Widget? w) {
    if (w == null) return 0;
    if (w is Icon) return w.icon.hashCode;
    if (w is Text) return w.data.hashCode;
    return w.hashCode;
  }

  bool _didScalarLayoutFieldsChange(
    M3EToggleButtonGroup old,
    M3EToggleButtonGroup next,
  ) {
    return old.type != next.type ||
        old.shape != next.shape ||
        old.size != next.size ||
        old.style != next.style ||
        old.density != next.density ||
        old.direction != next.direction ||
        old.neighborSquish != next.neighborSquish ||
        old.expandBy != next.expandBy ||
        old.overflow != next.overflow ||
        old.overflowMenuStyle != next.overflowMenuStyle ||
        old.decoration != next.decoration;
  }

  void _focusNextButton(int currentIndex, int direction) {
    if (widget.actions.isEmpty) return;
    int nextIndex = currentIndex + direction;
    final int start = nextIndex;

    // Wrap around logic while skipping disabled buttons
    while (true) {
      if (nextIndex < 0) {
        nextIndex = widget.actions.length - 1;
      } else if (nextIndex >= widget.actions.length) {
        nextIndex = 0;
      }

      if (widget.actions[nextIndex].enabled) break;

      nextIndex += direction;
      // Looped back to where we started and no enabled button found
      if (nextIndex == start || nextIndex == currentIndex) return;
    }

    if (nextIndex >= 0 && nextIndex < widget.actions.length) {
      (widget.actions[nextIndex].focusNode ?? _focusNodes[nextIndex])
          ?.requestFocus();
    }
  }

  // ── Press tracking ────────────────────────────────────────────────────────

  void _onButtonStateChanged(int index, WidgetStatesController c) {
    if (!mounted) return;

    // Press tracking for neighbor squish
    final isPressed = c.value.contains(WidgetState.pressed);
    if (isPressed && _pressedIndexNotifier.value != index) {
      _isWaitingForRelease = false;
      _releaseDeadline = null;
      _setPressedIndex(index);
    } else if (!isPressed && _pressedIndexNotifier.value == index) {
      _isWaitingForRelease = true;
      _scheduleReleaseCheck();
    }

    // Focus tracking for connected gap expansion
    final isFocused = c.value.contains(WidgetState.focused);
    if (isFocused && _focusedIndexNotifier.value != index) {
      // Must use addPostFrameCallback to avoid setStates during build phase
      // if focus changes synchronously during layout.
      if (SchedulerBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) _focusedIndexNotifier.value = index;
        });
      } else {
        _focusedIndexNotifier.value = index;
      }
    } else if (!isFocused && _focusedIndexNotifier.value == index) {
      if (SchedulerBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted && _focusedIndexNotifier.value == index) {
            _focusedIndexNotifier.value = null;
          }
        });
      } else {
        _focusedIndexNotifier.value = null;
      }
    }
  }

  void _scheduleReleaseCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _releaseDeadline =
          SchedulerBinding.instance.currentFrameTimeStamp +
          ButtonConstants.kReleaseTimeout;
      _checkRelease();
    });
  }

  void _checkRelease() {
    if (!_isWaitingForRelease || !mounted) return;
    final timedOut =
        _releaseDeadline != null &&
        SchedulerBinding.instance.currentFrameTimeStamp >= _releaseDeadline!;
    if (_pressProgress >= ButtonConstants.kPressReleaseThreshold || timedOut) {
      _isWaitingForRelease = false;
      _releaseDeadline = null;
      _pressProgress = 0.0;
      _setPressedIndex(null);
    }
  }

  void _setPressedIndex(int? index) {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pressedIndexNotifier.value = index;
      });
    } else {
      _pressedIndexNotifier.value = index;
    }
  }

  void _onProgressUpdate(double progress) {
    _pressProgress = progress;
    if (_isWaitingForRelease) _checkRelease();
  }

  // ── Keyboard navigation via Shortcuts/Actions ─────────────────────────────

  Map<ShortcutActivator, Intent> get _arrowKeyShortcuts {
    final int rtlFlip = _isRtl ? -1 : 1;
    if (widget.direction == Axis.horizontal) {
      return {
        const SingleActivator(LogicalKeyboardKey.arrowRight): _MoveFocusIntent(
          1 * rtlFlip,
        ),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): _MoveFocusIntent(
          -1 * rtlFlip,
        ),
      };
    }
    return {
      const SingleActivator(LogicalKeyboardKey.arrowDown):
          const _MoveFocusIntent(1),
      const SingleActivator(LogicalKeyboardKey.arrowUp): const _MoveFocusIntent(
        -1,
      ),
    };
  }

  void _focusNextButtonFromFocused(int direction) {
    _focusNextButton(_focusedIndex, direction);
  }

  // ── Natural size helpers (FEAT-07) ────────────────────────────────────────

  double _naturalSizeForButton(BuildContext context, int index) {
    if (index < 0 || index >= _measuredUncheckedWidths.length) {
      return _iconOnlyNaturalSizeCache;
    }

    final bool checked = _isToggleActionSelected(index);

    final widths = checked ? _measuredCheckedWidths : _measuredUncheckedWidths;
    return widths[index] ?? _iconOnlyNaturalSizeCache;
  }

  // ── debugFillProperties ───────────────────────────────────────────────────

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<M3EButtonGroupType>('type', widget.type));
    properties.add(EnumProperty<M3EButtonShape>('shape', widget.shape));
    properties.add(DiagnosticsProperty<M3EButtonSize>('size', widget.size));
    properties.add(IntProperty('actionCount', widget.actions.length));
    properties.add(
      EnumProperty<M3EButtonGroupOverflow>('overflow', widget.overflow),
    );
    properties.add(
      FlagProperty(
        'neighborSquish',
        value: widget.neighborSquish,
        ifTrue: 'squish',
      ),
    );
    properties.add(
      FlagProperty('hasLabels', value: _hasAnyLabel, ifTrue: 'labeled'),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final metrics = metricsFor(
      context,
      widget.size,
      widget.density,
      isConnected: widget._connected,
    );
    final spacing =
        widget.spacing ?? (widget._connected ? 0.0 : metrics.spacing);
    // Read directionality once — shared by all _buildButton calls.
    _isRtl = Directionality.of(context) == TextDirection.rtl;

    final group = M3EButtonGroupProvider(
      controller: _overflowController,
      child: M3EButtonGroupScope(
        type: widget.type,
        shape: widget.shape,
        size: widget.size,
        density: widget.density,
        direction: widget.direction,
        child: _buildContent(context, spacing),
      ),
    );

    Widget result = Shortcuts(
      shortcuts: _arrowKeyShortcuts,
      child: Actions(
        actions: <Type, Action<Intent>>{
          _MoveFocusIntent: _MoveFocusAction(_focusNextButtonFromFocused),
        },
        child: FocusTraversalGroup(
          policy: WidgetOrderTraversalPolicy(),
          child: Semantics(
            container: true,
            label: widget.semanticLabel,
            child: group,
          ),
        ),
      ),
    );

    // FEAT-07: Offstage measurer — renders labeled buttons unconstrained so
    // _measureButtonWidths reads true natural widths, never animated widths.
    // Only built when any action has a label.
    if (_needsLabelMeasurement) {
      final measurer = ExcludeFocus(
        child: ExcludeSemantics(
          child: Offstage(
            offstage: true,
            child: RepaintBoundary(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < widget.actions.length; i++)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Unchecked state — inert statesController prevents any
                        // internal interaction state from propagating up to the
                        // group state and triggering spurious remeasure rebuilds.
                        M3EToggleButton(
                          key: _uncheckedKeys[i],
                          checked: false,
                          icon: widget.actions[i].icon,
                          checkedIcon: widget.actions[i].checkedIcon,
                          label: widget.actions[i].label,
                          checkedLabel: widget.actions[i].checkedLabel,
                          onCheckedChange: (_) {},
                          style: widget.style,
                          size: _mapSize(widget.size),
                          decoration: M3EToggleButtonDecoration(
                            size:
                                widget.actions[i].decoration?.size ??
                                widget.decoration?.size,
                          ),
                          statesController: _measurerUncheckedControllers?[i],
                        ),
                        if (_needsDistinctCheckedMeasurement(widget.actions[i]))
                          M3EToggleButton(
                            key: _checkedKeys[i],
                            checked: true,
                            icon: widget.actions[i].icon,
                            checkedIcon: widget.actions[i].checkedIcon,
                            label: widget.actions[i].label,
                            checkedLabel: widget.actions[i].checkedLabel,
                            onCheckedChange: (_) {},
                            style: widget.style,
                            size: _mapSize(widget.size),
                            decoration: M3EToggleButtonDecoration(
                              size:
                                  widget.actions[i].decoration?.size ??
                                  widget.decoration?.size,
                            ),
                            statesController: _measurerCheckedControllers?[i],
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      result = Stack(children: [result, measurer]);
    }

    // Apply an outer clip only when the caller opts into clipping.
    if (widget.clipBehavior != Clip.none) {
      result = ClipRRect(
        clipBehavior: widget.clipBehavior,
        borderRadius: radiusFor(context, widget.shape, widget.size),
        child: result,
      );
    }

    return result;
  }

  // ── Button construction ────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context, double spacing) {
    if (widget.actions.isEmpty) return const SizedBox.shrink();

    if (widget.overflowStrategy != null) {
      return _buildWithCustomStrategy(context, spacing);
    }

    switch (widget.overflow) {
      case M3EButtonGroupOverflow.none:
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxMain = widget.direction == Axis.horizontal
                ? constraints.maxWidth
                : constraints.maxHeight;
            return _buildAnimatedLinearLayout(context, spacing, maxMain);
          },
        );
      case M3EButtonGroupOverflow.scroll:
        return _linearScrollable(context, spacing);
      case M3EButtonGroupOverflow.menu:
        return _linearWithOverflowMenu(context, spacing);
      case M3EButtonGroupOverflow.experimentalPaging:
        return _linearWithExperimentalPaging(context, spacing);
    }
  }

  Widget _buildWithCustomStrategy(BuildContext context, double spacing) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxMain = widget.direction == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;

        final strategy = widget.overflowStrategy!;
        int visibleCount = widget.actions.length;

        // Start by assuming we don't know the trigger extent
        double triggerExtent = 0;

        if (maxMain.isFinite) {
          final hasMeasurements =
              _overflowController.stableAllOverflowMeasured.value ||
              !_needsLabelMeasurement ||
              _allOverflowExtentsMeasured();

          // If we have extents, compute the visible count safely
          if (hasMeasurements) {
            final itemExtents = [
              for (int i = 0; i < widget.actions.length; i++)
                _itemMainExtentForOverflow(context, i),
            ];

            // Estimate the trigger. Since we can't reliably predict the size of
            // a custom strategy's trigger until it's built, we fall back to a
            // standard icon-only measurement.
            triggerExtent = M3EButtonGroupOverflowController.roundConsumed(
              _defaultOverflowTriggerExtent(),
            );

            visibleCount = _overflowController.computeVisibleCountForMenu(
              maxMain: maxMain,
              itemExtents: itemExtents,
              triggerExtent: triggerExtent,
              separatorExtent: () => _separatorMainExtent(spacing),
            );
          } else {
            // Unmeasured labels yet, just return scrollable fallback
            return _linearScrollable(context, spacing);
          }
        }

        // The strategy is responsible for laying out visible items.
        // We pass the actual action index (0, 1, 2, ...) to buildButton so that
        // keys remain stable across rebuilds — critical for smooth animations.
        final layout = strategy.buildLayout(
          context: context,
          actions: widget.actions,
          visibleCount: visibleCount,
          spacing: spacing,
          direction: widget.direction,
          style: widget.style,
          size: widget.size,
          decoration: widget.decoration,
          connected: widget._connected,
          isRtl: _isRtl,
          buildButton: (index, isFirst, isLast) {
            return _repaintButton(
              KeyedSubtree(
                key: ValueKey('custom-item-$index'),
                child: M3EButtonGroupItemScope(
                  index: index,
                  count:
                      visibleCount +
                      (visibleCount < widget.actions.length ? 1 : 0),
                  child: _buildButton(context, index, isFirst, isLast),
                ),
              ),
            );
          },
        );

        final hiddenCount = widget.actions.length - visibleCount;

        if (hiddenCount > 0) {
          final trigger = strategy.buildOverflowTrigger(
            context: context,
            hiddenCount: hiddenCount,
            style: widget.style,
            size: widget.size,
            decoration: widget.decoration,
            connected: widget._connected,
            isFirst: visibleCount == 0,
            isLast: true,
            onPressed: () async {
              final selectedAction = _selectedToggleActionInRange(
                visibleCount,
                widget.actions.length - 1,
              );
              final selectedIndex = selectedAction != null
                  ? widget.actions.indexOf(selectedAction)
                  : null;
              final result = await strategy.showOverflowMenu(
                context: context,
                actions: widget.actions,
                firstHiddenIndex: visibleCount,
                selectedIndex: selectedIndex,
              );
              if (result != null && mounted) {
                strategy.onItemSelected(result);
                _handleOverflowActionSelection(result);
              }
            },
            checked:
                _selectedToggleActionInRange(
                  visibleCount,
                  widget.actions.length - 1,
                ) !=
                null,
          );

          if (trigger != null) {
            final children = <Widget>[
              layout,
              _buildGap(context, visibleCount - 1, spacing),
              _repaintButton(
                KeyedSubtree(
                  key: const ValueKey('custom-overflow-trigger'),
                  child: M3EButtonGroupItemScope(
                    index: ButtonConstants.kOverflowTriggerScopeIndex,
                    count: 1,
                    child: trigger,
                  ),
                ),
              ),
            ];

            return _axisFlex(children);
          }
        }

        return layout;
      },
    );
  }

  // Same isolation rationale as in _M3EButtonGroupState._repaintButton:
  // each visible button slot gets its own layer so a spring animation or
  // ink ripple on one button does not dirty the paint of its siblings.
  Widget _repaintButton(Widget child) => RepaintBoundary(child: child);

  Widget _buildAnimatedLinearLayout(
    BuildContext context,
    double spacing,
    double maxMain,
  ) {
    final count = widget.actions.length;
    final squishEnabled = _supportsAnimatedSquish;

    final naturalSizes = squishEnabled
        ? [for (int i = 0; i < count; i++) _naturalSizeForButton(context, i)]
        : const <double>[];

    final totalNaturalWidth = squishEnabled
        ? naturalSizes.fold(0.0, (s, w) => s + w) +
              (count > 1 ? spacing * (count - 1) : 0.0)
        : 0.0;

    final slack = squishEnabled && maxMain.isFinite
        ? (maxMain - totalNaturalWidth).clamp(0.0, double.infinity)
        : double.infinity;
    final clampedExpandBy = slack.isFinite
        ? widget.expandBy.clamp(0.0, slack)
        : widget.expandBy;

    final children = <Widget>[];
    for (var i = 0; i < count; i++) {
      final button = _buildButton(context, i, i == 0, i == count - 1);
      final scoped = M3EButtonGroupItemScope(
        index: i,
        count: count,
        child: button,
      );

      final item = (squishEnabled && (!_hasAnyLabel || _isMeasured(i)))
          ? RepaintBoundary(
              child: _AnimatedWidthToggle(
                key: ValueKey('awt_$i'),
                pressedIndexNotifier: _pressedIndexNotifier,
                index: i,
                expandBy: clampedExpandBy,
                naturalSize: naturalSizes[i],
                maxWidth: maxMain.isFinite
                    ? naturalSizes[i] + slack
                    : double.infinity,
                motion:
                    widget.decoration?.motion ?? M3EMotion.standardSpatialFast,
                onProgressUpdate: _onProgressUpdate,
                child: scoped,
              ),
            )
          : scoped;

      children.add(
        _repaintButton(
          KeyedSubtree(key: ValueKey('toggle-item-$i'), child: item),
        ),
      );
      if (i < count - 1) {
        children.add(_buildGap(context, i, spacing));
      }
    }

    return _axisFlex(children);
  }

  Widget _linearScrollable(BuildContext context, double spacing) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isBounded = widget.direction == Axis.horizontal
            ? constraints.hasBoundedWidth
            : constraints.hasBoundedHeight;
        final maxMain = widget.direction == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;
        final core = _buildAnimatedLinearLayout(context, spacing, maxMain);
        if (!isBounded) return core;
        return SingleChildScrollView(
          scrollDirection: widget.direction,
          primary: false,
          clipBehavior: Clip.hardEdge,
          child: core,
        );
      },
    );
  }

  Widget _linearWithOverflowMenu(BuildContext context, double spacing) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxMain = widget.direction == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;
        if (!maxMain.isFinite) {
          return _buildAnimatedLinearLayout(context, spacing, maxMain);
        }

        // Use the stable sentinel to decide whether we have valid measurements.
        // `_allOverflowExtentsMeasured()` can transiently return false during
        // an interaction-driven rebuild (press/hover setState) while key
        // contexts are in flux — causing a one-frame flash to _linearScrollable.
        // `_overflowController.stableAllOverflowMeasured.value` is only cleared on genuine layout changes.
        final hasMeasurements =
            _overflowController.stableAllOverflowMeasured.value ||
            !_needsLabelMeasurement ||
            _allOverflowExtentsMeasured();

        if (!hasMeasurements) {
          return _linearScrollable(context, spacing);
        }

        final itemExtents = [
          for (int i = 0; i < widget.actions.length; i++)
            _itemMainExtentForOverflow(context, i),
        ];

        final visibleCount = _overflowController.computeVisibleCountForMenu(
          maxMain: maxMain,
          itemExtents: itemExtents,
          triggerExtent: M3EButtonGroupOverflowController.roundConsumed(
            _defaultOverflowTriggerExtent(),
          ),
          separatorExtent: () => _separatorMainExtent(spacing),
        );

        if (visibleCount >= widget.actions.length) {
          return _buildAnimatedLinearLayout(context, spacing, maxMain);
        }

        final visibleItems = <Widget>[];
        final visibleScopeCount = visibleCount + 1;
        for (int i = 0; i < visibleCount; i++) {
          if (visibleItems.isNotEmpty)
            visibleItems.add(_buildGap(context, i - 1, spacing));
          visibleItems.add(
            _repaintButton(
              KeyedSubtree(
                key: ValueKey('toggle-menu-item-$i'),
                child: M3EButtonGroupItemScope(
                  index: i,
                  count: visibleScopeCount,
                  child: _buildButton(context, i, i == 0, false),
                ),
              ),
            ),
          );
        }

        if (visibleItems.isNotEmpty)
          visibleItems.add(_buildGap(context, visibleCount - 1, spacing));
        visibleItems.add(
          _repaintButton(
            _buildOverflowMenuTrigger(
              context,
              firstHiddenIndex: visibleCount,
              isFirst: visibleCount == 0,
              isLast: true,
            ),
          ),
        );
        return _axisFlex(visibleItems);
      },
    );
  }

  Widget _linearWithExperimentalPaging(BuildContext context, double spacing) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxMain = widget.direction == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;
        if (!maxMain.isFinite) {
          return _buildAnimatedLinearLayout(context, spacing, maxMain);
        }

        // Same stable-sentinel guard as _linearWithOverflowMenu — prevents
        // one-frame flash to _linearScrollable during interaction rebuilds.
        final hasMeasurements =
            _overflowController.stableAllOverflowMeasured.value ||
            (!_needsLabelMeasurement) ||
            _allOverflowExtentsMeasured();

        if (!hasMeasurements) {
          return _linearScrollable(context, spacing);
        }

        final itemExtents = [
          for (int i = 0; i < widget.actions.length; i++)
            _itemMainExtentForOverflow(context, i),
        ];

        return ValueListenableBuilder<int>(
          valueListenable: _overflowController.windowStartIndex,
          builder: (context, windowStartIndex, _) {
            final pagingWindow = _overflowController.computePagingWindow(
              maxMain: maxMain,
              itemExtents: itemExtents,
              triggerExtent: M3EButtonGroupOverflowController.roundConsumed(
                _defaultOverflowTriggerExtent(),
              ),
              separatorBetweenItems: (_) => _separatorMainExtent(spacing),
              separatorBeforeOverflow: (isFirst) =>
                  isFirst ? 0.0 : _separatorMainExtent(spacing),
            );

            final visibleItems = <Widget>[];
            int localIndex = 0;
            if (pagingWindow.needsBack) {
              visibleItems.add(
                _repaintButton(
                  KeyedSubtree(
                    key: const ValueKey('toggle-paging-back'),
                    child: _buildOverflowTrigger(
                      context,
                      targetIndex: 0,
                      isBack: true,
                      isFirst: true,
                      isLast: false,
                    ),
                  ),
                ),
              );
              localIndex++;
            }

            for (int i = pagingWindow.start; i <= pagingWindow.end; i++) {
              if (visibleItems.isNotEmpty)
                visibleItems.add(_buildGap(context, i - 1, spacing));
              final isLastVisible =
                  i == pagingWindow.end && !pagingWindow.needsForward;
              visibleItems.add(
                _repaintButton(
                  KeyedSubtree(
                    key: ValueKey('toggle-paging-item-$i'),
                    child: M3EButtonGroupItemScope(
                      index: localIndex++,
                      count: _pagingScopeCount(pagingWindow),
                      child: _buildButton(
                        context,
                        i,
                        !pagingWindow.needsBack && i == pagingWindow.start,
                        isLastVisible,
                      ),
                    ),
                  ),
                ),
              );
            }

            if (pagingWindow.needsForward) {
              if (visibleItems.isNotEmpty)
                visibleItems.add(_buildGap(context, pagingWindow.end, spacing));
              visibleItems.add(
                _repaintButton(
                  KeyedSubtree(
                    key: const ValueKey('toggle-paging-forward'),
                    child: _buildOverflowTrigger(
                      context,
                      targetIndex: pagingWindow.end + 1,
                      isBack: false,
                      isFirst: false,
                      isLast: true,
                    ),
                  ),
                ),
              );
            }

            return _axisFlex(visibleItems);
          },
        );
      },
    );
  }

  Widget _axisFlex(List<Widget> children) => widget.direction == Axis.horizontal
      ? Row(mainAxisSize: MainAxisSize.min, children: children)
      : Column(mainAxisSize: MainAxisSize.min, children: children);

  Widget _buildGap(BuildContext context, int beforeIndex, double spacing) {
    return ValueListenableBuilder<int?>(
      valueListenable: _focusedIndexNotifier,
      builder: (context, focusedIndex, _) {
        double gap = widget._connected
            ? ButtonGroupTokens.kConnectedGap
            : spacing;

        if (widget._connected) {
          final bool isFocusedLeft = focusedIndex == beforeIndex;
          final bool isFocusedRight = focusedIndex == beforeIndex + 1;
          if (isFocusedLeft || isFocusedRight) {
            gap +=
                ButtonConstants.kFocusRingGap + ButtonConstants.kFocusRingWidth;
          }
        }

        final double width = widget.direction == Axis.horizontal ? gap : 0;
        final double height = widget.direction == Axis.vertical ? gap : 0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          width: widget.direction == Axis.horizontal ? null : width,
          height: widget.direction == Axis.vertical ? null : height,
          constraints: BoxConstraints(minWidth: width, minHeight: height),
        );
      },
    );
  }

  double _separatorMainExtent(double spacing) =>
      M3EButtonGroupOverflowController.roundConsumed(
        widget._connected ? ButtonGroupTokens.kConnectedGap : spacing,
      );

  bool _allOverflowExtentsMeasured() {
    for (int i = 0; i < widget.actions.length; i++) {
      final action = widget.actions[i];
      if (action.label != null || action.checkedLabel != null) {
        if (!_isMeasured(i)) return false;
      }
    }
    return true;
  }

  double _itemMainExtentForOverflow(BuildContext context, int index) {
    if (widget.direction == Axis.horizontal) {
      return M3EButtonGroupOverflowController.roundConsumed(
        _naturalSizeForButton(context, index),
      );
    }
    final tokens = M3EButtonTokensAdapter(context);
    tokens.didChangeDependencies();
    final measurements = tokens.measurements(
      _mapSize(widget.size),
      override:
          widget.actions[index].decoration?.size ?? widget.decoration?.size,
    );
    return M3EButtonGroupOverflowController.roundConsumed(measurements.height);
  }

  double _defaultOverflowTriggerExtent() {
    if (widget.direction == Axis.vertical) return _iconOnlyNaturalSizeCache;
    return M3EButtonGroupOverflowController.roundConsumed(
      (widget.decoration?.size?.width ?? 0.0) > _iconOnlyNaturalSizeCache
          ? widget.decoration!.size!.width!
          : _iconOnlyNaturalSizeCache,
    );
  }

  int _pagingScopeCount(ButtonGroupOverflowPagingWindow window) {
    int count = window.end >= window.start
        ? (window.end - window.start + 1)
        : 0;
    if (window.needsBack) count++;
    if (window.needsForward) count++;
    return count;
  }

  Widget _buildOverflowTrigger(
    BuildContext context, {
    required int targetIndex,
    required bool isBack,
    required bool isFirst,
    required bool isLast,
  }) {
    return _buildOverflowIndicatorButton(
      context,
      start: isBack ? 0 : targetIndex,
      end: isBack
          ? _overflowController.windowStartIndex.value - 1
          : widget.actions.length - 1,
      icon: isBack
          ? const Icon(Icons.arrow_back_rounded)
          : (widget.overflowIcon ?? const Icon(Icons.more_horiz)),
      semanticLabel: isBack
          ? MaterialLocalizations.of(context).previousPageTooltip
          : 'More options',
      isFirst: isFirst,
      isLast: isLast,
      onPressed: () {
        _overflowController.windowStartIndex.value = targetIndex;
      },
    );
  }

  Widget _buildOverflowMenuTrigger(
    BuildContext context, {
    required int firstHiddenIndex,
    required bool isFirst,
    required bool isLast,
  }) {
    return _buildOverflowIndicatorButton(
      context,
      start: firstHiddenIndex,
      end: widget.actions.length - 1,
      icon: widget.overflowIcon ?? const Icon(Icons.more_horiz),
      semanticLabel: MaterialLocalizations.of(context).showMenuTooltip,
      isFirst: isFirst,
      isLast: isLast,
      onPressed: () => _openOverflowMenu(context, firstHiddenIndex),
    );
  }

  Widget _buildOverflowIndicatorButton(
    BuildContext context, {
    required int start,
    required int end,
    required Widget icon,
    required String semanticLabel,
    required bool isFirst,
    required bool isLast,
    required VoidCallback onPressed,
  }) {
    return KeyedSubtree(
      key: ValueKey('toggle-overflow-$start-$end-$isFirst-$isLast'),
      child: M3EButtonGroupItemScope(
        index: isLast ? ButtonConstants.kOverflowTriggerScopeIndex : 0,
        count: 1,
        child: M3EToggleButton(
          icon: icon,
          checked: _selectedToggleActionInRange(start, end) != null,
          onCheckedChange: (_) => onPressed(),
          style: widget.style,
          size: _mapSize(widget.size),
          decoration: widget.decoration,
          isGroupConnected: widget._connected,
          isFirstInGroup: isFirst,
          isLastInGroup: isLast,
          semanticLabel: semanticLabel,
        ),
      ),
    );
  }

  Future<void> _openOverflowMenu(
    BuildContext context,
    int firstHiddenIndex,
  ) async {
    if (firstHiddenIndex >= widget.actions.length) return;
    final selectedIndex = switch (widget.overflowMenuStyle) {
      M3EButtonGroupOverflowMenuStyle.dropdown => _showOverflowDropdown(
        context,
        firstHiddenIndex,
      ),
      M3EButtonGroupOverflowMenuStyle.bottomSheet => _showOverflowBottomSheet(
        context,
        firstHiddenIndex,
      ),
    };
    final result = await selectedIndex;
    if (!mounted || result == null) return;
    _handleOverflowActionSelection(result);
  }

  Future<int?> _showOverflowDropdown(
    BuildContext context,
    int firstHiddenIndex,
  ) async {
    final triggerBox = context.findRenderObject() as RenderBox?;
    if (triggerBox == null) return null;

    final screenSize = MediaQuery.of(context).size;
    final triggerTopLeft = triggerBox.localToGlobal(Offset.zero);
    final triggerBottomRight = triggerBox.localToGlobal(
      triggerBox.size.bottomRight(Offset.zero),
    );
    final theme = Theme.of(context);

    final cs = theme.colorScheme;

    final dec = widget.overflowDropdownDecoration;

    final menuWidth = (triggerBox.size.width + 176.0).clamp(
      dec.minWidth,
      dec.maxWidth,
    );

    final spaceBelow =
        screenSize.height -
        triggerBottomRight.dy -
        ButtonConstants.kScreenEdgePadding;
    final spaceAbove = triggerTopLeft.dy - ButtonConstants.kScreenEdgePadding;

    final approxHeight = ((widget.actions.length - firstHiddenIndex) * 60.0)
        .clamp(96.0, dec.maxHeight);
    final showAbove = spaceBelow < approxHeight && spaceAbove > spaceBelow;

    final menuRadius =
        widget.decoration?.checkedRadius ??
        widget.decoration?.uncheckedRadius ??
        20.0;

    double left = triggerBottomRight.dx - menuWidth;
    left += dec.offset.dx;
    left = left.clamp(
      ButtonConstants.kScreenEdgePadding,
      screenSize.width - menuWidth - ButtonConstants.kScreenEdgePadding,
    );

    final bool isClampedToLeft = left <= ButtonConstants.kScreenEdgePadding;
    final alignment = Alignment(
      isClampedToLeft ? -1.0 : 1.0,
      showAbove ? 1.0 : -1.0,
    );

    final itemCount = widget.actions.length - firstHiddenIndex;

    return showGeneralDialog<int>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (dialogContext, _, _) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(dialogContext).pop(),
              ),
            ),
            Positioned(
              left: left,
              top: showAbove ? null : triggerBottomRight.dy + dec.offset.dy,
              bottom: showAbove
                  ? screenSize.height - triggerTopLeft.dy + dec.offset.dy
                  : null,
              width: menuWidth,
              child: _SpringMenuWrapper(
                motion: dec.motion,
                alignment: alignment,
                child: FocusScope(
                  autofocus: true,
                  child: Material(
                    color: dec.backgroundColor ?? cs.surfaceContainer,
                    surfaceTintColor: Colors.transparent,
                    elevation: dec.elevation,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          dec.borderRadius ?? BorderRadius.circular(menuRadius),
                      side:
                          dec.border ??
                          BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.7),
                          ),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: (showAbove ? spaceAbove : spaceBelow).clamp(
                          0.0,
                          dec.maxHeight,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: dec.useCardList
                                ? _buildCardListItems(
                                    dialogContext,
                                    firstHiddenIndex,
                                    itemCount,
                                    dec,
                                    cs,
                                  )
                                : _buildStandardListItems(
                                    dialogContext,
                                    firstHiddenIndex,
                                    itemCount,
                                    dec,
                                    cs,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(opacity: curved, child: child);
      },
    );
  }

  Widget _buildCardListItems(
    BuildContext context,
    int firstHiddenIndex,
    int itemCount,
    M3EOverflowDropdownDecoration dec,
    ColorScheme cs,
  ) {
    final outerR = dec.outerRadius;
    final innerR = dec.innerRadius;
    final selectedR = dec.selectedBorderRadius ?? outerR;

    return ListView.separated(
      padding: dec.padding,
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, _) => SizedBox(height: dec.itemGap),
      itemBuilder: (context, listIndex) {
        final actionIndex = firstHiddenIndex + listIndex;
        return _buildCardListItem(
          context,
          actionIndex,
          listIndex,
          itemCount,
          dec,
          cs,
          outerR,
          innerR,
          selectedR,
        );
      },
    );
  }

  Widget _buildCardListItem(
    BuildContext context,
    int actionIndex,
    int listIndex,
    int total,
    M3EOverflowDropdownDecoration dec,
    ColorScheme cs,
    double outerR,
    double innerR,
    double selectedR,
  ) {
    final action = widget.actions[actionIndex];
    final selected = _isToggleActionSelected(actionIndex);

    final isFirst = listIndex == 0;
    final isLast = listIndex == total - 1;
    final isSingle = total == 1;

    BorderRadius borderRadius;
    if (selected) {
      borderRadius = BorderRadius.circular(selectedR);
    } else if (isSingle) {
      borderRadius = BorderRadius.circular(outerR);
    } else if (isFirst) {
      borderRadius = BorderRadius.vertical(
        top: Radius.circular(outerR),
        bottom: Radius.circular(innerR),
      );
    } else if (isLast) {
      borderRadius = BorderRadius.vertical(
        top: Radius.circular(innerR),
        bottom: Radius.circular(outerR),
      );
    } else {
      borderRadius = BorderRadius.circular(innerR);
    }

    final bgColor = selected
        ? (dec.selectedBackgroundColor ?? cs.secondaryContainer)
        : (dec.itemBackgroundColor ?? cs.surfaceContainerHigh);

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: action.enabled
            ? () => Navigator.of(context).pop(actionIndex)
            : null,
        borderRadius: borderRadius,
        child: Padding(
          padding: dec.itemPadding,
          child: Row(
            children: [
              IconTheme.merge(
                data: IconThemeData(
                  size: 18,
                  color: selected ? cs.onSecondaryContainer : cs.onSurface,
                ),
                child: _overflowMenuLeading(actionIndex),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DefaultTextStyle.merge(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: selected ? cs.onSecondaryContainer : cs.onSurface,
                  ),
                  child: _overflowMenuTitle(actionIndex),
                ),
              ),
              if (selected)
                dec.trailing ??
                    Icon(
                      Icons.check_rounded,
                      color: cs.onSecondaryContainer,
                      size: 20,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardListItems(
    BuildContext context,
    int firstHiddenIndex,
    int itemCount,
    M3EOverflowDropdownDecoration dec,
    ColorScheme cs,
  ) {
    return ListView.builder(
      padding: dec.padding,
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, listIndex) {
        final actionIndex = firstHiddenIndex + listIndex;
        return _buildStandardListItem(context, actionIndex, dec, cs);
      },
    );
  }

  Widget _buildStandardListItem(
    BuildContext context,
    int actionIndex,
    M3EOverflowDropdownDecoration dec,
    ColorScheme cs,
  ) {
    final action = widget.actions[actionIndex];
    final selected = _isToggleActionSelected(actionIndex);

    final itemRadius = dec.selectedBorderRadius ?? dec.outerRadius;

    final fgColor = selected
        ? (widget.decoration?.checkedForegroundColor ?? cs.onSecondaryContainer)
        : (widget.decoration?.foregroundColor ?? cs.onSurface);

    final bgColor = selected
        ? (dec.selectedBackgroundColor ?? cs.secondaryContainer)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: action.enabled ? bgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(itemRadius),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(itemRadius),
          onTap: action.enabled
              ? () => Navigator.of(context).pop(actionIndex)
              : null,
          child: Padding(
            padding: dec.itemPadding,
            child: Row(
              children: [
                IconTheme.merge(
                  data: IconThemeData(
                    size: 18,
                    color: action.enabled
                        ? fgColor
                        : fgColor.withValues(
                            alpha: ButtonConstants.kDisabledForegroundAlpha,
                          ),
                  ),
                  child: _overflowMenuLeading(actionIndex),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: action.enabled
                          ? fgColor
                          : fgColor.withValues(
                              alpha: ButtonConstants.kDisabledForegroundAlpha,
                            ),
                    ),
                    child: _overflowMenuTitle(actionIndex),
                  ),
                ),
                if (selected)
                  dec.trailing ??
                      Icon(Icons.check_rounded, color: fgColor, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ////////////////////////////

  Future<int?> _showOverflowBottomSheet(
    BuildContext context,
    int firstHiddenIndex,
  ) async {
    final dec = widget.overflowBottomSheetDecoration;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final itemCount = widget.actions.length - firstHiddenIndex;

    return showModalBottomSheet<int>(
      context: context,
      showDragHandle: dec.showDragHandle,
      backgroundColor: dec.backgroundColor,
      elevation: dec.elevation,
      shape: dec.shape,
      builder: (sheetContext) {
        return _SpringMenuWrapper(
          motion: dec.motion,
          alignment: Alignment.bottomCenter,
          isBottomSheet: true,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dec.title != null)
                    Padding(
                      padding: dec.titlePadding,
                      child: DefaultTextStyle.merge(
                        style: Theme.of(sheetContext).textTheme.titleMedium,
                        child: dec.title!,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: dec.useCardList
                        ? _buildBottomSheetCardList(
                            sheetContext,
                            firstHiddenIndex,
                            itemCount,
                            dec,
                            cs,
                          )
                        : _buildBottomSheetStandardList(
                            sheetContext,
                            firstHiddenIndex,
                            itemCount,
                            dec,
                            cs,
                          ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetCardList(
    BuildContext sheetContext,
    int firstHiddenIndex,
    int itemCount,
    M3EOverflowBottomSheetDecoration dec,
    ColorScheme cs,
  ) {
    final outerR = dec.outerRadius;
    final innerR = dec.innerRadius;
    final selectedR = dec.selectedBorderRadius ?? outerR;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => SizedBox(height: dec.itemGap),
      itemBuilder: (context, listIndex) {
        final actionIndex = firstHiddenIndex + listIndex;
        return _buildBottomSheetCardListItem(
          context,
          actionIndex,
          listIndex,
          itemCount,
          dec,
          cs,
          outerR,
          innerR,
          selectedR,
        );
      },
    );
  }

  Widget _buildBottomSheetCardListItem(
    BuildContext context,
    int actionIndex,
    int listIndex,
    int total,
    M3EOverflowBottomSheetDecoration dec,
    ColorScheme cs,
    double outerR,
    double innerR,
    double selectedR,
  ) {
    final action = widget.actions[actionIndex];
    final selected = _isToggleActionSelected(actionIndex);

    final isFirst = listIndex == 0;
    final isLast = listIndex == total - 1;
    final isSingle = total == 1;

    BorderRadius borderRadius;
    if (selected) {
      borderRadius = BorderRadius.circular(selectedR);
    } else if (isSingle) {
      borderRadius = BorderRadius.circular(outerR);
    } else if (isFirst) {
      borderRadius = BorderRadius.vertical(
        top: Radius.circular(outerR),
        bottom: Radius.circular(innerR),
      );
    } else if (isLast) {
      borderRadius = BorderRadius.vertical(
        top: Radius.circular(innerR),
        bottom: Radius.circular(outerR),
      );
    } else {
      borderRadius = BorderRadius.circular(innerR);
    }

    final bgColor = selected
        ? (dec.selectedBackgroundColor ?? cs.secondaryContainer)
        : (dec.itemBackgroundColor ?? cs.surfaceContainerHigh);

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: action.enabled
            ? () => Navigator.of(context).pop(actionIndex)
            : null,
        borderRadius: borderRadius,
        child: Padding(
          padding: dec.itemPadding,
          child: Row(
            children: [
              IconTheme.merge(
                data: IconThemeData(
                  size: 18,
                  color: selected ? cs.onSecondaryContainer : cs.onSurface,
                ),
                child: _overflowMenuLeading(actionIndex),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DefaultTextStyle.merge(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: selected ? cs.onSecondaryContainer : cs.onSurface,
                  ),
                  child: _overflowMenuTitle(actionIndex),
                ),
              ),
              if (selected)
                dec.trailing ??
                    Icon(
                      Icons.check_rounded,
                      color: cs.onSecondaryContainer,
                      size: 20,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetStandardList(
    BuildContext sheetContext,
    int firstHiddenIndex,
    int itemCount,
    M3EOverflowBottomSheetDecoration dec,
    ColorScheme cs,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, listIndex) {
        final actionIndex = firstHiddenIndex + listIndex;
        return _buildBottomSheetStandardItem(context, actionIndex, dec, cs);
      },
    );
  }

  Widget _buildBottomSheetStandardItem(
    BuildContext context,
    int actionIndex,
    M3EOverflowBottomSheetDecoration dec,
    ColorScheme cs,
  ) {
    final action = widget.actions[actionIndex];
    final selected = _isToggleActionSelected(actionIndex);

    final itemRadius = dec.selectedBorderRadius ?? dec.outerRadius;

    final fgColor = selected
        ? (widget.decoration?.checkedForegroundColor ?? cs.onSecondaryContainer)
        : (widget.decoration?.foregroundColor ?? cs.onSurface);

    final bgColor = selected
        ? (dec.selectedBackgroundColor ?? cs.secondaryContainer)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: action.enabled ? bgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(itemRadius),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(itemRadius),
          onTap: action.enabled
              ? () => Navigator.of(context).pop(actionIndex)
              : null,
          child: Padding(
            padding: dec.itemPadding,
            child: Row(
              children: [
                IconTheme.merge(
                  data: IconThemeData(
                    size: 18,
                    color: action.enabled
                        ? fgColor
                        : fgColor.withValues(
                            alpha: ButtonConstants.kDisabledForegroundAlpha,
                          ),
                  ),
                  child: _overflowMenuLeading(actionIndex),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: action.enabled
                          ? fgColor
                          : fgColor.withValues(
                              alpha: ButtonConstants.kDisabledForegroundAlpha,
                            ),
                    ),
                    child: _overflowMenuTitle(actionIndex),
                  ),
                ),
                if (selected)
                  dec.trailing ??
                      Icon(Icons.check_rounded, color: fgColor, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _overflowMenuLeading(int index) {
    final action = widget.actions[index];
    final Widget? icon = _isToggleActionSelected(index)
        ? (action.checkedIcon ?? action.icon)
        : action.icon;
    return icon ?? const SizedBox.shrink();
  }

  Widget _overflowMenuTitle(int index) {
    final action = widget.actions[index];
    if (_isToggleActionSelected(index)) {
      return action.checkedLabel ?? action.label ?? Text('Option ${index + 1}');
    }
    return action.label ?? action.checkedLabel ?? Text('Option ${index + 1}');
  }

  void _handleOverflowActionSelection(int index) {
    final action = widget.actions[index];
    if (!action.enabled) return;

    final isCurrentlySelected = _isToggleActionSelected(index);

    // Multi-select mode
    if (widget.onSelectedIndicesChanged != null) {
      final current = widget.selectedIndices ?? <int>{};
      Set<int> next;
      if (isCurrentlySelected) {
        next = {...current};
        next.remove(index);
      } else {
        next = {...current, index};
      }
      _lastOverflowSelectionIndex = index;
      widget.onSelectedIndicesChanged!.call(next);
      return;
    }

    // Single-select mode
    final nextSelectedIndex = isCurrentlySelected ? null : index;
    final isNowSelected = nextSelectedIndex == index;

    _lastOverflowSelectionIndex = index;
    widget.onSelectedIndexChanged?.call(nextSelectedIndex);

    if (!isNowSelected) {
      _lastOverflowSelectionIndex = null;
    }
  }

  bool _isToggleActionSelected(int index) {
    // Multi-select mode: check if index is in the selected set
    if (widget.selectedIndices != null) {
      return widget.selectedIndices!.contains(index);
    }
    // Single-select mode: widget.selectedIndex takes precedence
    if (widget.onSelectedIndexChanged != null || widget.selectedIndex != null) {
      return widget.selectedIndex == index;
    }
    // Otherwise, fall back to the per-action state.
    return widget.actions[index].checked ?? false;
  }

  M3EToggleButtonGroupAction? _selectedToggleActionInRange(int start, int end) {
    if (start < 0 || end >= widget.actions.length || start > end) return null;
    for (int i = start; i <= end; i++) {
      if (_isToggleActionSelected(i)) return widget.actions[i];
    }
    final selectedIndex = _lastOverflowSelectionIndex;
    if (selectedIndex == null) return null;
    if (selectedIndex < start || selectedIndex > end) return null;
    return widget.actions[selectedIndex];
  }

  Widget _buildButton(
    BuildContext context,
    int index,
    bool isFirst,
    bool isLast,
  ) {
    final action = widget.actions[index];

    final bool checked = _isToggleActionSelected(index);

    // Use _isRtl cached once per build() — avoids N Directionality.of() calls.
    final isVisualFirst = _isRtl ? isLast : isFirst;
    final isVisualLast = _isRtl ? isFirst : isLast;

    Widget button = M3EToggleButton(
      icon: action.icon,
      checkedIcon: action.checkedIcon,
      label: action.label,
      checkedLabel: action.checkedLabel,
      checked: checked,
      enabled: action.enabled,
      style: widget.style,
      size: _mapSize(widget.size),
      isGroupConnected: widget._connected,
      isFirstInGroup: isVisualFirst,
      isLastInGroup: isVisualLast,
      decoration: _cachedDecorations[index],
      statesController: _controllers[index],
      focusNode: action.focusNode ?? _focusNodes[index],
      autofocus: action.autofocus,
      onFocusChange: (focused) {
        if (focused) _focusedIndex = index;
        action.onFocusChange?.call(focused);
      },
      semanticLabel: action.semanticLabel,
      onCheckedChange: (val) {
        // Multi-select mode
        if (widget.onSelectedIndicesChanged != null) {
          final current = widget.selectedIndices ?? <int>{};
          Set<int> next;
          if (val) {
            next = {...current, index};
          } else {
            next = {...current};
            next.remove(index);
          }
          widget.onSelectedIndicesChanged!.call(next);
          return;
        }
        // Single-select mode
        if (widget.onSelectedIndexChanged != null) {
          widget.onSelectedIndexChanged!.call(val ? index : null);
        }
      },
    );

    // Keys are on buttons in the Offstage measurer, not here.
    // Attaching them here would measure inside _AnimatedWidthToggle's SizedBox.
    return button;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  M3EButtonSize _mapSize(M3EButtonSize s) => switch (s.name) {
    'xs' => M3EButtonSize.xs,
    'sm' => M3EButtonSize.sm,
    'md' => M3EButtonSize.md,
    'lg' => M3EButtonSize.lg,
    'xl' => M3EButtonSize.xl,
    _ => M3EButtonSize.md,
  };
}

// ---------------------------------------------------------------------------
// _AnimatedWidthToggle
// ---------------------------------------------------------------------------
//
// Animates the width of a toggle button during press/neighbor-squish.
//
// For icon-only buttons: naturalSize == token height (always known).
// For labeled buttons:   naturalSize == measured width (from _naturalSizeForButton).
//
// The spring animates between three widths:
//   • pressed  → naturalSize + expandBy
//   • neighbor → naturalSize - expandBy / 2
//   • resting  → naturalSize

/// Animates the width of a toggle button during press/neighbor-squish.
///
/// Converted to [StatefulWidget] so that [SpringMotion] is resolved once and
/// cached in state — avoiding a new allocation on every animation frame
/// (which can fire at ~120 fps on ProMotion devices).
class _AnimatedWidthToggle extends StatefulWidget {
  const _AnimatedWidthToggle({
    super.key,
    required this.pressedIndexNotifier,
    required this.index,
    required this.expandBy,
    required this.naturalSize,
    required this.maxWidth,
    required this.motion,
    required this.onProgressUpdate,
    required this.child,
  });

  final ValueNotifier<int?> pressedIndexNotifier;
  final int index;
  final double expandBy;
  final double naturalSize;

  /// Hard ceiling on the animated width. Prevents spring overshoot from
  /// producing a width that exceeds the available space in the parent Row.
  /// Pass [double.infinity] when the parent is unconstrained.
  final double maxWidth;

  final M3EMotion motion;
  final ValueChanged<double> onProgressUpdate;
  final Widget child;

  @override
  State<_AnimatedWidthToggle> createState() => _AnimatedWidthToggleState();
}

class _AnimatedWidthToggleState extends State<_AnimatedWidthToggle> {
  late SpringMotion _springMotion;

  @override
  void initState() {
    super.initState();
    _springMotion = widget.motion.toMotion();
  }

  @override
  void didUpdateWidget(_AnimatedWidthToggle old) {
    super.didUpdateWidget(old);
    if (widget.motion != old.motion) {
      _springMotion = widget.motion.toMotion();
    }
  }

  double _computeTarget(int? pressedIndex) {
    final bool isPressed = pressedIndex == widget.index;
    final bool isNeighbor =
        pressedIndex != null &&
        widget.index != pressedIndex &&
        (widget.index == pressedIndex - 1 || widget.index == pressedIndex + 1);

    if (isPressed) return widget.naturalSize + widget.expandBy;
    if (isNeighbor) return widget.naturalSize - widget.expandBy / 2;
    return widget.naturalSize;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: widget.pressedIndexNotifier,
      builder: (context, pressedIndex, _) {
        final target = _computeTarget(pressedIndex);

        return SingleMotionBuilder(
          motion: _springMotion,
          value: target,
          builder: (_, animatedWidth, _) {
            final delta = target - widget.naturalSize;
            if (delta.abs() > ButtonConstants.kAnimationDeltaThreshold) {
              final progress =
                  ((animatedWidth - widget.naturalSize) / delta.abs()).clamp(
                    0.0,
                    1.0,
                  );
              widget.onProgressUpdate(progress);
            }

            // Clamp to [1, maxWidth]: lower bound prevents collapse, upper bound
            // prevents RenderFlex overflow from spring overshoot.
            final safeWidth =
                (animatedWidth.isFinite && animatedWidth > 0
                        ? animatedWidth
                        : widget.naturalSize)
                    .clamp(1.0, widget.maxWidth);

            return SizedBox(width: safeWidth, child: widget.child);
          },
        );
      },
    );
  }
}

class _SpringMenuWrapper extends StatefulWidget {
  final Widget child;
  final M3EMotion motion;
  final Alignment alignment;
  final bool isBottomSheet;

  const _SpringMenuWrapper({
    required this.child,
    required this.motion,
    required this.alignment,
    this.isBottomSheet = false,
  });

  @override
  State<_SpringMenuWrapper> createState() => _SpringMenuWrapperState();
}

class _SpringMenuWrapperState extends State<_SpringMenuWrapper>
    with SingleTickerProviderStateMixin {
  late SingleMotionController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = SingleMotionController(
      motion: widget.motion.toMotion(),
      vsync: this,
    );
    _ctrl.animateTo(1.0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final val = _ctrl.value;
        if (widget.isBottomSheet) {
          return Transform.translate(
            offset: Offset(0, 40 * (1.0 - val.clamp(0.0, 1.5))),
            child: child,
          );
        } else {
          return Opacity(
            opacity: val.clamp(0.0, 1.0),
            child: Transform.scale(
              scaleY: val.clamp(0.0, 1.2),
              alignment: widget.alignment,
              child: child,
            ),
          );
        }
      },
      child: widget.child,
    );
  }
}

class _MoveFocusAction extends Action<_MoveFocusIntent> {
  _MoveFocusAction(this._onMove);

  final void Function(int direction) _onMove;

  @override
  Object? invoke(_MoveFocusIntent intent) {
    _onMove(intent.direction);
    return null;
  }
}
