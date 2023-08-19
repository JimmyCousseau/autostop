import 'package:cloud_firestore/cloud_firestore.dart';

class PointService {
  final CollectionReference pointsCollection =
      FirebaseFirestore.instance.collection('points');

  Future<void> addPoint(Point point) async {
    await pointsCollection.add(point.toMap());
  }

  Future<void> updatePoint(Point point) async {
    await pointsCollection.doc(point.documentId).update(point.toMap());
  }

  Future<void> deletePoint(String pointId) async {
    await pointsCollection.doc(pointId).delete();
  }

  Stream<List<Point>> getApprovedPointsStream() {
    return pointsCollection.snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) {
              if (doc.data() != null) {
                return Point.fromMap(
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool approved;

  Point({
    this.documentId,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.approved,
  });

  factory Point.fromMap(String documentId, Map<String, dynamic> map) {
    return Point(
      documentId: documentId,
      latitude: map['latitude'],
      longitude: map['longitude'],
      name: map['name'],
      description: map['description'],
      createdAt: map['created_at'].toDate(),
      updatedAt: map['updated_at'].toDate(),
      approved: map['approved'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'approved': approved,
    };
  }
}
