import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  final double rating;
  final double size;

  const StarRatingWidget({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Icon(
          half ? Icons.star_half : filled ? Icons.star : Icons.star_border,
          size: size, color: Colors.amber,
        );
      }),
    );
  }
}

class StarRatingPickerWidget extends StatelessWidget {
  final int rating;
  final void Function(int) onRatingChanged;
  final double size;

  const StarRatingPickerWidget({super.key, required this.rating, required this.onRatingChanged, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => GestureDetector(
        onTap: () => onRatingChanged(i + 1),
        child: Icon(i < rating ? Icons.star : Icons.star_border, size: size, color: Colors.amber),
      )),
    );
  }
}
