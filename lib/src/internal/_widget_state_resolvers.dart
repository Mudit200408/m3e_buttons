// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'button_constants.dart';

abstract class WidgetStateResolver<T> {
  WidgetStateProperty<T> resolve(Set<WidgetState> states);
}

class ColorResolver extends WidgetStateResolver<Color?> {
  final Color _color;
  final bool _applyDisabledAlpha;

  ColorResolver({required Color color, bool applyDisabledAlpha = true})
    : _color = color,
      _applyDisabledAlpha = applyDisabledAlpha;

  WidgetStateProperty<Color?>? _cached;

  @override
  WidgetStateProperty<Color?> resolve(Set<WidgetState> states) {
    _cached ??= WidgetStateProperty.resolveWith((resolvedStates) {
      final disabled = resolvedStates.contains(WidgetState.disabled);
      if (disabled && _applyDisabledAlpha) {
        return _color.withValues(
          alpha: ButtonConstants.kDisabledForegroundAlpha,
        );
      }
      return _color;
    });
    return _cached!;
  }
}

class BackgroundColorResolver extends WidgetStateResolver<Color?> {
  final Color? _decorationColor;
  final Color _fallbackColor;
  final bool _transparentForOutlined;
  final bool _applyDisabledAlpha;

  BackgroundColorResolver({
    Color? decorationColor,
    required Color fallbackColor,
    bool transparentForOutlined = false,
    bool applyDisabledAlpha = true,
  }) : _decorationColor = decorationColor,
       _fallbackColor = fallbackColor,
       _transparentForOutlined = transparentForOutlined,
       _applyDisabledAlpha = applyDisabledAlpha;

  WidgetStateProperty<Color?>? _cached;

  @override
  WidgetStateProperty<Color?> resolve(Set<WidgetState> states) {
    _cached ??= WidgetStateProperty.resolveWith((resolvedStates) {
      final disabled = resolvedStates.contains(WidgetState.disabled);
      final Color color;

      if (_decorationColor != null) {
        color = _decorationColor;
      } else if (_transparentForOutlined) {
        color = Colors.transparent;
      } else {
        color = _fallbackColor;
      }

      if (disabled && _applyDisabledAlpha) {
        return color.withValues(
          alpha: ButtonConstants.kDisabledBackgroundAlpha,
        );
      }
      return color;
    });
    return _cached!;
  }
}

class StaticColorResolver extends WidgetStateResolver<Color?> {
  final Color _color;

  StaticColorResolver(this._color);

  WidgetStateProperty<Color?>? _cached;

  @override
  WidgetStateProperty<Color?> resolve(Set<WidgetState> states) {
    _cached ??= WidgetStateProperty.all(_color);
    return _cached!;
  }
}

class DecorationColorResolver extends WidgetStateResolver<Color?> {
  final Color? _decorationColor;
  final Color Function(Set<WidgetState> states) _fallbackResolver;
  final bool _transparentForOutlined;
  final bool _applyDisabledAlpha;

  DecorationColorResolver({
    Color? decorationColor,
    required Color Function(Set<WidgetState> states) fallbackResolver,
    bool transparentForOutlined = false,
    bool applyDisabledAlpha = true,
  }) : _decorationColor = decorationColor,
       _fallbackResolver = fallbackResolver,
       _transparentForOutlined = transparentForOutlined,
       _applyDisabledAlpha = applyDisabledAlpha;

  WidgetStateProperty<Color?>? _cached;

  @override
  WidgetStateProperty<Color?> resolve(Set<WidgetState> states) {
    _cached ??= WidgetStateProperty.resolveWith((resolvedStates) {
      final disabled = resolvedStates.contains(WidgetState.disabled);
      final Color color;

      if (_decorationColor != null) {
        color = _decorationColor;
      } else if (_transparentForOutlined) {
        if (disabled && _applyDisabledAlpha) {
          return Colors.transparent.withValues(
            alpha: ButtonConstants.kDisabledBackgroundAlpha,
          );
        }
        return Colors.transparent;
      } else {
        color = _fallbackResolver(resolvedStates);
      }

      if (disabled && _applyDisabledAlpha) {
        return color.withValues(
          alpha: ButtonConstants.kDisabledBackgroundAlpha,
        );
      }
      return color;
    });
    return _cached!;
  }
}

class DoubleResolver extends WidgetStateResolver<double> {
  final double Function(Set<WidgetState> states) _resolver;

  DoubleResolver(this._resolver);

  WidgetStateProperty<double>? _cached;

  @override
  WidgetStateProperty<double> resolve(Set<WidgetState> states) {
    _cached ??= WidgetStateProperty.resolveWith(_resolver);
    return _cached!;
  }
}

class BorderSideResolver extends WidgetStateResolver<BorderSide> {
  final BorderSide? _decorationBorderSide;
  final BorderSide Function(Set<WidgetState> states) _fallbackResolver;

  BorderSideResolver({
    BorderSide? decorationBorderSide,
    required BorderSide Function(Set<WidgetState> states) fallbackResolver,
  }) : _decorationBorderSide = decorationBorderSide,
       _fallbackResolver = fallbackResolver;

  WidgetStateProperty<BorderSide>? _cached;

  @override
  WidgetStateProperty<BorderSide> resolve(Set<WidgetState> states) {
    _cached ??= _decorationBorderSide != null
        ? WidgetStateProperty.all(_decorationBorderSide)
        : WidgetStateProperty.resolveWith(_fallbackResolver);
    return _cached!;
  }
}

class OutlineBorderSideResolver extends WidgetStateResolver<BorderSide> {
  final Color? _decorationForegroundColor;
  final Color _fallbackColor;
  final bool _applyDisabledAlpha;

  OutlineBorderSideResolver({
    Color? decorationForegroundColor,
    required Color fallbackColor,
    bool applyDisabledAlpha = true,
  }) : _decorationForegroundColor = decorationForegroundColor,
       _fallbackColor = fallbackColor,
       _applyDisabledAlpha = applyDisabledAlpha;

  WidgetStateProperty<BorderSide>? _cached;

  @override
  WidgetStateProperty<BorderSide> resolve(Set<WidgetState> states) {
    _cached ??= WidgetStateProperty.resolveWith((resolvedStates) {
      final disabled = resolvedStates.contains(WidgetState.disabled);
      final color = _decorationForegroundColor ?? _fallbackColor;
      return BorderSide(
        color: color.withValues(
          alpha: disabled && _applyDisabledAlpha
              ? ButtonConstants.kDisabledOutlineAlpha
              : 1,
        ),
        width: 1,
      );
    });
    return _cached!;
  }
}

class NoneBorderSideResolver extends WidgetStateResolver<BorderSide> {
  static final WidgetStateProperty<BorderSide> _cached =
      WidgetStateProperty.all(BorderSide.none);

  @override
  WidgetStateProperty<BorderSide> resolve(Set<WidgetState> states) {
    return _cached;
  }
}
