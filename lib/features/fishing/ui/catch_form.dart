import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/theme.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/data/catalog.dart';
import 'package:nad_parseta/domain/models.dart';

import '../service/catch_camera.dart';
import 'catch_fate_picker.dart';
import 'catch_measurements.dart';
import 'catch_tile.dart';
import 'delete_catch_screen.dart';
import 'species_picker_screen.dart';

class CatchForm extends ConsumerStatefulWidget {
  const CatchForm({
    super.key,
    required this.ownerId,
    required this.session,
    this.entry,
  });
  final String ownerId;
  final FishingSession session;
  final CatchEntry? entry;
  @override
  ConsumerState<CatchForm> createState() => _CatchFormState();
}

class _CatchFormState extends ConsumerState<CatchForm> {
  final _form = GlobalKey<FormState>();
  final _length = TextEditingController();
  final _weight = TextEditingController();
  String? _species;
  FishFate? _fate;
  bool _busy = false;
  bool _takingPhoto = false;
  ({String? base64})? _photoChange;
  String? _formError;
  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    if (entry == null) return;
    _species = entry.speciesId;
    _fate = entry.fate;
    _length.text = entry.lengthMm == null
        ? ''
        : (entry.lengthMm! / 10).toString().replaceAll('.', ',');
    _weight.text = entry.weightGrams == null
        ? ''
        : (entry.weightGrams! / 1000).toString().replaceAll('.', ',');
  }

  @override
  void dispose() {
    _length.dispose();
    _weight.dispose();
    super.dispose();
  }

  double? _number(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));
  String? _validate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = _number(value);
    return parsed == null || !parsed.isFinite || parsed <= 0
        ? context.l.invalidNumber
        : null;
  }

  Future<void> _save() async {
    if (_busy ||
        _takingPhoto ||
        _species == null ||
        !_form.currentState!.validate()) {
      return;
    }
    if (_fate == null) {
      setState(() => _formError = context.l.requiredFate);
      return;
    }
    if (_length.text.trim().isEmpty && _weight.text.trim().isEmpty) {
      setState(() => _formError = context.l.measurementHelp);
      return;
    }
    setState(() {
      _busy = true;
      _formError = null;
    });
    final entry = CatchEntry(
      id: widget.entry?.id ?? const Uuid().v4(),
      sessionId: widget.session.id,
      placeId: widget.entry?.placeId ?? widget.session.currentPlaceId,
      speciesId: _species!,
      caughtAt: widget.entry?.caughtAt ?? DateTime.now(),
      lengthMm: _number(_length.text) == null
          ? null
          : (_number(_length.text)! * 10).round(),
      weightGrams: _number(_weight.text) == null
          ? null
          : (_number(_weight.text)! * 1000).round(),
      fate: _fate!,
      revision: (widget.entry?.revision ?? 0) + 1,
    );
    final saved = await runAction(
      context,
      () => ref
          .read(fishingProvider(widget.ownerId).notifier)
          .saveCatch(entry, photoChange: _photoChange),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (saved) Navigator.pop(context);
  }

  Future<void> _takePhoto(Future<String?> Function() camera) async {
    setState(() => _takingPhoto = true);
    try {
      final photo = await camera();
      if (mounted && photo != null) {
        setState(() => _photoChange = (base64: photo));
      }
    } on FormatException {
      if (mounted) _showPhotoMessage(context.l.catchPhotoTooLarge);
    } catch (_) {
      if (mounted) _showPhotoMessage(context.l.catchCameraUnavailable);
    } finally {
      if (mounted) setState(() => _takingPhoto = false);
    }
  }

  void _showPhotoMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _selectSpecies(BuildContext c) async {
    final id = await Navigator.push<String>(
      c,
      MaterialPageRoute(builder: (c) => const SpeciesPickerScreen()),
    );
    if (id != null && mounted) setState(() => _species = id);
  }

  Future<void> _delete(BuildContext c) async {
    final entry = widget.entry!;
    final confirm = await Navigator.push<bool>(
      c,
      MaterialPageRoute(builder: (c) => DeleteCatchScreen(entry: entry)),
    );
    if (confirm != true || !c.mounted) return;
    setState(() => _busy = true);
    final removed = await runAction(
      c,
      () =>
          ref.read(fishingProvider(widget.ownerId).notifier).deleteCatch(entry),
    );
    if (!c.mounted) return;
    setState(() => _busy = false);
    if (removed) {
      final navigator = Navigator.of(c);
      navigator.pop();
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext c) {
    final editing = widget.entry != null;
    final online = ref.watch(networkProvider).online;
    final snapshot = ref.watch(fishingProvider(widget.ownerId)).valueOrNull;
    final camera = ref.watch(catchCameraProvider);
    final photo = _photoChange == null
        ? snapshot?.attachments
              .where((item) => item.catchId == widget.entry?.id)
              .lastOrNull
              ?.base64Bytes
        : _photoChange!.base64;
    return PopScope(
      canPop: !_busy && !_takingPhoto,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FishingHeader(
                      back: true,
                      title: editing ? c.l.editFish : c.l.addFish,
                      subtitle: placeById(
                        widget.entry?.placeId ?? widget.session.currentPlaceId,
                        ref
                                .watch(fishingProvider(widget.ownerId))
                                .valueOrNull
                                ?.places ??
                            const [],
                      ).label,
                    ),
                    PageBody(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SurfacePanel(
                              onTap: _busy ? null : () => _selectSpecies(c),
                              child: Row(
                                children: [
                                  if (_species == null)
                                    Container(
                                      width: 74,
                                      height: 62,
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    )
                                  else
                                    FishPicture(
                                      speciesId: _species!,
                                      width: 74,
                                      height: 62,
                                    ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      _species == null
                                          ? c.l.chooseSpecies
                                          : speciesById(
                                              _species!,
                                              ref.watch(speciesProvider),
                                            ).name,
                                      style: c.text.titleMedium,
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            CatchMeasurements(
                              lengthController: _length,
                              weightController: _weight,
                              validator: _validate,
                            ),
                            const SizedBox(height: 8),
                            Text(c.l.measurementHelp, style: c.text.bodySmall),
                            const SizedBox(height: 18),
                            Text(c.l.fatePrompt),
                            const SizedBox(height: 8),
                            CatchFatePicker(
                              selected: _fate,
                              onSelected: _busy
                                  ? null
                                  : (fate) => setState(() => _fate = fate),
                            ),
                            const SizedBox(height: 20),
                            if (photo != null) ...[
                              Image.memory(
                                base64Decode(photo),
                                height: 130,
                                fit: BoxFit.contain,
                                semanticLabel: c.l.yourPhoto,
                              ),
                              TextButton(
                                onPressed: _busy || _takingPhoto
                                    ? null
                                    : () => setState(
                                        () => _photoChange = (base64: null),
                                      ),
                                child: Text(c.l.removeCatchPhoto),
                              ),
                            ],
                            if (camera != null)
                              OutlinedButton.icon(
                                onPressed: _busy || _takingPhoto
                                    ? null
                                    : () => _takePhoto(camera),
                                icon: const Icon(Icons.camera_alt_outlined),
                                label: Text(
                                  photo == null
                                      ? c.l.takeCatchPhoto
                                      : c.l.retakeCatchPhoto,
                                ),
                              ),
                            if (editing) ...[
                              const SizedBox(height: 18),
                              Text(c.l.correctionHint, style: c.text.bodySmall),
                              TextButton(
                                onPressed: _busy ? null : () => _delete(c),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                ),
                                child: Text(c.l.deleteFish),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: PageBody(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  children: [
                    if (_formError != null || !online || _species == null) ...[
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _formError ??
                              (!online
                                  ? c.l.offlineCatch
                                  : c.l.chooseSpeciesFirst),
                          textAlign: TextAlign.center,
                          style: c.text.bodySmall?.copyWith(
                            color: _formError == null
                                ? AppColors.muted
                                : AppColors.error,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    FilledButton(
                      key: const Key('save-catch'),
                      onPressed: _busy || _takingPhoto || _species == null
                          ? null
                          : _save,
                      child: Text(
                        _busy
                            ? c.l.loading
                            : editing
                            ? c.l.saveCorrection
                            : c.l.saveFish,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
