import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/formatters.dart';
import 'package:lifeos/features/finance/domain/entities/account.dart';
import 'package:lifeos/features/finance/domain/entities/account_type.dart';
import 'package:lifeos/features/finance/presentation/widgets/account_card.dart';

void main() {
  testWidgets('AccountCard shows the account name and formatted balance',
      (WidgetTester tester) async {
    final DateTime now = DateTime(2026, 1, 1);
    final Account account = Account(
      id: 'a1',
      name: 'HDFC Savings',
      type: AccountType.bank,
      currentBalance: 12500,
      openingBalance: 10000,
      colorValue: 0xFF22C55E,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AccountCard(account: account)),
      ),
    );

    expect(find.text('HDFC Savings'), findsOneWidget);
    expect(find.text(AppFormatters.currency(12500)), findsOneWidget);
  });

  testWidgets('tapping the card invokes onTap', (WidgetTester tester) async {
    final DateTime now = DateTime(2026, 1, 1);
    final Account account = Account(
      id: 'a1',
      name: 'Cash Wallet',
      type: AccountType.cash,
      currentBalance: 500,
      openingBalance: 500,
      colorValue: 0xFF22C55E,
      createdAt: now,
      updatedAt: now,
    );

    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountCard(account: account, onTap: () => tapped = true),
        ),
      ),
    );

    await tester.tap(find.byType(AccountCard));
    expect(tapped, isTrue);
  });
}
