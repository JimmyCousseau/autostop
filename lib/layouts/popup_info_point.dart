import 'package:autostop/screens/auth_screen.dart';
import 'package:autostop/screens/comment_screen.dart';
import 'package:autostop/services/comment_service.dart';
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
  late Future<Rate> _commentDataFuture;

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
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 3),
      width: MediaQuery.of(context).size.width / 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "Direction ${widget.point.name}",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildEstimatedTime(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.point.description),
              ),
              Text(
                  "Dernière modification: il y a ${updatedDays(widget.point.updatedAt)}"),
              if (isAuthenticated)
                Column(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PointFormScreen(
                                point: widget.point,
                              ),
                            ),
                          );
                        },
                        child: const Text("Proposer une modification")),
                    const SizedBox(
                      height: 8.0,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CommentScreen(
                                pointDocumentId: widget.point.documentId!),
                          ),
                        );
                      },
                      child: const Text("Ajouter un commentaire"),
                    )
                  ],
                ),
              const SizedBox(
                height: 8.0,
              ),
              if (!isAuthenticated)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                      );
                    },
                    child: const Text("Connectez-vous pour plus d'options"),
                  ),
                )
            ]),
          ),
        ),
      ),
    );
  }

  FutureBuilder<Rate> _buildEstimatedTime() {
    return FutureBuilder(
      future: _commentDataFuture,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("...");
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          Rate rate = snapshot.data!;
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CommentScreen(pointDocumentId: widget.point.documentId!),
              ),
            ),
            child: Text(
              "Temps d'attente estimé: \n${rate.estimatedTime.toStringAsFixed(0)} minutes (${rate.totalComments} avis)",
              softWrap: true,
            ),
          );
        } else {
          return const Text('No data available');
        }
      }),
    );
  }
}
