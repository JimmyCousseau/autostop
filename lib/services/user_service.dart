import 'package:autostop/screens/account_deletion_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../screens/map_screen.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<bool> checkUsernameAvailability(String username) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      if (kDebugMode) {
        print("Error checking username availability: $e");
      }
      return false;
    }
  }

  Future<bool> registerUser(User user) async {
    if (user.password == null) {
      return false;
    }
    try {
      await _firestore.collection('users').add(user.toJson());

      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password!,
      );
      if (userCredential.user != null) {
        await userCredential.user?.sendEmailVerification();
        await userCredential.user?.updateDisplayName(user.username);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    final auth = FirebaseAuth.instance;
    try {
      final user = auth.currentUser;
      if (user != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
        return true;
      }
      return false;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return false;
    }
  }

  void logout(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text("Se déconnecter"),
          content: const Text(
            "Êtes-vous sûr ? \n Vous ne pourrez plus laisser de commentaires \nou bien ajouter de nouveaux spots.",
          ),
          actions: [
            ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.redAccent)),
                onPressed: () async {
                  final scaffold = Scaffold.of(context);
                  final navigator = Navigator.of(context);
                  await FirebaseAuth.instance.signOut();
                  scaffold.closeDrawer();
                  navigator.pushAndRemoveUntil<void>(
                    MaterialPageRoute<void>(
                        builder: (BuildContext context) => const MapScreen()),
                    ModalRoute.withName('/'),
                  );
                },
                child: const Text("Se déconnecter")),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Retour"),
            )
          ],
        );
      }),
    );
  }

  void deleteAccount(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text(
                "Vous-êtes sur le point de supprimer votre compte, continuer ?"),
            actions: [
              ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.redAccent)),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (_) => const AccountDeletionPage()));
                  },
                  child: const Text("Supprimer le compte")),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Retour"),
              )
            ],
          );
        });
  }
}

class User {
  final String email;
  final String? role;
  final String username;
  final String? password;

  User({
    required this.email,
    this.role,
    required this.username,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      role: json['role'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'role': role,
      'username': username,
    };
  }
}
