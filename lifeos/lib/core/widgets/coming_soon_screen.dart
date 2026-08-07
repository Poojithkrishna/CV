import 'package:flutter/material.dart';

import 'gradient_card.dart';

/// Placeholder screen for a module that hasn't been built out yet. Every
/// module is reachable from day one (so navigation and the dashboard are
/// fully wired), but only Finance → Accounts has real functionality so
/// far — the rest arrive as their own feature-by-feature passes.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.gradient,
    required this.description,
  });

  final String title;
  final IconData icon;
  final Gradient gradient;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GradientCard(
          gradient: gradient,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 44),
              const SizedBox(height: 20),
              Text(
                '$title is on the roadmap',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
