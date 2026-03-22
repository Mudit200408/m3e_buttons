import 'package:flutter/foundation.dart';
import 'package:motor/motor.dart';

@immutable
class M3EMotion {
  const M3EMotion._({
    required this.stiffness,
    required this.damping,
    this.snapToEnd = false,
  });

  static const M3EMotion standardSpatialFast = M3EMotion._(
    stiffness: 1400,
    damping: 0.9,
    snapToEnd: false,
  );

  static const M3EMotion standardSpatialDefault = M3EMotion._(
    stiffness: 700,
    damping: 0.9,
  );

  static const M3EMotion standardSpatialSlow = M3EMotion._(
    stiffness: 300,
    damping: 0.9,
  );

  static const M3EMotion expressiveSpatialFast = M3EMotion._(
    stiffness: 800,
    damping: 0.6,
  );

  static const M3EMotion expressiveSpatialDefault = M3EMotion._(
    stiffness: 380,
    damping: 0.8,
  );

  static const M3EMotion expressiveSpatialSlow = M3EMotion._(
    stiffness: 200,
    damping: 0.8,
  );

  static const M3EMotion standardEffectsFast = M3EMotion._(
    stiffness: 3800,
    damping: 1,
  );

  static const M3EMotion standardEffectsDefault = M3EMotion._(
    stiffness: 1600,
    damping: 1,
  );

  static const M3EMotion standardEffectsSlow = M3EMotion._(
    stiffness: 800,
    damping: 1,
  );

  static const M3EMotion expressiveEffectsFast = M3EMotion._(
    stiffness: 3800,
    damping: 1,
  );

  static const M3EMotion expressiveEffectsDefault = M3EMotion._(
    stiffness: 1600,
    damping: 1,
  );

  static const M3EMotion expressiveEffectsSlow = M3EMotion._(
    stiffness: 800,
    damping: 1,
  );

  static const M3EMotion standardOverflow = M3EMotion._(
    stiffness: 1600,
    damping: 0.85,
  );

  static const M3EMotion standardPopup = M3EMotion._(
    stiffness: 1000,
    damping: 0.6,
  );

  factory M3EMotion.custom(double stiffness, double damping) {
    return M3EMotion._(stiffness: stiffness, damping: damping);
  }

  final double stiffness;
  final double damping;
  final bool snapToEnd;

  SpringMotion toMotion() => MaterialSpringMotion.expressiveEffectsFast()
      .copyWith(stiffness: stiffness, damping: damping, snapToEnd: snapToEnd);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is M3EMotion &&
          stiffness == other.stiffness &&
          damping == other.damping &&
          snapToEnd == other.snapToEnd;

  @override
  int get hashCode => Object.hash(stiffness, damping, snapToEnd);
}
