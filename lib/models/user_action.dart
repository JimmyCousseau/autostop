// class UserAction {
//   int id;
//   int userId;
//   int pointId;
//   String actionType;
//   DateTime createdAt;

//   UserAction({
//     required this.id,
//     required this.userId,
//     required this.pointId,
//     required this.actionType,
//     required this.createdAt,
//   });

//   factory UserAction.fromJson(Map<String, dynamic> json) {
//     return UserAction(
//       id: json['user_action_id'],
//       userId: json['user_id'],
//       pointId: json['point_id'],
//       actionType: json['action_type'],
//       createdAt: DateTime.parse(json['created_at']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'user_action_id': id,
//       'user_id': userId,
//       'point_id': pointId,
//       'action_type': actionType,
//       'created_at': createdAt.toIso8601String(),
//     };
//   }
// }
