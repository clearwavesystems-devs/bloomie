import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloomie/core/theme/cubit/theme_cubit.dart';
import 'package:bloomie/core/locale/cubit/locale_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/sync/sync_queue_service.dart';
import '../../../../core/sync/data_sync_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.baloo2(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        children: [
          _Section(
            title: 'Appearance',
            children: [_ThemeTile(), _LanguageTile()],
          ),
          _Section(title: 'Cloud Sync', children: [const _SyncSettingsCard()]),
          _Section(
            title: 'About',
            children: [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
                leading: const Icon(SolarIconsOutline.infoCircle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SyncSettingsCard extends StatefulWidget {
  const _SyncSettingsCard();

  @override
  State<_SyncSettingsCard> createState() => _SyncSettingsCardState();
}

class _SyncSettingsCardState extends State<_SyncSettingsCard> {
  bool _isManualSyncing = false;

  @override
  Widget build(BuildContext context) {
    final syncQueue = context.read<SyncQueueService>();
    final dataSync = context.read<DataSyncService>();

    return ListenableBuilder(
      listenable: syncQueue,
      builder: (context, child) {
        final isOffline = syncQueue.isOffline;
        final pendingCount = syncQueue.pendingCount;
        final isProcessing = syncQueue.isProcessing || _isManualSyncing;
        final lastSync = syncQueue.lastSyncTime;

        String lastSyncText = 'Never synced';
        if (lastSync != null) {
          lastSyncText = DateFormat('jm').format(lastSync); // e.g. 4:30 PM
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE896B0).withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFE896B0).withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isOffline
                            ? const Color(0xFFFFE8D6)
                            : const Color(0xFFE8F8F0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isOffline
                            ? SolarIconsOutline.cloud
                            : SolarIconsOutline.cloudCheck,
                        color: isOffline
                            ? const Color(0xFFE87E50)
                            : const Color(0xFF4CAF50),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOffline ? 'Offline Mode' : 'Cloud Sync Active',
                            style: GoogleFonts.baloo2(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C2C2C),
                            ),
                          ),
                          Text(
                            isOffline
                                ? 'Changes will sync when online'
                                : 'All data matches remote servers',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: const Color(0xFF7C7C7C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pending Queue',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF9E9E9E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$pendingCount operations',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Last Saved',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF9E9E9E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lastSyncText,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE896B0),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xFFE896B0,
                      ).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isProcessing
                        ? null
                        : () async {
                            setState(() {
                              _isManualSyncing = true;
                            });
                            try {
                              await syncQueue.forceSync();
                              await dataSync.syncFromSupabase();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '✅ Data synchronized successfully!',
                                      style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFE896B0),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '❌ Sync failed: Check your connection.',
                                      style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isManualSyncing = false;
                                });
                              }
                            }
                          },
                    child: isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(SolarIconsOutline.refresh, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Sync Now',
                                style: GoogleFonts.baloo2(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
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
          leading: const Icon(SolarIconsOutline.palette),
          trailing: const Icon(SolarIconsOutline.altArrowRight),
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
                _ThemeOption(ThemeMode.light, SolarIconsOutline.sun),
                _ThemeOption(ThemeMode.dark, SolarIconsOutline.moon),
                _ThemeOption(ThemeMode.system, SolarIconsOutline.settings),
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
          trailing: isSelected
              ? Icon(
                  SolarIconsOutline.checkSquare,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
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
          leading: const Icon(SolarIconsOutline.global),
          trailing: const Icon(SolarIconsOutline.altArrowRight),
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
              children: [
                _LanguageOption(const Locale('en'), 'English'),
                _LanguageOption(const Locale('bn'), 'বাংলা'),
              ],
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
          trailing: isSelected
              ? Icon(
                  SolarIconsOutline.checkSquare,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
          onTap: () {
            context.read<LocaleCubit>().setLocale(locale);
            context.pop();
          },
        );
      },
    );
  }
}
