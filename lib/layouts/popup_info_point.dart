import 'package:autostop/screens/auth_screen.dart';
import 'package:autostop/screens/comment_screen.dart';
import 'package:autostop/services/comment_service.dart';
import 'package:autostop/shared/star_rating.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/point_form_screen.dart';
import '../services/point_service.dart';

class PopupInfoPoint extends StatefulWidget {
  final Point point;

  const PopupInfoPoint({Key? key, required this.point}) : super(key: key);

  @override
  State<PopupInfoPoint> createState() => _PopupInfoPointState();
}

class _PopupInfoPointState extends State<PopupInfoPoint> {
  late Future<Map<String, dynamic>> _commentDataFuture;

  @override
  void initState() {
    super.initState();
    _commentDataFuture = CommentService()
        .getCommentCountAndAverageRate(widget.point.documentId!);
  }

  String updatedDays(DateTime updated) {
    int updatedMillis = DateTime.now().millisecondsSinceEpoch -
        widget.point.updatedAt.millisecondsSinceEpoch;

    double updatedDays = updatedMillis / 86400000;
    if (updatedDays < 1) {
      return "${(updatedDays * 24).floorToDouble().toInt()} heure(s)";
    }
    return "${updatedDays.floorToDouble().toInt()} jour(s)";
  }

  @override
  Widget build(BuildContext context) {
    bool isAuthenticated = FirebaseAuth.instance.currentUser != null;
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Direction ${widget.point.name}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FutureBuilder(
                        future: _commentDataFuture,
                        builder: ((context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text("");
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            final int commentCount =
                                snapshot.data?['totalComments'];
                            double averageRate = snapshot.data?['averageRate'];
                            return InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CommentScreen(
                                      pointDocumentId:
                                          widget.point.documentId!),
                                ),
                              ),
                              child: StarRating(
                                  initialRating: averageRate,
                                  commentCount: commentCount),
                            );
                          } else {
                            return const Text('No data available');
                          }
                        }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(widget.point.description),
                    ),
                    Text(
                        "Dernière modification: il y a ${updatedDays(widget.point.updatedAt)}"),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (isAuthenticated) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PointFormScreen(
                                  point: widget.point,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthScreen(),
                              ),
                            );
                          }
                        },
                        child: isAuthenticated
                            ? const Text("Ajouter une modification")
                            : const Text("Connectez-vous pour le modifier"),
                      ),
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
