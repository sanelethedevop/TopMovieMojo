import 'package:flutter/material.dart';

import '../../../core/utils.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.title,
    this.posterImagePath,
    required this.genre,
  });

  final String title;
  final String? posterImagePath;
  final String genre;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(3),
          height: MediaQuery.of(context).size.height * .2,
          width: MediaQuery.of(context).size.width * .4,
          decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  posterImagePath.toString(),
                ),
              ),
              borderRadius: BorderRadius.circular(12)),
        ),
        WhiteText(
          text: title.length >= 20 ? '${title.substring(0, 17)}...' : title,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }
}
