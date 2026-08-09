import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/providers/backup_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/widgets/confirm_dialog.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _exporting = false;
  bool _restoring = false;

  Future<void> _exportBackup() async {
    setState(() => _exporting = true);
    try {
      final backupService = ref.read(backupServiceProvider);
      final String exportPath = await backupService.resolveDefaultExportPath();
      await backupService.exportTo(ref.read(appDatabaseProvider), exportPath);
      await Share.shareXFiles([XFile(exportPath)], subject: 'Demon Origin backup');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _restoreBackup() async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Restore from backup?',
      message: 'This replaces everything currently in Demon Origin with the contents of the '
          'backup file. This cannot be undone. Demon Origin will close afterward — reopen it '
          'to see the restored data.',
      confirmLabel: 'Choose backup file',
      isDestructive: true,
    );
    if (!confirmed) return;

    final FilePickerResult? picked = await FilePicker.platform.pickFiles();
    if (picked == null || picked.files.single.path == null) return;
    final File pickedFile = File(picked.files.single.path!);

    setState(() => _restoring = true);
    final backupService = ref.read(backupServiceProvider);

    final bool isValid = await backupService.isValidSqliteFile(pickedFile);
    if (!isValid) {
      if (mounted) {
        setState(() => _restoring = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('That doesn\'t look like a valid Demon Origin backup file.')),
        );
      }
      return;
    }

    // Close the live connection before touching its file — restoring
    // hot-swaps nothing; Demon Origin closes afterward and the next launch
    // opens the restored file fresh, the same way any launch does.
    await ref.read(appDatabaseProvider).close();
    final String databaseFilePath = await backupService.resolveDatabaseFilePath();
    await backupService.installBackupFile(pickedFile, databaseFilePath);

    if (!mounted) return;
    setState(() => _restoring = false);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Restore complete'),
        content: const Text('Demon Origin will now close. Reopen it to see your restored data.'),
        actions: [
          FilledButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Close Demon Origin'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.upload_outlined),
              title: const Text('Export backup'),
              subtitle: const Text(
                'Save everything in Demon Origin to a file you can share or store elsewhere.',
              ),
              trailing: _exporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right_rounded),
              onTap: _exporting ? null : _exportBackup,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Restore from backup'),
              subtitle: const Text(
                'Replace everything in Demon Origin with a previously exported backup file.',
              ),
              trailing: _restoring
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right_rounded),
              onTap: _restoring ? null : _restoreBackup,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Backups are plain database files with no separate encryption of their '
              'own — share them the same way you\'d share anything else sensitive.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
