import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/card_emis_dao.dart';
import '../../data/daos/credit_cards_dao.dart';
import '../../data/repositories/credit_card_repository_impl.dart';
import '../../domain/entities/card_emi.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/repositories/credit_card_repository.dart';
import '../../domain/usecases/create_card_emi.dart';
import '../../domain/usecases/create_credit_card.dart';
import '../../domain/usecases/delete_card_emi.dart';
import '../../domain/usecases/delete_credit_card.dart';
import '../../domain/usecases/mark_emi_installment_paid.dart';
import '../../domain/usecases/record_card_charge.dart';
import '../../domain/usecases/record_card_payment.dart';
import '../../domain/usecases/update_credit_card.dart';

final Provider<CreditCardsDao> creditCardsDaoProvider = Provider<CreditCardsDao>((ref) {
  return CreditCardsDao(ref.watch(appDatabaseProvider));
});

final Provider<CardEmisDao> cardEmisDaoProvider = Provider<CardEmisDao>((ref) {
  return CardEmisDao(ref.watch(appDatabaseProvider));
});

final Provider<CreditCardRepository> creditCardRepositoryProvider =
    Provider<CreditCardRepository>((ref) {
  return CreditCardRepositoryImpl(
    ref.watch(creditCardsDaoProvider),
    ref.watch(cardEmisDaoProvider),
  );
});

final Provider<CreateCreditCard> createCreditCardUseCaseProvider = Provider(
  (ref) => CreateCreditCard(ref.watch(creditCardRepositoryProvider)),
);

final Provider<UpdateCreditCard> updateCreditCardUseCaseProvider = Provider(
  (ref) => UpdateCreditCard(ref.watch(creditCardRepositoryProvider)),
);

final Provider<DeleteCreditCard> deleteCreditCardUseCaseProvider = Provider(
  (ref) => DeleteCreditCard(ref.watch(creditCardRepositoryProvider)),
);

final Provider<RecordCardCharge> recordCardChargeUseCaseProvider = Provider(
  (ref) => RecordCardCharge(ref.watch(creditCardRepositoryProvider)),
);

final Provider<RecordCardPayment> recordCardPaymentUseCaseProvider = Provider(
  (ref) => RecordCardPayment(ref.watch(creditCardRepositoryProvider)),
);

final Provider<CreateCardEmi> createCardEmiUseCaseProvider = Provider(
  (ref) => CreateCardEmi(ref.watch(creditCardRepositoryProvider)),
);

final Provider<DeleteCardEmi> deleteCardEmiUseCaseProvider = Provider(
  (ref) => DeleteCardEmi(ref.watch(creditCardRepositoryProvider)),
);

final Provider<MarkEmiInstallmentPaid> markEmiInstallmentPaidUseCaseProvider = Provider(
  (ref) => MarkEmiInstallmentPaid(ref.watch(creditCardRepositoryProvider)),
);

final StreamProvider<List<CreditCard>> activeCreditCardsProvider =
    StreamProvider<List<CreditCard>>((ref) {
  return ref.watch(creditCardRepositoryProvider).watchActiveCards();
});

final StreamProviderFamily<CreditCard?, String> creditCardByIdProvider =
    StreamProvider.family<CreditCard?, String>((ref, id) {
  return ref.watch(creditCardRepositoryProvider).watchCard(id);
});

final StreamProviderFamily<List<CardEmi>, String> emisForCardProvider =
    StreamProvider.family<List<CardEmi>, String>((ref, cardId) {
  return ref.watch(creditCardRepositoryProvider).watchEmisForCard(cardId);
});
