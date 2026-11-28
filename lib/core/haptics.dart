import 'package:flutter/services.dart';

/// Light vibration on answers, switchable in settings.
class Haptics {
  const Haptics._();

  // shortcut: global flag set by the settings notifier, move to a provider if more feedback kinds appear.
  static bool enabled = true;

  static void tap() {
    if (enabled) HapticFeedback.selectionClick();
  }

  static void success() {
    if (enabled) HapticFeedback.lightImpact();
  }

  static void error() {
    if (enabled) HapticFeedback.mediumImpact();
  }
}
