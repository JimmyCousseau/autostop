// import 'package:flutter/material.dart';

// class StarRating extends StatefulWidget {
//   final double initialRating;
//   final int? commentCount;
//   final ValueChanged<double>? onChanged;
//   final bool showRate;

//   const StarRating({
//     super.key,
//     required this.initialRating,
//     this.onChanged,
//     this.commentCount,
//     this.showRate = true,
//   });

//   @override
//   State<StarRating> createState() => _StarRatingState();
// }

// class _StarRatingState extends State<StarRating> {
//   double _selectedRating = 0;

//   @override
//   void initState() {
//     super.initState();
//     _selectedRating = widget.onChanged != null ? 0.0 : widget.initialRating;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Row(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (widget.showRate)
//                 Text(
//                   _selectedRating.toStringAsFixed(1),
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//               const SizedBox(width: 5),
//               ...List.generate(
//                 5,
//                 (index) {
//                   final isSelected = index < _selectedRating.floor();
//                   final color = isSelected ? Colors.orange : Colors.grey;

//                   return widget.onChanged != null
//                       ? GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _selectedRating = index + 1.0;
//                             });
//                             widget.onChanged!(_selectedRating);
//                           },
//                           child: Icon(
//                             Icons.star,
//                             color: color,
//                             size: 18,
//                           ),
//                         )
//                       : Icon(
//                           Icons.star,
//                           color: color,
//                           size: 18,
//                         );
//                 },
//               )
//             ]),
//         const SizedBox(height: 5),
//         if (widget.commentCount != null)
//           Text(
//             '(${widget.commentCount} ${widget.commentCount == 1 ? 'comment' : 'comments'})',
//             style: const TextStyle(fontSize: 14, color: Colors.grey),
//           ),
//       ],
//     );
//   }
// }
