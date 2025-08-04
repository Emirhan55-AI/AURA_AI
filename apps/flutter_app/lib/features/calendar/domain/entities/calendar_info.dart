import 'package:flutter/material.dart';

/// Represents calendar information from device calendars
class CalendarInfo {
  final String? id;
  final String? name;
  final String? accountName;
  final Color? color;
  final bool? isReadOnly;
  final bool? isDefault;

  const CalendarInfo({
    this.id,
    this.name,
    this.accountName,
    this.color,
    this.isReadOnly,
    this.isDefault,
  });

  factory CalendarInfo.fromDeviceCalendar(dynamic deviceCalendar) {
    return CalendarInfo(
      id: deviceCalendar.id?.toString(),
      name: deviceCalendar.name?.toString(),
      accountName: deviceCalendar.accountName?.toString(),
      color: deviceCalendar.color != null 
          ? Color(deviceCalendar.color as int)
          : Colors.blue,
      isReadOnly: deviceCalendar.isReadOnly as bool?,
      isDefault: deviceCalendar.isDefault as bool?,
    );
  }
}
