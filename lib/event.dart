import 'package:flutter/material.dart';

class Event {
  final String title;
  final String description;
  final List<String> details;
  final DateTime startDate;
  final DateTime endDate;

  Event({
    required this.title,
    required this.description,
    required this.details,
    required this.startDate,
    required this.endDate,
  });
}
