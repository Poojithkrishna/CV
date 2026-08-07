import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction_entry.dart';
import '../../domain/entities/transaction_type.dart';
import '../providers/category_providers.dart';
import '../providers/finance_providers.dart';
import 'category_icons.dart';

/// A single row in any transaction list: category/type icon, note or
/// category name, account (and destination, for transfers), date and a
/// signed, color-coded amount.
class TransactionTile extends ConsumerWidget {
  const TransactionTile({super.key, required this.entry, this.onTap});

  final TransactionEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Account?> accountAsync = ref.watch(accountByIdProvider(entry.accountId));
    final AsyncValue<Category?> categoryAsync = entry.categoryId != null
        ? ref.watch(categoryByIdProvider(entry.categoryId!))
        : const AsyncValue.data(null);
    final AsyncValue<Account?> transferAccountAsync = entry.transferAccountId != null
        ? ref.watch(accountByIdProvider(entry.transferAccountId!))
        : const AsyncValue.data(null);

    final Category? category = categoryAsync.valueOrNull;
    final Account? account = accountAsync.valueOrNull;
    final Account? transferAccount = transferAccountAsync.valueOrNull;

    final IconData icon =
        category != null ? CategoryIcons.resolve(category.iconKey) : entry.type.icon;
    final Color color = category != null ? Color(category.colorValue) : entry.type.color;

    final String title = entry.isTransfer
        ? '${account?.name ?? '…'} → ${transferAccount?.name ?? '…'}'
        : (category?.name ?? entry.type.label);

    final String subtitle = entry.note?.isNotEmpty == true
        ? entry.note!
        : (entry.isTransfer ? 'Transfer' : (account?.name ?? ''));

    final String sign = switch (entry.type) {
      TransactionType.income => '+',
      TransactionType.expense => '−',
      TransactionType.transfer => '',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.18),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$sign${AppFormatters.currency(entry.amount)}',
              style: TextStyle(fontWeight: FontWeight.w700, color: color),
            ),
            Text(
              AppFormatters.relativeDay(entry.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
