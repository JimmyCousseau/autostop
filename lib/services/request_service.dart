// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import '../models/request.dart';

// class RequestService {
//   final String baseUrl;

//   RequestService(this.baseUrl);

//   Future<Request> createRequest(Request request) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/requests'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(request.toJson()),
//     );

//     if (response.statusCode == 200) {
//       return Request.fromJson(jsonDecode(response.body));
//     } else {
//       throw Exception('Failed to create request');
//     }
//   }

//   Future<void> updateRequestStatus(int requestId, String status) async {
//     final response = await http.put(
//       Uri.parse('$baseUrl/requests/$requestId/status'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode({'status': status}),
//     );

//     if (response.statusCode != 204) {
//       throw Exception('Failed to update request status');
//     }
//   }

//   Future<Request?> getRequestById(int requestId) async {
//     final response = await http.get(Uri.parse('$baseUrl/requests/$requestId'));

//     if (response.statusCode == 200) {
//       return Request.fromJson(jsonDecode(response.body));
//     } else {
//       return null;
//     }
//   }

//   // Add more methods as needed
// }
