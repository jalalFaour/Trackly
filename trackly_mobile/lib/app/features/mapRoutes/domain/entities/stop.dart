class Stop {
  final String name;
  final int order;
  final Point location;

  Stop({
    required this.name,
    required this.order,
    required this.location,
  });

  factory Stop.defaultObj() => Stop(
    name: '',
    order: 0,
    location: const Point(coordinates: [0, 0]),
  );

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      name: (json['name'] ?? '').toString(),
      order: (json['order'] ?? 0) as int,
      location: Point.fromJson(json['location'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'order': order,
      'location': location.toJson(),
    };
  }
}

/// GeoJSON Point entity
class Point {
  final String type;
  final List<double> coordinates;

  const Point({
    this.type = 'Point',
    required this.coordinates,
  });

  const Point.empty() : type = 'Point', coordinates = const [0, 0];

  factory Point.fromJson(Map<String, dynamic> json) {
    final coords = (json['coordinates'] as List? ?? const []);
    final parsedCoords = coords
        .map((e) => (e as num).toDouble())
        .toList(growable: false);

    return Point(
      type: (json['type'] ?? 'Point').toString(),
      coordinates: parsedCoords.length >= 2
          ? parsedCoords.sublist(0, 2)
          : const [0, 0],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}
