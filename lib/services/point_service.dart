import 'package:cloud_firestore/cloud_firestore.dart';

class PointService {
  final CollectionReference pointsCollection =
      FirebaseFirestore.instance.collection('points');

  Future<void> addPoint(Point point) async {
    await pointsCollection.add(point.toJson());
  }

  Stream<List<Point>> getApprovedPointsStream() {
    return pointsCollection.snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) {
              if (doc.data() != null) {
                return Point.fromJson(
                    doc.id, doc.data() as Map<String, dynamic>);
              } else {
                throw Exception("Document data is null");
              }
            })
            .where((e) => e.approved)
            .toList();
      },
    );
  }
}

class Point {
  static const double size = 40;

  final String? documentId;
  final double latitude;
  final double longitude;
  final String name;
  final String description;
  final DateTime updatedAt;
  final bool approved;
  final String creatorEmail;

  Point({
    this.documentId,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.description,
    required this.updatedAt,
    required this.approved,
    required this.creatorEmail,
  });

  factory Point.fromJson(String documentId, Map<String, dynamic> map) {
    return Point(
      documentId: documentId,
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      name: map['name'] ?? "",
      description: map['description'] ?? "",
      updatedAt: ((map['updated_at'] ?? DateTime.now()) as Timestamp).toDate(),
      approved: map['approved'] ?? false,
      creatorEmail: map['creator_email'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'description': description,
      'updated_at': updatedAt,
      'approved': approved,
      'creator_email': creatorEmail,
    };
  }
}
