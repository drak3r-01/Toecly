import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mode de thème choisi (système par défaut), mémorisé entre deux lancements.
class ThemeModeController extends ChangeNotifier {
  ThemeModeController(this._prefs)
      : _themeMode = ThemeMode.values.asNameMap()[_prefs.getString(_key)] ?? ThemeMode.system;

  static const _key = 'theme_mode';

  final SharedPreferences _prefs;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _prefs.setString(_key, mode.name);
  }
}
