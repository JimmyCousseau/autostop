// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import '../models/favorite.dart';

// class FavoriteService {
//   static const String apiUrl =
//       'http://localhost:3000'; // Replace with your API URL

//   Future<List<Favorite>> fetchFavorites() async {
//     final response = await http.get(Uri.parse('$apiUrl/favorites'));

//     if (response.statusCode == 200) {
//       final List<dynamic> responseData = json.decode(response.body);
//       return responseData.map((data) => Favorite.fromJson(data)).toList();
//     } else {
//       throw Exception('Failed to fetch favorites');
//     }
//   }

//   Future<Favorite> createFavorite(Favorite favorite) async {
//     final response = await http.post(
//       Uri.parse('$apiUrl/favorites'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(favorite.toJson()),
//     );

//     if (response.statusCode == 201) {
//       return Favorite.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to create favorite');
//     }
//   }

//   Future<void> deleteFavorite(int id) async {
//     final response = await http.delete(Uri.parse('$apiUrl/favorites/$id'));

//     if (response.statusCode != 204) {
//       throw Exception('Failed to delete favorite');
//     }
//   }
// }
