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
    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height / 3,
          maxWidth: MediaQuery.of(context).size.width / 2),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "Ajouter",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 5),
              Text("latitude: ${p.latitude}"),
              Text("longitude: ${p.longitude}"),
              const SizedBox(height: 5),
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
                                updatedAt: DateTime.now(),
                                approved: false,
                                creatorEmail:
                                    FirebaseAuth.instance.currentUser!.email!,
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
