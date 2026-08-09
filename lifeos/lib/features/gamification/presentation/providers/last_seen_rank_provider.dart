import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefsKey = 'lifeos.last_seen_rank_index';

/// Persists the [Rank.index] the cultivator has already seen a
/// celebration dialog for, so the rank-up dialog fires exactly once per
/// rank reached rather than on every rebuild. `null` until loaded from
/// disk — mirrors `ThemeModeController`'s pattern, since a wrong value
/// for one frame here is cosmetic, not security-critical.
class LastSeenRankController extends Notifier<int?> {
  @override
  int? build() {
    unawaited(_load());
    return null;
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_prefsKey) ?? 0;
  }

  Future<void> markSeen(int rankIndex) async {
    state = rankIndex;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, rankIndex);
  }
}

final NotifierProvider<LastSeenRankController, int?> lastSeenRankProvider =
    NotifierProvider<LastSeenRankController, int?>(LastSeenRankController.new);
