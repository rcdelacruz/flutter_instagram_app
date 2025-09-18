import 'package:flutter/material.dart';

class LinearGradientWidget extends StatelessWidget {
  final List<Color> colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  const LinearGradientWidget({
    super.key,
    required this.colors,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: begin,
          end: end,
        ),
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

// Instagram gradient colors - exact replica from React Native
class InstagramGradient {
  static const List<Color> primary = [
    Color(0xFF833AB4),
    Color(0xFFFD1D1D),
    Color(0xFFFCB045),
  ];

  static const List<Color> viewed = [
    Color(0xFFC7C7C7),
    Color(0xFFC7C7C7),
  ];
}
