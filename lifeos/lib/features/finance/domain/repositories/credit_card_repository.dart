import '../../../../core/utils/result.dart';
import '../entities/card_emi.dart';
import '../entities/credit_card.dart';

abstract interface class CreditCardRepository {
  Stream<List<CreditCard>> watchActiveCards();
  Stream<CreditCard?> watchCard(String id);

  Future<Result<CreditCard>> createCard(CreditCard card);
  Future<Result<CreditCard>> updateCard(CreditCard card);
  Future<Result<void>> deleteCard(String id);

  /// Positive [delta] records a charge, negative records a payment.
  Future<Result<void>> adjustUsage(String cardId, double delta);

  Stream<List<CardEmi>> watchEmisForCard(String cardId);
  Future<Result<CardEmi>> createEmi(CardEmi emi);
  Future<Result<void>> deleteEmi(String id);
  Future<Result<void>> markEmiInstallmentPaid(String id);
}
