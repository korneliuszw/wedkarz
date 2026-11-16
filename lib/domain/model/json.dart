typedef Clock = DateTime Function();
typedef Json = Map<String, dynamic>;

DateTime? optionalDate(Object? value) =>
    value == null ? null : DateTime.parse(value as String);
List<T> readList<T>(Json json, String key, T Function(Json) parse) =>
    ((json[key] as List?) ?? [])
        .map((value) => parse(Map<String, dynamic>.from(value as Map)))
        .toList();
