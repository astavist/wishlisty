import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final Color color;

  const LogoWidget({
    super.key,
    this.size = 60,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Two overlapping circles representing "links"
          Positioned(
            left: size * 0.15,
            child: Container(
              width: size * 0.4,
              height: size * 0.4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: size * 0.15,
            child: Container(
              width: size * 0.4,
              height: size * 0.4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Heart symbol in the center
          Icon(
            Icons.favorite,
            size: size * 0.3,
            color: color,
          ),
        ],
      ),
    );
  }
} 