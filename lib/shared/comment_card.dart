import 'package:autostop/shared/star_rating.dart';
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 8),
                Text(comment.userMail),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StarRating(
                  initialRating: comment.rate.toDouble(),
                  showRate: false,
                ),
                Text(
                  comment.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Commenté le ${comment.updatedAt.day}/${comment.updatedAt.month}/${comment.updatedAt.year}",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(comment.content),
          ],
        ),
      ),
    );
  }
}
