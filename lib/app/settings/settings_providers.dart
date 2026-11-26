import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;

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
