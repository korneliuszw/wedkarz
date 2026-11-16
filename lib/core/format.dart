import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/core/context.dart';

String dayLabel(DateTime at) =>
    DateFormat('d MMMM yyyy', 'pl').format(at.toLocal());
String timeLabel(DateTime at) => DateFormat('HH:mm', 'pl').format(at.toLocal());
String cm(int? mm) =>
    mm == null ? '—' : '${NumberFormat('0.#', 'pl').format(mm / 10)} cm';
String kg(int? grams) => grams == null
    ? '—'
    : '${NumberFormat('0.00', 'pl').format(grams / 1000)} kg';
String fateLabel(BuildContext c, FishFate fate) =>
    fate == FishFate.released ? c.l.released : c.l.retained;
