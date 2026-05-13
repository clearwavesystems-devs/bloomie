import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloomie/core/theme/cubit/theme_cubit.dart';
import 'package:bloomie/core/locale/cubit/locale_cubit.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("settings")),
      body: ListView(
        children: [
          _Section(title: 'Appearance', children: [_ThemeTile(), _LanguageTile()]),
          _Section(
            title: 'About',
            children: [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
                leading: const Icon(Icons.info_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        ...children,
        const Divider(height: 32),
      ],
    );
  }
}

class _ThemeTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return ListTile(
          title: const Text('Theme'),
          subtitle: Text(_getThemeLabel(state.themeMode)),
          leading: const Icon(Icons.palette_outlined),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showThemeDialog(context),
        );
      },
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: context.read<ThemeCubit>(),
          child: AlertDialog(
            title: const Text('Select Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ThemeOption(ThemeMode.light, Icons.light_mode),
                _ThemeOption(ThemeMode.dark, Icons.dark_mode),
                _ThemeOption(ThemeMode.system, Icons.brightness_auto),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final ThemeMode mode;
  final IconData icon;

  const _ThemeOption(this.mode, this.icon);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isSelected = state.themeMode == mode;
        return ListTile(
          title: Text(_getThemeLabel(mode)),
          leading: Icon(icon),
          trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
          onTap: () {
            context.read<ThemeCubit>().setThemeMode(mode);
            context.pop();
          },
        );
      },
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}

class _LanguageTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        return ListTile(
          title: const Text('Language'),
          subtitle: Text(_getLanguageLabel(state.locale.languageCode)),
          leading: const Icon(Icons.language),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguageDialog(context),
        );
      },
    );
  }

  String _getLanguageLabel(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'bn':
        return 'বাংলা';
      default:
        return code;
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: context.read<LocaleCubit>(),
          child: AlertDialog(
            title: const Text('Select Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_LanguageOption(const Locale('en'), 'English'), _LanguageOption(const Locale('bn'), 'বাংলা')],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final Locale locale;
  final String label;

  const _LanguageOption(this.locale, this.label);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final isSelected = state.locale.languageCode == locale.languageCode;
        return ListTile(
          title: Text(label),
          trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
          onTap: () {
            context.read<LocaleCubit>().setLocale(locale);
            context.pop();
          },
        );
      },
    );
  }
}
