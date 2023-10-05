import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class PointService {
  final CollectionReference pointsCollection =
      FirebaseFirestore.instance.collection('points');

  Future<DocumentReference> addPoint(Point point) async {
    if (point.documentId == null) {
      return await pointsCollection.add(point.toJson());
    } else {
      final ref = pointsCollection.doc(point.documentId);
      ref.update(point.toJson());
      // TODO: Should control what to update
      return ref;
    }
  }

  Stream<List<Point>> getApproved() {
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
  final double destLat;
  final double destLng;
  final int estimatedTime;

  Point({
    this.documentId,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.description,
    required this.updatedAt,
    required this.approved,
    required this.creatorEmail,
    required this.destLat,
    required this.destLng,
    required this.estimatedTime,
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
      destLat: map['destination_latitude'] ?? 0.0,
      destLng: map['destination_longitude'] ?? 0.0,
      estimatedTime: map['estimated_time'] ?? 0,
    );
  }

  factory Point.fromLatLng(LatLng ll) {
    return Point(
      latitude: ll.latitude,
      longitude: ll.longitude,
      name: "",
      description: "",
      updatedAt: DateTime.now(),
      approved: false,
      creatorEmail: "",
      destLat: 0.0,
      destLng: 0.0,
      estimatedTime: 0,
    );
  }

  LatLng toLatLng() {
    return LatLng(latitude, longitude);
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
      'destination_latitude': destLat,
      'destination_longitude': destLng,
      'estimated_time': estimatedTime,
    };
  }

  void openInMap() async {
    final url = Uri.parse('geo:$latitude,$longitude');
    final fallbackUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl);
      } else {
        throw 'Could not launch $url';
      }
    }
  }
}
