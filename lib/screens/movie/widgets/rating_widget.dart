import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:moviemojo/core/utils.dart';

class RatingGlassWidget extends StatelessWidget {
  const RatingGlassWidget({
    super.key,
    required this.rating,
    required this.totalVotes,
  });
  final String rating;
  final int totalVotes;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
            child: Container(
              height: Screen.height(context) * .06,
              width: Screen.height(context) * 0.07,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: WhiteText(
                      text: rating,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: WhiteText(
                      text: '$totalVotes',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
