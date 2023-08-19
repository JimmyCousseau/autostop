// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import '../models/user.dart';

// class UserService {
//   static const String apiUrl =
//       'http://localhost:3000'; // Replace with your API URL

//   Future<List<User>> fetchUsers() async {
//     final response = await http.get(Uri.parse('$apiUrl/users'));

//     if (response.statusCode == 200) {
//       final List<dynamic> responseData = json.decode(response.body);
//       return responseData.map((data) => User.fromJson(data)).toList();
//     } else {
//       throw Exception('Failed to fetch users');
//     }
//   }

//   Future<User> createUser(User user) async {
//     final response = await http.post(
//       Uri.parse('$apiUrl/users'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(user.toJson()),
//     );

//     if (response.statusCode == 201) {
//       return User.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to create user');
//     }
//   }

//   Future<void> updateUser(User user) async {
//     final response = await http.put(
//       Uri.parse('$apiUrl/users/${user.id}'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(user.toJson()),
//     );

//     if (response.statusCode != 204) {
//       throw Exception('Failed to update user');
//     }
//   }

//   Future<void> deleteUser(int id) async {
//     final response = await http.delete(Uri.parse('$apiUrl/users/$id'));

//     if (response.statusCode != 204) {
//       throw Exception('Failed to delete user');
//     }
//   }
// }
