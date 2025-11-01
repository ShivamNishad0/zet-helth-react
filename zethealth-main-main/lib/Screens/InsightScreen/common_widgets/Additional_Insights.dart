import 'package:flutter/material.dart';
import 'package:zet_health/Helper/ColorHelper.dart'; // for primaryColor

class AdditionalInsights extends StatefulWidget {
  final List<dynamic>? needsImprovements;

  const AdditionalInsights({super.key, this.needsImprovements});

  @override
  State<AdditionalInsights> createState() => _AdditionalInsightsState();
}

class _AdditionalInsightsState extends State<AdditionalInsights> {
  bool _expanded = false;

  // Helper to determine status based on reference range
  String _getStatus(String currentValue, String reference) {
    try {
      final double value = double.tryParse(currentValue) ?? 0;

      if (reference.contains("-")) {
        // Range like "56 - 119 U/L"
        final parts = reference.split("-");
        final low = double.tryParse(parts[0].trim().split(" ").first) ?? 0;
        final high = double.tryParse(parts[1].trim().split(" ").first) ?? 0;

        if (value < low) return "Low";
        if (value > high) return "High";
        return "Normal";
      } else if (reference.toLowerCase().contains("upto")) {
        // Format "upto 40 U/L"
        final limit = double.tryParse(
          reference.replaceAll(RegExp(r'[^0-9.]'), ""),
        ) ?? 0;
        if (value > limit) return "High";
        return "Normal";
      }
    } catch (e) {
      return "Unknown";
    }
    return "Unknown";
  }

  // Color for status
  Color _getStatusColor(String status) {
    switch (status) {
      case "High":
        return Colors.redAccent;
      case "Low":
        return Colors.orangeAccent;
      case "Normal":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final needsImprovements = widget.needsImprovements;

    if (needsImprovements == null || needsImprovements.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 20),
          Text(
            "No metrics need improvement. Great job!",
            style: TextStyle(fontSize: 16, color: Colors.green),
          ),
        ],
      );
    }

    // Limit to 4 if not expanded
    final displayList =
        _expanded ? needsImprovements : needsImprovements.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with one "Needs Improvement" tag
        Row(
          children: [
            Text(
              "Areas to Improve",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                "Needs Improvement",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // List of cards
        Column(
          children: displayList.map((insight) {
            final status = _getStatus(
              insight['current_value'] ?? "-",
              insight['reference_range'] ?? "-",
            );
            final statusColor = _getStatusColor(status);

            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Left indicator
                    Container(
                      width: 6,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Icon
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.redAccent.withOpacity(0.2),
                      child: const Icon(
                        Icons.health_and_safety,
                        size: 28,
                        color: Colors.redAccent,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Text content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              insight['parameter'] ?? "Unknown",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  insight['current_value'] ?? "-",
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Reference: ${insight['reference_range'] ?? "-"}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // See more / See less
        if (needsImprovements.length > 3)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() {
                _expanded = !_expanded;
              }),
              child: Text(
                _expanded ? "See less" : "See more",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
