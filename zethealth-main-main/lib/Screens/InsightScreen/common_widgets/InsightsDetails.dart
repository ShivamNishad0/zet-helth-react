import 'package:flutter/material.dart';
import 'package:zet_health/Helper/ColorHelper.dart';

class InsightsDetails extends StatefulWidget {
  final List<String>? looksGood;
  final List<String>? notLooksGood;

  const InsightsDetails({super.key, this.looksGood, this.notLooksGood});

  @override
  State<InsightsDetails> createState() => _InsightsDetailsState();
}

class _InsightsDetailsState extends State<InsightsDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  bool _expandLooksGood = false;
  bool _expandNotLooksGood = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildItemCard(String item, Color startColor, Color endColor) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          item,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<String>? items,
    Color startColor,
    Color endColor,
    bool expanded,
    VoidCallback onToggle,
  ) {
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    // Limit items to 4 if not expanded
    final displayItems = expanded ? items : items.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: startColor,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: displayItems
              .map((item) => _buildItemCard(item, startColor, endColor))
              .toList(),
        ),
        if (items.length > 4)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onToggle,
              child: Text(
                expanded ? "See less" : "See more",
                style: TextStyle(
                  color: startColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          "Looks Good",
          widget.looksGood,
          const Color.fromARGB(255, 54, 124, 57),
          const Color.fromARGB(255, 55, 190, 55),
          _expandLooksGood,
          () => setState(() => _expandLooksGood = !_expandLooksGood),
        ),
        _buildSection(
          "Not Looks Good",
          widget.notLooksGood,
          Colors.red.shade600,
          const Color.fromARGB(255, 123, 29, 29),
          _expandNotLooksGood,
          () => setState(() => _expandNotLooksGood = !_expandNotLooksGood),
        ),
      ],
    );
  }
}
