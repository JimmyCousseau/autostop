// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import '../models/user_action.dart';

// class UserActionService {
//   static const String apiUrl =
//       'http://localhost:3000'; // Replace with your API URL

//   Future<List<UserAction>> fetchUserActions() async {
//     final response = await http.get(Uri.parse('$apiUrl/user_actions'));

//     if (response.statusCode == 200) {
//       final List<dynamic> responseData = json.decode(response.body);
//       return responseData.map((data) => UserAction.fromJson(data)).toList();
//     } else {
//       throw Exception('Failed to fetch user actions');
//     }
//   }

//   Future<UserAction> createUserAction(UserAction userAction) async {
//     final response = await http.post(
//       Uri.parse('$apiUrl/user_actions'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(userAction.toJson()),
//     );

//     if (response.statusCode == 201) {
//       return UserAction.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to create user action');
//     }
//   }

//   Future<void> deleteUserAction(int id) async {
//     final response = await http.delete(Uri.parse('$apiUrl/user_actions/$id'));

//     if (response.statusCode != 204) {
//       throw Exception('Failed to delete user action');
//     }
//   }
// }
