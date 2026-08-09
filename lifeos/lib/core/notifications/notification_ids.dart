/// Deterministic, stable notification ids for `flutter_local_notifications`
/// (which requires a 32-bit int). Every entity uses a String UUID, so
/// each id is `Object.hash(entityId, moduleSalt)` masked into the
/// positive int32 range — the per-module salt keeps a loan and a
/// calendar task that happen to share a hash collision from ever
/// canceling each other's reminder.
int _stableId(String entityId, int moduleSalt) {
  return Object.hash(entityId, moduleSalt) & 0x7FFFFFFF;
}

int loanReminderId(String loanId) => _stableId(loanId, 1);

int recurringPaymentReminderId(String paymentId) => _stableId(paymentId, 2);

int calendarTaskReminderId(String taskId) => _stableId(taskId, 3);

int calendarEventReminderId(String eventId) => _stableId(eventId, 4);
