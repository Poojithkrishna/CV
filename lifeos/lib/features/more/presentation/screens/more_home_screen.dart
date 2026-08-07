import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';

/// Catch-all tab for modules that don't warrant their own slot in the
/// bottom navigation bar (Goals, Creator Studio, Entertainment, Journal,
/// Calendar, Gamification, Settings).
class MoreHomeScreen extends StatelessWidget {
  const MoreHomeScreen({super.key});

  static const List<_MoreEntry> _entries = [
    _MoreEntry('Goals', Icons.flag_rounded, AppColors.goals, '/goals'),
    _MoreEntry('Creator Studio', Icons.videocam_rounded, AppColors.creatorStudio,
        '/creator-studio'),
    _MoreEntry('Entertainment', Icons.movie_filter_rounded, AppColors.entertainment,
        '/entertainment'),
    _MoreEntry('Journal', Icons.menu_book_rounded, AppColors.journal, '/journal'),
    _MoreEntry(
        'Calendar & Tasks', Icons.calendar_month_rounded, AppColors.calendar, '/calendar'),
    _MoreEntry('Cultivation', Icons.local_fire_department_rounded,
        AppColors.gamification, '/gamification'),
    _MoreEntry('Settings', Icons.settings_rounded, Color(0xFF64748B), '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final _MoreEntry entry = _entries[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: entry.color.withOpacity(0.15),
                child: Icon(entry.icon, color: entry.color),
              ),
              title: Text(entry.label),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(entry.route),
            ),
          );
        },
      ),
    );
  }
}

class _MoreEntry {
  const _MoreEntry(this.label, this.icon, this.color, this.route);

  final String label;
  final IconData icon;
  final Color color;
  final String route;
}
