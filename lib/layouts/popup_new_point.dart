import 'package:autostop/screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../screens/point_form_screen.dart';
import '../services/point_service.dart';

class PopupNewPoint extends StatelessWidget {
  final LatLng p;

  const PopupNewPoint({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    bool isAuthenticated = FirebaseAuth.instance.currentUser != null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                "Ajouter",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    Text("latitude: ${p.latitude}, longitude: ${p.longitude}"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      if (isAuthenticated) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PointFormScreen(
                              point: Point(
                                latitude: p.latitude,
                                longitude: p.longitude,
                                name: "",
                                description: "",
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                                approved: false,
                              ),
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AuthScreen()),
                        );
                      }
                    },
                    child: isAuthenticated
                        ? const Text("Ajouter un nouveau spot")
                        : const Text(
                            "Connectez-vous pour l'ajouter à AutoStop")),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
