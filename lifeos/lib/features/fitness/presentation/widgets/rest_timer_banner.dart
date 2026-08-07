import 'dart:async';

import 'package:flutter/material.dart';

/// A countdown banner shown after logging a working set, so the app can
/// time rest between sets without a separate stopwatch. Purely ephemeral
/// UI state — nothing here is persisted.
class RestTimerBanner extends StatefulWidget {
  const RestTimerBanner({super.key, required this.seconds, required this.onDismiss});

  final int seconds;
  final VoidCallback onDismiss;

  @override
  State<RestTimerBanner> createState() => _RestTimerBannerState();
}

class _RestTimerBannerState extends State<RestTimerBanner> {
  late int _remaining = widget.seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        widget.onDismiss();
        return;
      }
      setState(() => _remaining -= 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double progress = _remaining / widget.seconds;

    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                value: progress.clamp(0, 1).toDouble(),
                strokeWidth: 3,
                backgroundColor: colorScheme.onPrimaryContainer.withOpacity(0.2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Resting — ${_remaining}s',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _timer?.cancel();
                widget.onDismiss();
              },
              child: const Text('Skip'),
            ),
          ],
        ),
      ),
    );
  }
}
