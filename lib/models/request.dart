// class Request {
//   int requestId;
//   int pointId;
//   String status;
//   DateTime lastChange;

//   Request({
//     required this.requestId,
//     required this.pointId,
//     required this.status,
//     required this.lastChange,
//   });

//   factory Request.fromJson(Map<String, dynamic> json) {
//     return Request(
//       requestId: json['request_id'],
//       pointId: json['point_id'],
//       status: json['status'],
//       lastChange: DateTime.parse(json['last_change']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'request_id': requestId,
//       'point_id': pointId,
//       'status': status,
//       'last_change': lastChange.toIso8601String(),
//     };
//   }
// }
