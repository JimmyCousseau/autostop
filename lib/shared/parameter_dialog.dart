import 'package:autostop/screens/auth_screen.dart';
import 'package:autostop/shared/btn_icon_txt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/map_screen.dart';

class ParameterDialog extends StatelessWidget {
  ParameterDialog({super.key});

  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final isConnected = currentUser != null;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              Text(
                'AutoStop',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              IconButton(onPressed: () {}, icon: const Icon(null)),
            ],
          ),
          if (isConnected)
            Text(
              'Bonjour !',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          if (isConnected)
            Text("${currentUser?.email}",
                style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isConnected)
                  BtnIconText(
                    icon: Icons.login,
                    text: "Se connecter",
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AuthScreen(),
                      ),
                    ),
                  ),
                if (isConnected)
                  BtnIconText(
                    text: "Changer son mot de passe",
                    icon: Icons.password,
                    onPressed: () {},
                  ),
                if (isConnected)
                  BtnIconText(
                    text: "Se déconnecter",
                    icon: Icons.logout,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: ((context) {
                          return AlertDialog(
                            title: const Text("Se déconnecter"),
                            content: const Text(
                              "Êtes-vous sûr ? \n Vous ne pourrez plus laisser de commentaires \nou bien ajouter de nouveaux spots.",
                            ),
                            actions: [
                              ElevatedButton(
                                  onPressed: () async {
                                    final scaffold = Scaffold.of(context);
                                    final navigator = Navigator.of(context);
                                    await FirebaseAuth.instance.signOut();
                                    scaffold.closeDrawer();
                                    navigator.pushAndRemoveUntil<void>(
                                      MaterialPageRoute<void>(
                                          builder: (BuildContext context) =>
                                              const MapScreen()),
                                      ModalRoute.withName('/'),
                                    );
                                  },
                                  child: const Text("Se déconnecter")),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("retour"),
                              )
                            ],
                          );
                        }),
                      );
                    },
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}
