import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;

import '../../core/haptics.dart';
import '../providers.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() =>
      ThemeMode.values.asNameMap()[ref.read(localStoreProvider).read(_key)] ?? ThemeMode.system;

  Future<void> set(ThemeMode mode) {
    state = mode;
    return ref.read(localStoreProvider).write(_key, mode.name);
  }
}

/// `null` means "follow the system language".
class LocaleNotifier extends Notifier<Locale?> {
  static const _key = 'language';
  static const supportedLanguageCodes = ['en', 'fr'];

  @override
  Locale? build() {
    final code = ref.read(localStoreProvider).read(_key);
    return supportedLanguageCodes.contains(code) ? Locale(code!) : null;
  }

  Future<void> set(Locale? locale) {
    state = locale;
    return ref.read(localStoreProvider).write(_key, locale?.languageCode ?? 'system');
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

class HapticsNotifier extends Notifier<bool> {
  static const _key = 'haptics';

  @override
  bool build() => Haptics.enabled = ref.read(localStoreProvider).read(_key) != 'off';

  Future<void> set(bool enabled) {
    state = Haptics.enabled = enabled;
    return ref.read(localStoreProvider).write(_key, enabled ? 'on' : 'off');
  }
}

final hapticsProvider = NotifierProvider<HapticsNotifier, bool>(HapticsNotifier.new);

/// Reading text size, applied on top of the system font scale.
enum TextSize {
  small(0.9),
  normal(1),
  large(1.15),
  huge(1.3);

  const TextSize(this.factor);

  final double factor;
}

class TextSizeNotifier extends Notifier<TextSize> {
  static const _key = 'text_size';

  @override
  TextSize build() =>
      TextSize.values.asNameMap()[ref.read(localStoreProvider).read(_key)] ?? TextSize.normal;

  Future<void> set(TextSize size) {
    state = size;
    return ref.read(localStoreProvider).write(_key, size.name);
  }
}

final textSizeProvider = NotifierProvider<TextSizeNotifier, TextSize>(TextSizeNotifier.new);
