import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/domain/models.dart';

final currentFishingPositionProvider = Provider<Future<Position> Function()>(
  (ref) => () async {
    if (!kIsWeb) {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw const DomainFailure(FailureCode.invalidMeasurement);
      }
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  },
);

class NewFishingPlaceScreen extends ConsumerStatefulWidget {
  const NewFishingPlaceScreen({
    super.key,
    required this.ownerId,
    required this.start,
  });

  final String ownerId;
  final bool start;

  @override
  ConsumerState<NewFishingPlaceScreen> createState() =>
      _NewFishingPlaceScreenState();
}

class _NewFishingPlaceScreenState extends ConsumerState<NewFishingPlaceScreen> {
  final _name = TextEditingController();
  ({int id, String name})? _area;
  String? _coordinates;
  bool _locating = false;
  bool _locationFailed = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _locationFailed = false;
      _coordinates = null;
    });
    try {
      final position = await ref.read(currentFishingPositionProvider)();
      if (!mounted) return;
      setState(
        () => _coordinates =
            '${position.latitude.toStringAsFixed(6)},${position.longitude.toStringAsFixed(6)}',
      );
    } catch (_) {
      if (mounted) setState(() => _locationFailed = true);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _save(FishingPlace place) async {
    if (_saving) return;
    setState(() => _saving = true);
    final controller = ref.read(fishingProvider(widget.ownerId).notifier);
    final saved = await runAction(
      context,
      () => widget.start
          ? controller.start(place.id, newPlace: place)
          : controller.selectPlace(place.id, newPlace: place),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (saved) Navigator.pop(context, true);
  }

  void _saveNew() {
    final name = _name.text.trim();
    _save(
      FishingPlace(
        id: const Uuid().v4(),
        areaId: _area!.id,
        waterName: _area!.name,
        sectionName: '',
        coordinates: _coordinates,
        customName: name.isEmpty ? null : name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context;
    final snapshot = ref.watch(fishingProvider(widget.ownerId)).valueOrNull;
    final savedPlaces =
        snapshot?.places.where(
          (place) =>
              !(snapshot.activeSession?.placeIds.contains(place.id) ?? false),
        ) ??
        const <FishingPlace>[];
    final busy = _locating || _saving;
    return FishingScreenBody(
      title: widget.start ? c.l.startFishing : c.l.newPlaceTitle,
      footer: FilledButton(
        onPressed: busy || _area == null || _coordinates == null
            ? null
            : _saveNew,
        child: Text(c.l.fishHere),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (savedPlaces.isNotEmpty) ...[
            Text(c.l.savedFishingPlaces),
            for (final place in savedPlaces)
              MenuPanel(
                title: place.label,
                onTap: () {
                  if (!busy) _save(place);
                },
              ),
            const SizedBox(height: 20),
          ],
          AsyncBody(
            value: ref.watch(fishingAreasProvider),
            retry: () => ref.invalidate(fishingAreasProvider),
            data: (areas) => areas.isEmpty
                ? Text(c.l.noFishingAreas)
                : DropdownButtonFormField<int>(
                    value: areas.any((area) => area.id == _area?.id)
                        ? _area?.id
                        : null,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: c.l.chooseFishingArea,
                    ),
                    items: [
                      for (final area in areas)
                        DropdownMenuItem(
                          value: area.id,
                          child: Text(
                            area.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: busy
                        ? null
                        : (id) {
                            setState(() {
                              _area = areas.firstWhere((area) => area.id == id);
                              _coordinates = null;
                              _locationFailed = false;
                            });
                          },
                  ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _area == null || busy ? null : _locate,
            icon: const Icon(Icons.my_location),
            label: Text(
              _locating ? c.l.locatingFishingPlace : c.l.getFishingCoordinates,
            ),
          ),
          if (_coordinates case final coordinates?) Text(coordinates),
          if (_locationFailed)
            Semantics(
              liveRegion: true,
              child: Text(c.l.fishingLocationUnavailable),
            ),
          if (_coordinates != null) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              enabled: !busy,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: c.l.optionalFishingPlaceName,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
