import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/home_widget/home_widget_data.dart';
import 'package:lifeos/features/gamification/domain/entities/gamification_snapshot.dart';
import 'package:lifeos/features/gamification/domain/entities/rank.dart';

void main() {
  group('buildHomeWidgetData', () {
    test('maps every value through when the gamification snapshot has loaded', () {
      final snapshot = GamificationSnapshot(
        attributes: const {},
        xp: 1234,
        rank: Rank.coreFormation,
        progressToNextRank: 0.5,
        lifeScore: 42,
        satisfiedAchievementKeys: const {},
      );

      final data = buildHomeWidgetData(
        gamificationSnapshot: snapshot,
        netWorthValue: '₹1.2L',
        habitCompletionValue: '80%',
        scheduleSummary: '3 today',
      );

      expect(data['rank_label'], 'Core Formation');
      expect(data['xp_label'], '1234 XP');
      expect(data['net_worth'], '₹1.2L');
      expect(data['habit_completion'], '80%');
      expect(data['schedule_summary'], '3 today');
    });

    test('falls back to Mortal / 0 XP when the snapshot has not loaded yet', () {
      final data = buildHomeWidgetData(
        gamificationSnapshot: null,
        netWorthValue: '—',
        habitCompletionValue: '—',
        scheduleSummary: '—',
      );

      expect(data['rank_label'], 'Mortal');
      expect(data['xp_label'], '0 XP');
    });

    test('always produces exactly the five widget keys', () {
      final data = buildHomeWidgetData(
        gamificationSnapshot: null,
        netWorthValue: '—',
        habitCompletionValue: '—',
        scheduleSummary: '—',
      );

      expect(
        data.keys.toSet(),
        {'rank_label', 'xp_label', 'net_worth', 'habit_completion', 'schedule_summary'},
      );
    });
  });
}
