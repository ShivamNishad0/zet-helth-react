import 'package:flutter/material.dart';
import 'package:zet_health/Helper/ColorHelper.dart';

class AnimatedSeeMore extends StatefulWidget {
  const AnimatedSeeMore({Key? key}) : super(key: key);

  @override
  State<AnimatedSeeMore> createState() => _AnimatedSeeMoreState();
}

class _AnimatedSeeMoreState extends State<AnimatedSeeMore>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true); // bounce loop

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.2), // slight downward movement
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SlideTransition(
          position: _offsetAnimation,
          child: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 36,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "See more details",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
