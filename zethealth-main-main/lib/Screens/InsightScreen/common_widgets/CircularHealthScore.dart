import 'package:flutter/material.dart';
import 'package:zet_health/Helper/ColorHelper.dart';

class CircularHealthScore extends StatelessWidget {
  final double score;
  final double size;
  final Duration animationDuration;

  const CircularHealthScore({
    super.key,
    required this.score,
    this.size = 160, // ✅ bigger circle
    this.animationDuration = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: score),
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ✅ Big circular progress
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: value / 100,
                  strokeWidth: 14, // ✅ thicker stroke
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),

              // ✅ Score in the center
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 36, // ✅ larger text
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    "Score",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
