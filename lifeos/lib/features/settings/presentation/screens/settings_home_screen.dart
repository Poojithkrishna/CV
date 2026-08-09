import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/app_lock_provider.dart';
import '../../../../core/providers/theme_mode_provider.dart';
import '../../../../core/widgets/app_icon_mark.dart';
import '../../../../core/widgets/brand_wordmark.dart';

class SettingsHomeScreen extends ConsumerWidget {
  const SettingsHomeScreen({super.key});

  Future<void> _setAppLockEnabled(BuildContext context, WidgetRef ref, bool value) async {
    final bool supported = await ref.read(appLockServiceProvider).isSupported();
    if (!context.mounted) return;
    if (!supported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No biometrics or device lock is set up on this device.'),
        ),
      );
      return;
    }

    // Re-authentication is required in both directions: to enable, so
    // no one can turn it on and lock the actual owner out, and to
    // disable, so grabbing an already-unlocked phone isn't enough to
    // permanently switch the lock off.
    final bool authenticated = await ref.read(appLockServiceProvider).authenticate(
          reason: value ? 'Verify it\'s you to enable App Lock' : 'Verify it\'s you to disable App Lock',
        );
    if (!authenticated) return;

    await ref.read(appLockEnabledProvider.notifier).setEnabled(value);
    if (value) {
      // Already proven who they are just now — don't immediately
      // re-lock the screen they're looking at.
      ref.read(appLockSessionProvider.notifier).unlock();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final bool appLockEnabled = ref.watch(appLockEnabledProvider) ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Text('Appearance', style: Theme.of(context).textTheme.labelLarge),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('System default'),
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    onChanged: (mode) =>
                        ref.read(themeModeProvider.notifier).setThemeMode(mode!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Light'),
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (mode) =>
                        ref.read(themeModeProvider.notifier).setThemeMode(mode!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark'),
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (mode) =>
                        ref.read(themeModeProvider.notifier).setThemeMode(mode!),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Text('Security', style: Theme.of(context).textTheme.labelLarge),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint_rounded),
                    title: const Text('App Lock'),
                    subtitle: const Text('Require biometrics or device unlock to open Demon Origin'),
                    value: appLockEnabled,
                    onChanged: (value) => _setAppLockEnabled(context, ref, value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Text('Data', style: Theme.of(context).textTheme.labelLarge),
                  ),
                  ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: const Text('Backup & Restore'),
                    subtitle: const Text('Export everything, or restore from a backup file'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/settings/backup'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const AppIconMark(size: 28),
              title: const BrandWordmark(fontSize: 16),
              subtitle: const Text('v0.1.0 — personal build'),
            ),
          ),
        ],
      ),
    );
  }
}
