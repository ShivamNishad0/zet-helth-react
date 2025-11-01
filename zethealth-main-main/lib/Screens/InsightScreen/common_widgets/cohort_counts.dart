import 'package:flutter/material.dart';

class CohortCounts extends StatelessWidget {
  final Map<String, dynamic>? counts;

  const CohortCounts({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    if (counts == null) return const SizedBox();

    final highRiskCount = counts?['high_risk'] ?? 0;
    final earlySignsCount = counts?['early_signs'] ?? 0;
    final allIsWellCount = counts?['all_is_well'] ?? 0;
    final notTestedCount = counts?['not_tested'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with scroll indicator
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Row(
            children: [
              Text(
                'Health Snapshot',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.swipe, size: 18, color: Colors.grey),
              Text(
                'Swipe to view',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        
        // Horizontal scrollable cards with visual indicators
        SizedBox(
          height: 100, // Fixed height for the scrollable area
          child: Stack(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    const SizedBox(width: 6), // Left padding
                    _CohortCard(
                      title: "HIGH RISK",
                      count: highRiskCount,
                      color: Colors.red.shade100,
                      textColor: Colors.red.shade900,
                    ),
                    _CohortCard(
                      title: "EARLY SIGNS",
                      count: earlySignsCount,
                      color: Colors.orange.shade100,
                      textColor: Colors.orange.shade900,
                    ),
                    _CohortCard(
                      title: "ALL IS WELL",
                      count: allIsWellCount,
                      color: Colors.green.shade100,
                      textColor: Colors.green.shade900,
                    ),
                    _CohortCard(
                      title: "NOT TESTED",
                      count: notTestedCount,
                      color: Colors.grey.shade300,
                      textColor: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 30), // Extra right padding to show part of 4th card
                  ],
                ),
              ),
              
              // Right fade effect to indicate more content
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 30,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CohortCard extends StatelessWidget {
  final String title;
  final dynamic count;
  final Color color;
  final Color textColor;

  const _CohortCard({
    required this.title,
    required this.count,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90, // Reduced width from 120 to 90
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10, // Slightly smaller font
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18, // Slightly smaller font
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}