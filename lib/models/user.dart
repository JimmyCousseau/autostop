// class User {
//   int id;
//   String username;
//   String email;
//   DateTime createdAt;
//   DateTime updatedAt;

//   User({
//     required this.id,
//     required this.username,
//     required this.email,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       username: json['username'],
//       email: json['email'],
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'username': username,
//       'email': email,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//     };
//   }
// }
