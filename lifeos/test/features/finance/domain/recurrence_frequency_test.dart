import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/finance/domain/entities/recurrence_frequency.dart';

void main() {
  group('RecurrenceFrequency.next', () {
    test('weekly adds exactly 7 days', () {
      final DateTime result = RecurrenceFrequency.weekly.next(DateTime(2026, 3, 10));
      expect(result, DateTime(2026, 3, 17));
    });

    test('monthly rolls over to the next year in December', () {
      final DateTime result = RecurrenceFrequency.monthly.next(DateTime(2026, 12, 15));
      expect(result, DateTime(2027, 1, 15));
    });

    test('monthly clamps 31 Jan to the last day of February (non-leap year)', () {
      final DateTime result = RecurrenceFrequency.monthly.next(DateTime(2027, 1, 31));
      expect(result, DateTime(2027, 2, 28));
    });

    test('monthly clamps 31 Jan to 29 Feb in a leap year', () {
      final DateTime result = RecurrenceFrequency.monthly.next(DateTime(2028, 1, 31));
      expect(result, DateTime(2028, 2, 29));
    });

    test('quarterly adds three months', () {
      final DateTime result = RecurrenceFrequency.quarterly.next(DateTime(2026, 11, 30));
      expect(result, DateTime(2027, 2, 28));
    });

    test('yearly clamps 29 Feb to 28 Feb in a non-leap year', () {
      final DateTime result = RecurrenceFrequency.yearly.next(DateTime(2028, 2, 29));
      expect(result, DateTime(2029, 2, 28));
    });

    test('yearly keeps the same month and day in a normal case', () {
      final DateTime result = RecurrenceFrequency.yearly.next(DateTime(2026, 6, 15));
      expect(result, DateTime(2027, 6, 15));
    });
  });
}
