import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({
    super.key,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/Traffix.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
    );
  }
}
