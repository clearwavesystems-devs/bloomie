import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleState {
  final Locale locale;
  const LocaleState(this.locale);
}

class LocaleCubit extends Cubit<LocaleState> {
  static const _prefsKey = 'app_locale_code';
  static const supported = <Locale>[
    Locale('en'),
    Locale('bn'),
    // Add more locales here as needed
  ];

  LocaleCubit() : super(const LocaleState(Locale('en'))) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == null) return;

    final match = supported.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => const Locale('en'),
    );
    emit(LocaleState(match));
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == state.locale.languageCode) return;
    emit(LocaleState(locale));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}
