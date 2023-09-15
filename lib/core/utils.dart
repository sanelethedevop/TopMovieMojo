import 'package:flutter/material.dart';

class Screen {
  static height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static width(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static to(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return page;
      },
    ));
  }

  static close(
    BuildContext context,
  ) {
    Navigator.pop(context);
  }
}

class WhiteText extends StatelessWidget {
  WhiteText({super.key, required this.text, this.fontSize, this.fontWeight});
  final String text;
  double? fontSize = 14.0;
  FontWeight? fontWeight = FontWeight.normal;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: fontSize, fontWeight: fontWeight, color: Colors.white),
    );
  }
}

class GreyText extends StatelessWidget {
  GreyText({super.key, required this.text, this.fontSize, this.fontWeight});
  final String text;
  double? fontSize = 14.0;
  FontWeight? fontWeight = FontWeight.normal;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: fontSize, fontWeight: fontWeight, color: Colors.grey),
    );
  }
}
