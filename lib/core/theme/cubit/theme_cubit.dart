import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState {
  final ThemeMode themeMode;
  const ThemeState(this.themeMode);
}

class ThemeCubit extends Cubit<ThemeState> {
  static const _prefsKey = 'theme_mode';

  ThemeCubit() : super(const ThemeState(ThemeMode.system)) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved == null) return;

    final mode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    emit(ThemeState(mode));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == state.themeMode) return;
    emit(ThemeState(mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }

  void toggle() {
    final current = state.themeMode;
    final isSystem = current == ThemeMode.system;
    final brightness = MediaQuery.platformBrightnessOf(
      // ignore: invalid_use_of_visible_for_testing_member
      MyAppGlobalKey().currentContext!,
    );

    if (isSystem) {
      setThemeMode(brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
    } else {
      setThemeMode(current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
    }
  }
}

// Helper for accessing brightness in toggle
class MyAppGlobalKey {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  BuildContext? get currentContext => key.currentContext;
}
