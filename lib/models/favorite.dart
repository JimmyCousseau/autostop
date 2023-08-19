// class Favorite {
//   int id;
//   int userId;
//   int pointId;
//   DateTime createdAt;

//   Favorite({
//     required this.id,
//     required this.userId,
//     required this.pointId,
//     required this.createdAt,
//   });

//   factory Favorite.fromJson(Map<String, dynamic> json) {
//     return Favorite(
//       id: json['favorite_id'],
//       userId: json['user_id'],
//       pointId: json['point_id'],
//       createdAt: DateTime.parse(json['created_at']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'favorite_id': id,
//       'user_id': userId,
//       'point_id': pointId,
//       'created_at': createdAt.toIso8601String(),
//     };
//   }
// }
