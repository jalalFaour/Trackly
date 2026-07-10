import 'stop.dart';

class MapRoute {
  final String id;
  final String routeName;
  final String companyName;
  final LineStringPath path;
  final List<Stop>? stops;
  final String routeLengthKm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MapRoute({
    required this.id,
    required this.companyName,
    required this.routeLengthKm,
    required this.routeName,
    required this.path,
    this.stops,
    this.createdAt,
    this.updatedAt,
  });

  factory MapRoute.defaultObj() => MapRoute(
    id: '',
    companyName: '',
    routeLengthKm: '',
    routeName: '',
    path: const LineStringPath.empty(),
    stops: const [],
    createdAt: null,
    updatedAt: null,
  );

  factory MapRoute.fromJson(Map<String, dynamic> json) {
    return MapRoute(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      companyName: (json['companyId']['name'] ?? '').toString(),
      routeName: (json['routeName'] ?? '').toString(),
      routeLengthKm: (json['routeLengthKm'] ?? '').toString(),
      path: json['path'] is Map<String, dynamic>
          ? LineStringPath.fromJson(json['path'] as Map<String, dynamic>)
          : json['path'] is Map
          ? LineStringPath.fromJson(
              (json['path'] as Map).cast<String, dynamic>(),
            )
          : const LineStringPath.empty(),
      stops: (json['stops'] as List? ?? const [])
          .map((e) => Stop.fromJson((e as Map).cast<String, dynamic>()))
          .toList(growable: false),
      createdAt: _tryParseDate(json['createdAt']),
      updatedAt: _tryParseDate(json['updatedAt']),
    );
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final str = value.toString();
    if (str.isEmpty) return null;
    try {
      return DateTime.parse(str);
    } catch (_) {
      return null;
    }
  }
}

/// GeoJSON LineString entity
class LineStringPath {
  final String type;
  final List<List<double>> coordinates;

  const LineStringPath({
    this.type = 'LineString',
    required this.coordinates,
  });

  const LineStringPath.empty() : type = 'LineString', coordinates = const [];

  factory LineStringPath.fromJson(Map<String, dynamic> json) {
    final rawCoords = (json['coordinates'] as List? ?? const []);

    final coords = rawCoords
        .map((e) {
          final point = (e as List? ?? const []).toList(growable: false);
          final lat = point.isNotEmpty ? (point[0] as num).toDouble() : 0.0;
          final lng = point.length > 1 ? (point[1] as num).toDouble() : 0.0;
          return [lat, lng];
        })
        .toList(growable: false);

    return LineStringPath(
      type: (json['type'] ?? 'LineString').toString(),
      coordinates: coords,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}

//        {
//         "path": {
//           "type": "LineString",
//           "coordinates": [
//             [
//               37.157585620880134,
//               36.200146076634326
//             ],
//             [
//               37.16639399528504,
//               36.19736689637891
//             ],
//             [
//               37.16706988268281,
//               36.19681279239925
//             ],
//             [
//               37.16454860620881,
//               36.196778160002125
//             ],
//             [
//               37.16098666191102,
//               36.1965357205024
//             ]
//           ]
//         },
//         "_id": "69df2d836533a60eb7ce8856",
//         "companyId": "69def3a658926a12b0006c4c",
//         "routeName": "ويو ويو",
//         "stops": [],
//         "createdAt": "2026-04-15T06:17:39.737Z",
//         "updatedAt": "2026-04-15T06:17:39.737Z"
//       };

//        {
//         "path": {
//           "type": "LineString",
//           "coordinates": [
//             [
//               37.157585620880134,
//               36.200146076634326
//             ],
//             [
//               37.16639399528504,
//               36.19736689637891
//             ],
//             [
//               37.16706988268281,
//               36.19681279239925
//             ],
//             [
//               37.16454860620881,
//               36.196778160002125
//             ],
//             [
//               37.16098666191102,
//               36.1965357205024
//             ]
//           ]
//         },
//         "_id": "69df2d836533a60eb7ce8856",
//         "companyId": "69def3a658926a12b0006c4c",
//         "routeName": "ويو ويو",
//         "stops": [],
//         "createdAt": "2026-04-15T06:17:39.737Z",
//         "updatedAt": "2026-04-15T06:17:39.737Z"
//       },
