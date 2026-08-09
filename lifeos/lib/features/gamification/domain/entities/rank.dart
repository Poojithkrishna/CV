import 'package:flutter/material.dart';

/// The cultivation ladder, Mortal to Demon God. Each rank's [minXp] is
/// the total XP required to reach it — see `GamificationStats.rankForXp`.
/// [flavorTitle] is the honorific shown alongside the rank name, so
/// there's no need for a separate user-selectable "titles" feature.
enum Rank {
  mortal(
    'Mortal',
    'Ordinary Cultivator',
    0,
    Icons.person_outline_rounded,
  ),
  qiRefining(
    'Qi Refining',
    'Breath Seeker',
    400,
    Icons.air_rounded,
  ),
  foundationEstablishment(
    'Foundation Establishment',
    'Rooted One',
    1000,
    Icons.foundation_rounded,
  ),
  coreFormation(
    'Core Formation',
    'Golden Core Bearer',
    1800,
    Icons.blur_circular_rounded,
  ),
  nascentSoul(
    'Nascent Soul',
    'Soul-Forged Adept',
    2800,
    Icons.auto_awesome_rounded,
  ),
  soulTransformation(
    'Soul Transformation',
    'Transcendent Spirit',
    4000,
    Icons.brightness_7_rounded,
  ),
  voidTribulation(
    'Void Tribulation',
    'Heaven-Defier',
    5400,
    Icons.thunderstorm_rounded,
  ),
  immortalAscension(
    'Immortal Ascension',
    'Ascended Immortal',
    6800,
    Icons.self_improvement_rounded,
  ),
  demonGod(
    'Demon God',
    'Undisputed Sovereign',
    8000,
    Icons.local_fire_department_rounded,
  );

  const Rank(this.label, this.flavorTitle, this.minXp, this.icon);

  final String label;
  final String flavorTitle;
  final int minXp;
  final IconData icon;

  Rank? get next {
    final int index = Rank.values.indexOf(this);
    if (index >= Rank.values.length - 1) return null;
    return Rank.values[index + 1];
  }
}
