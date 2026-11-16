import '../domain/models.dart';

// Labels for place IDs stored by earlier API builds.
const legacyPlaces = [
  FishingPlace(id: 'parseta-a', waterName: 'Parsęta', sectionName: 'odcinek A'),
  FishingPlace(id: 'parseta-b', waterName: 'Parsęta', sectionName: 'odcinek B'),
  FishingPlace(id: 'parseta-c', waterName: 'Parsęta', sectionName: 'odcinek C'),
  FishingPlace(
    id: 'lake-a',
    waterName: 'Jezioro A',
    sectionName: 'stanowisko 1',
  ),
];

const speciesIllustrations = [
  FishSpecies(id: 'perch', name: 'Okoń', asset: 'assets/fish/perch.jpg'),
  FishSpecies(id: 'pike', name: 'Szczupak', asset: 'assets/fish/pike.jpg'),
  FishSpecies(id: 'bream', name: 'Leszcz', asset: 'assets/fish/bream.jpg'),
];
FishingPlace placeById(String id, [Iterable<FishingPlace> saved = const []]) =>
    saved.where((place) => place.id == id).firstOrNull ??
    legacyPlaces.where((place) => place.id == id).firstOrNull ??
    FishingPlace(
      id: id,
      waterName: id.replaceFirst('legacy-place:', ''),
      sectionName: '',
    );
FishSpecies speciesById(String id, List<FishSpecies> species) =>
    species.firstWhere(
      (e) => e.id == id,
      orElse: () => FishSpecies(id: id, name: '#$id', asset: ''),
    );
