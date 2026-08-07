/// Primary muscle group an exercise targets. Used to filter the exercise
/// library and to group progress by body area later.
enum MuscleGroup {
  chest('Chest'),
  back('Back'),
  shoulders('Shoulders'),
  biceps('Biceps'),
  triceps('Triceps'),
  legs('Legs'),
  glutes('Glutes'),
  core('Core'),
  cardio('Cardio'),
  fullBody('Full Body'),
  other('Other');

  const MuscleGroup(this.label);

  final String label;
}
