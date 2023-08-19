// class Point {
//   static const double size = 40;
//   int? id;
//   double latitude;
//   double longitude;
//   String name;
//   String description;
//   DateTime createdAt;
//   DateTime updatedAt;
//   bool? approved;

//   Point({
//     this.id,
//     required this.latitude,
//     required this.longitude,
//     required this.name,
//     required this.description,
//     required this.createdAt,
//     required this.updatedAt,
//     this.approved,
//   });

//   factory Point.fromJson(Map<String, dynamic> json) {
//     return Point(
//       id: json['point_id'] ?? 0,
//       latitude: double.tryParse(json['latitude']) ?? 0,
//       longitude: double.tryParse(json['longitude']) ?? 0,
//       name: json['name'],
//       description: json['description'],
//       createdAt: DateTime.parse(json['created_at']),
//       updatedAt: DateTime.parse(json['updated_at']),
//       approved: json['approved'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     if (id == null) {
//       return {
//         'latitude': latitude.toString(),
//         'longitude': longitude.toString(),
//         'name': name,
//         'description': description,
//         'created_at': createdAt.toIso8601String(),
//         'updated_at': updatedAt.toIso8601String(),
//         'approved': approved ?? false,
//       };
//     }
//     return {
//       'point_id': id ?? "",
//       'latitude': latitude.toString(),
//       'longitude': longitude.toString(),
//       'name': name,
//       'description': description,
//       'created_at': createdAt.toIso8601String(),
//       'updated_at': updatedAt.toIso8601String(),
//       'approved': approved ?? false,
//     };
//   }
// }
