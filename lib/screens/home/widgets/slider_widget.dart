import 'package:flutter/material.dart';

class SliderWidget extends StatelessWidget {
  const SliderWidget({
    super.key,
    required this.backdropImage,
    required this.title,
    required this.rating,
  });
  final String backdropImage;
  final String title;
  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
              image: NetworkImage(backdropImage), fit: BoxFit.cover)),
      height: MediaQuery.of(context).size.height * .23,
      width: MediaQuery.of(context).size.width * .9,
    );
  }
}
