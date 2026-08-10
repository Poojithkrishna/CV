import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/origin/origin_colors.dart';
import '../../../../app/origin/origin_motion.dart';
import '../../../../app/origin/origin_typography.dart';
import '../../../calendar/presentation/screens/calendar_home_screen.dart';
import '../../../entertainment/presentation/screens/entertainment_home_screen.dart';
import '../../../journal/presentation/screens/journal_home_screen.dart';

enum _ChronicleSection { journal, calendar, media }

/// Chronicle (spec §15) — the dark archival library that gathers Journal,
/// Calendar and Media tracking as sections of one destination instead of
/// three separate bottom-nav-adjacent modules. Each section reuses its
/// existing screen's content wholesale (JournalHomeBody, CalendarHomeBody,
/// EntertainmentHomeBody) — the data layer and every sub-route (entry
/// forms, task/event forms, item forms) are unchanged; this is a new front
/// door onto them, not a rewrite.
class ChronicleHomeScreen extends StatefulWidget {
  const ChronicleHomeScreen({super.key});

  @override
  State<ChronicleHomeScreen> createState() => _ChronicleHomeScreenState();
}

class _ChronicleHomeScreenState extends State<ChronicleHomeScreen> {
  _ChronicleSection _section = _ChronicleSection.journal;

  Future<void> _onAddPressed() async {
    switch (_section) {
      case _ChronicleSection.journal:
        context.push('/journal/entries/new');
        break;
      case _ChronicleSection.calendar:
        await showAddCalendarItemMenu(context);
        break;
      case _ChronicleSection.media:
        context.push('/entertainment/items/new');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chronicle',
          style: OriginTypography.heading(size: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddPressed,
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                _SectionTab(
                  label: 'Journal',
                  selected: _section == _ChronicleSection.journal,
                  onTap: () => setState(() => _section = _ChronicleSection.journal),
                ),
                const SizedBox(width: 8),
                _SectionTab(
                  label: 'Calendar',
                  selected: _section == _ChronicleSection.calendar,
                  onTap: () => setState(() => _section = _ChronicleSection.calendar),
                ),
                const SizedBox(width: 8),
                _SectionTab(
                  label: 'Media',
                  selected: _section == _ChronicleSection.media,
                  onTap: () => setState(() => _section = _ChronicleSection.media),
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _ChronicleSection.values.indexOf(_section),
              children: const [
                JournalHomeBody(),
                CalendarHomeBody(),
                EntertainmentHomeBody(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTab extends StatelessWidget {
  const _SectionTab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: OriginMotion.pressResponse,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? OriginColors.surfaceSecondary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? OriginColors.hairlineStrong : OriginColors.hairline,
            ),
          ),
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: OriginTypography.eyebrow(
              size: 12,
              color: selected ? OriginColors.textPrimary : OriginColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
