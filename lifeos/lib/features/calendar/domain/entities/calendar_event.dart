import 'package:flutter/foundation.dart';

/// A scheduled event — a meeting, appointment or block of time with a
/// start and, usually, an end.
@immutable
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.location,
    this.endTime,
    this.isAllDay = false,
    this.reminderEnabled = false,
  });

  final String id;
  final String title;
  final String? notes;
  final String? location;
  final DateTime startTime;

  /// Null means a point-in-time event with no known duration.
  final DateTime? endTime;

  final bool isAllDay;
  final bool reminderEnabled;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  CalendarEvent copyWith({
    String? title,
    String? notes,
    bool clearNotes = false,
    String? location,
    bool clearLocation = false,
    DateTime? startTime,
    DateTime? endTime,
    bool clearEndTime = false,
    bool? isAllDay,
    bool? reminderEnabled,
    int? colorValue,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id,
      title: title ?? this.title,
      notes: clearNotes ? null : (notes ?? this.notes),
      location: clearLocation ? null : (location ?? this.location),
      startTime: startTime ?? this.startTime,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      isAllDay: isAllDay ?? this.isAllDay,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is CalendarEvent && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
