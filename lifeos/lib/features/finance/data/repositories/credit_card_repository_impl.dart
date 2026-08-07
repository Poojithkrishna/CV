import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/card_emi.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/repositories/credit_card_repository.dart';
import '../daos/card_emis_dao.dart';
import '../daos/credit_cards_dao.dart';
import 'card_emi_mapper.dart';
import 'credit_card_mapper.dart';

class CreditCardRepositoryImpl implements CreditCardRepository {
  CreditCardRepositoryImpl(this._cardsDao, this._emisDao);

  final CreditCardsDao _cardsDao;
  final CardEmisDao _emisDao;

  @override
  Stream<List<CreditCard>> watchActiveCards() {
    return _cardsDao
        .watchActiveCards()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<CreditCard?> watchCard(String id) {
    return _cardsDao.watchCard(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<CreditCard>> createCard(CreditCard card) async {
    try {
      await _cardsDao.insertCard(card.toCompanion());
      return Result.ok(card);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save credit card: $e'));
    }
  }

  @override
  Future<Result<CreditCard>> updateCard(CreditCard card) async {
    try {
      final bool updated = await _cardsDao.updateCard(card.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Credit card no longer exists.'));
      }
      return Result.ok(card);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update credit card: $e'));
    }
  }

  @override
  Future<Result<void>> deleteCard(String id) async {
    try {
      await _cardsDao.deleteCard(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete credit card: $e'));
    }
  }

  @override
  Future<Result<void>> adjustUsage(String cardId, double delta) async {
    try {
      await _cardsDao.adjustUsage(cardId, delta);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update usage: $e'));
    }
  }

  @override
  Stream<List<CardEmi>> watchEmisForCard(String cardId) {
    return _emisDao
        .watchEmisForCard(cardId)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<CardEmi>> createEmi(CardEmi emi) async {
    try {
      await _emisDao.insertEmi(emi.toCompanion());
      return Result.ok(emi);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save EMI: $e'));
    }
  }

  @override
  Future<Result<void>> deleteEmi(String id) async {
    try {
      await _emisDao.deleteEmi(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete EMI: $e'));
    }
  }

  @override
  Future<Result<void>> markEmiInstallmentPaid(String id) async {
    try {
      await _emisDao.markInstallmentPaid(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update EMI: $e'));
    }
  }
}
