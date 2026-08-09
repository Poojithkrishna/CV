import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../domain/entities/account.dart';

/// A single account's summary tile: icon, name, type, masked account
/// number and current balance, painted in the account's chosen color
/// theme. Used in the accounts list and on the dashboard.
class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
  });

  final Account account;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // `account.iconCodePoint` has no picker UI setting it yet — every
    // account today falls back to its type's default icon. Flutter's
    // IconData now requires a compile-time-constant codePoint (for icon
    // tree-shaking), which a value loaded from the database can never
    // be, so a per-account custom icon isn't reconstructible this way
    // even once a picker exists — that'll need a fixed, curated set of
    // const IconData choices indexed by id instead.
    final IconData icon = account.type.defaultIcon;

    final Color baseColor = Color(account.colorValue);
    final bool isNegative = account.currentBalance < 0;

    return GradientCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [baseColor, Color.lerp(baseColor, Colors.black, 0.35)!],
      ),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(icon, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      account.bankName ?? account.type.label,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (account.type.isLiability)
                const Icon(Icons.trending_down_rounded, size: 18),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            AppFormatters.currency(account.currentBalance),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isNegative ? const Color(0xFFFFCDD2) : Colors.white,
            ),
          ),
          if (account.maskedAccountNumber.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              account.maskedAccountNumber,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
