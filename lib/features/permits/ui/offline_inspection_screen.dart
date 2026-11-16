import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/domain/models.dart';

class OfflineInspectionScreen extends ConsumerStatefulWidget {
  const OfflineInspectionScreen({super.key, required this.ownerId});
  final String ownerId;

  @override
  ConsumerState<OfflineInspectionScreen> createState() =>
      _OfflineInspectionScreenState();
}

class _OfflineInspectionScreenState
    extends ConsumerState<OfflineInspectionScreen> {
  List<String> _frames = const [];
  Timer? _timer;
  DateTime? _expires;
  int _frame = 0;
  bool _busy = false;
  Object? _error;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_generate());
    });
  }

  Future<void> _generate({bool provision = false}) async {
    final generation = ++_generation;
    _timer?.cancel();
    setState(() {
      _busy = true;
      _error = null;
      _frames = const [];
      _frame = 0;
    });
    try {
      final inspection = ref.read(offlineInspectionProvider);
      if (provision) {
        await ref.read(authProvider.notifier).apiRequest((session) {
          if (session.user.id != widget.ownerId) {
            throw const AuthorizationFailure();
          }
          return inspection.provision(session);
        });
        if (!mounted || generation != _generation) return;
      }
      final snapshot = ref.read(fishingProvider(widget.ownerId)).requireValue;
      final expires = DateTime.now().add(const Duration(seconds: 120));
      final frames = await inspection.present(
        widget.ownerId,
        snapshot,
        ref.read(speciesProvider),
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _frames = frames;
        _expires = expires;
      });
      _timer = Timer.periodic(const Duration(milliseconds: 600), (_) {
        if (!mounted) return;
        setState(() {
          if (DateTime.now().isBefore(expires)) {
            _frame = (_frame + 1) % frames.length;
          } else {
            _frames = const [];
            _timer?.cancel();
          }
        });
      });
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() => _error = error);
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final online = ref.watch(networkProvider).online;
    ref.listen(
      fishingProvider(
        widget.ownerId,
      ).select((state) => state.valueOrNull?.activeSession?.id),
      (_, __) => unawaited(_generate()),
    );
    final visible = _frames.isNotEmpty && DateTime.now().isBefore(_expires!);
    return FishingScreenBody(
      title: context.l.controlCode,
      child: Column(
        children: [
          if (_busy) const CircularProgressIndicator(),
          if (_error != null) Text(context.l.inspectionOfflineHint),
          if (visible) ...[
            Text(context.l.showToRanger, style: context.text.titleLarge),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (c, constraints) => Semantics(
                image: true,
                label: c.l.showToRanger,
                child: QrImageView(
                  data: _frames[_frame],
                  size: min(420, constraints.maxWidth),
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
              ),
            ),
            if (_frames.length > 1)
              Text(context.l.inspectionPage(_frame + 1, _frames.length)),
            Text('${max(0, _expires!.difference(DateTime.now()).inSeconds)} s'),
          ],
          if (!_busy && !visible && _error == null)
            FilledButton(
              onPressed: _generate,
              child: Text(context.l.regenerateCode),
            ),
          if (!_busy && online)
            TextButton(
              onPressed: () => _generate(provision: true),
              child: Text(context.l.refreshInspection),
            ),
        ],
      ),
    );
  }
}
