import 'package:autostop/screens/auth_screen.dart';
import 'package:autostop/screens/profil_screen.dart';
import 'package:autostop/services/user_service.dart';
import 'package:autostop/shared/btn_icon_txt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ParameterDialog extends StatelessWidget {
  ParameterDialog({super.key});

  final currentUser = FirebaseAuth.instance.currentUser;

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
              IconButton(
                onPressed: () {},
                icon: const Icon(null),
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.transparent),
                ),
              ),
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
                    text: "Mon profil",
                    icon: Icons.account_circle,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ProfilScreen()));
                    },
                  ),
                if (isConnected)
                  BtnIconText(
                    text: "Se déconnecter",
                    icon: Icons.logout,
                    onPressed: () {
                      UserService().logout(context);
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
