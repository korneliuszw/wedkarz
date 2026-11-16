import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/domain/rules.dart';

String fishingDate(DateTime date) {
  final label = DateFormat('EEEE, d MMMM', 'pl').format(date.toLocal());
  return label[0].toUpperCase() + label.substring(1);
}

String dayBalance(BuildContext c, List<CatchEntry> entries) {
  final totals = CatchAccounting.fromEntries(entries);
  final mass = totals.hasUnknownRetainedWeight
      ? totals.retainedWeightGrams == 0
            ? '— kg'
            : '${kg(totals.retainedWeightGrams)} + ?'
      : kg(totals.retainedWeightGrams);
  return c.l.dayBalance(totals.releasedCount, totals.retainedCount, mass);
}

int fishCount(Iterable<CatchEntry> entries) =>
    entries.fold(0, (total, entry) => total + entry.quantity);
