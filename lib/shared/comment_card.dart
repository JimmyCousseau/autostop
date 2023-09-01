import 'package:flutter/material.dart';
import '../services/comment_service.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;

  const CommentCard({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 8),
                Text(""),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              "Temps d'attente estimé: ${comment.estimatedTime.toStringAsFixed(0)} minutes",
              softWrap: true,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              "Commenté le ${_formatDate(comment.updatedAt)}",
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 8),
            Text(comment.content),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
