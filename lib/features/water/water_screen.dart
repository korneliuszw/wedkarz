import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/models.dart';

class WaterScreen extends ConsumerStatefulWidget {
  const WaterScreen({super.key});

  @override
  ConsumerState<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends ConsumerState<WaterScreen> {
  String? stationId;

  @override
  Widget build(BuildContext c) => AsyncBody(
    value: ref.watch(waterLevelsProvider),
    retry: () => ref.invalidate(waterLevelsProvider),
    data: (feed) {
      final stations = readList(feed, 'stations', (station) => station);
      if (stations.isEmpty) return PageBody(child: Text(c.l.noReading));
      final station =
          stations.where((station) => station['id'] == stationId).firstOrNull ??
          stations.first;
      final readings = readList(
        station,
        'readings',
        (row) => WaterReading(
          measuredAt: DateTime.parse(row['measuredAt'] as String),
          levelCm: row['levelCm'] as int,
        ),
      );
      if (readings.isEmpty) return PageBody(child: Text(c.l.noReading));
      return _readings(
        c,
        readings,
        selector: DropdownButtonFormField<String>(
          value: station['id'] as String,
          isExpanded: true,
          items: stations
              .map(
                (row) => DropdownMenuItem<String>(
                  value: row['id'] as String,
                  child: Text(row['name'] as String),
                ),
              )
              .toList(),
          onChanged: (id) => setState(() => stationId = id),
        ),
        stale: feed['stale'] == true || station['stale'] == true,
      );
    },
  );

  Widget _readings(
    BuildContext c,
    List<WaterReading> readings, {
    Widget? selector,
    bool stale = false,
  }) {
    final latest = readings.last;
    final delta = latest.levelCm! - readings.first.levelCm!;
    return SingleChildScrollView(
      child: PageBody(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selector != null) ...[selector, const SizedBox(height: 12)],
            if (stale) ...[Text(c.l.staleWater), const SizedBox(height: 12)],
            SurfacePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${latest.levelCm} cm',
                        style: c.text.headlineLarge?.copyWith(fontSize: 60),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${c.l.measuredAt} · ${dayLabel(latest.measuredAt)} · ${timeLabel(latest.measuredAt)}',
                          ),
                          if (readings.length > 1)
                            Text(
                              '${delta >= 0 ? '+' : ''}$delta cm · ${timeLabel(readings.first.measuredAt)}',
                              style: c.text.bodySmall?.copyWith(
                                color: AppColors.water,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ExcludeSemantics(
                    child: SizedBox(
                      height: 158,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _WaterChart(
                          readings,
                          AnglerAssets.fontOf(c, 'SofiaSans'),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timeLabel(readings.first.measuredAt),
                        style: c.text.bodySmall,
                      ),
                      Text(
                        timeLabel(latest.measuredAt),
                        style: c.text.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(c.l.measurements),
            const SizedBox(height: 8),
            for (final reading in readings.reversed) ...[
              SurfacePanel(
                child: Row(
                  children: [
                    Expanded(child: Text(timeLabel(reading.measuredAt))),
                    Text('${reading.levelCm} cm'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(c.l.imgwWaterSource, style: c.text.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _WaterChart extends CustomPainter {
  _WaterChart(this.readings, this.fontFamily);
  final List<WaterReading> readings;
  final String fontFamily;
  @override
  void paint(Canvas canvas, Size size) {
    const left = 46.0;
    final width = max(1.0, size.width - left - 9);
    final height = size.height - 28;
    final values = readings.map((reading) => reading.levelCm!).toList();
    final low = values.reduce(min) - 2;
    final high = values.reduce(max) + 2;
    final first = readings.first.measuredAt;
    final duration = max(
      1,
      readings.last.measuredAt.difference(first).inSeconds,
    );
    for (final value in [low, (low + high) ~/ 2, high]) {
      final y = (high - value) / (high - low) * height + 8;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width, y),
        Paint()..color = AppColors.line,
      );
      final label = TextPainter(
        text: TextSpan(
          text: '$value',
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            color: AppColors.muted,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(0, y - 10));
    }
    final path = Path();
    for (var i = 0; i < readings.length; i++) {
      final level = readings[i].levelCm;
      if (level == null) continue;
      final x =
          left +
          readings[i].measuredAt.difference(first).inSeconds / duration * width;
      final y = (high - level) / (high - low) * height + 8;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.water
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke,
    );
    final point = Offset(
      left +
          readings.last.measuredAt.difference(first).inSeconds /
              duration *
              width,
      (high - readings.last.levelCm!) / (high - low) * height + 8,
    );
    canvas.drawCircle(point, 8, Paint()..color = AppColors.ink);
    canvas.drawCircle(point, 5.5, Paint()..color = AppColors.water);
  }

  @override
  bool shouldRepaint(covariant _WaterChart oldDelegate) =>
      oldDelegate.readings != readings || oldDelegate.fontFamily != fontFamily;
}
