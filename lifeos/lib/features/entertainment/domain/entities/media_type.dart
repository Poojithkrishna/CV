import 'package:flutter/material.dart';

/// What kind of thing a [MediaItem] tracks.
enum MediaType {
  game('Game', Icons.sports_esports_outlined),
  movie('Movie', Icons.movie_outlined),
  series('Series', Icons.live_tv_outlined),
  anime('Anime', Icons.local_movies_outlined),
  book('Book', Icons.menu_book_outlined),
  manga('Manga', Icons.auto_stories_outlined),
  course('Course', Icons.school_outlined),
  other('Other', Icons.category_outlined);

  const MediaType(this.label, this.icon);

  final String label;
  final IconData icon;
}
