import 'package:flutter/material.dart';
import 'package:zet_health/Screens/InsightScreen/common_widgets/CategoryScreen.dart';

class HealthCategories extends StatelessWidget {
  final Map<String, dynamic>? cohorts;

  const HealthCategories({super.key, required this.cohorts});

  @override
  Widget build(BuildContext context) {
    if (cohorts == null || cohorts!.isEmpty) return const SizedBox();

    // Collect categories grouped by cohort
    final Map<String, List<Map<String, dynamic>>> grouped = {
      "high_risk": [],
      "early_signs": [],
      "all_is_well": [],
      "not_tested": [],
    };

    // The correct structure: cohorts -> categories -> category data
    cohorts?.forEach((cohortKey, cohortData) {
      if (cohortData is Map) {
        final categories = cohortData["categories"] as Map<String, dynamic>?;
        if (categories != null) {
          categories.forEach((categoryName, categoryData) {
            grouped[cohortKey]?.add({
              "name": categoryName,
              "cohort": cohortKey,
              "data": categoryData,
            });
          });
        }
      }
    });

    // Define order + labels
    final cohortOrder = [
      {"key": "high_risk", "title": "High Risk"},
      {"key": "early_signs", "title": "Early Signs"},
      {"key": "all_is_well", "title": "All Is Well"},
      {"key": "not_tested", "title": "Not Tested"}, // Add not_tested to order
    ];

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cohortOrder.expand((cohort) {
        final key = cohort["key"] as String;
        final title = cohort["title"] as String;
        final categories = grouped[key] ?? [];

        if (categories.isEmpty) return <Widget>[];

        return [
          // Cohort heading
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: key == "high_risk"
                        ? Colors.red.shade700
                        : key == "early_signs"
                            ? Colors.orange.shade800
                            : key == "all_is_well"
                                ? Colors.green.shade800
                                : Colors.grey.shade700, // Grey for not_tested
                  ),
                ),
              ],
            ),
          ),

          // Category cards under heading
          ...categories.map((category) => _CategoryCard(
                name: category["name"],
                cohort: category["cohort"],
                data: category["data"],
                onTap: () {
                    final params = (category["data"]?["parameters"] ?? []) as List<dynamic>;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryScreen(
                          category: category["name"],
                          values: params,
                          insight: category["data"]?["insight"],
                          cohort: category["cohort"],
                          recommendation: category["data"]?["recommendation"],
                        ),
                      ),
                    );
                  
                },
              )),
        ];
      }).toList(),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final String cohort;
  final Map<String, dynamic>? data;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.cohort,
    required this.data,
    required this.onTap,
  });

  // Map cohort to label + gradient + icons
  Map<String, dynamic> _getCohortInfo(String cohort) {
    switch (cohort) {
      case "all_is_well":
        return {
          "label": "Stable",
          "gradient": LinearGradient(
            colors: [const Color.fromARGB(205, 148, 231, 151), Colors.green.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          "leftIcon": Icons.check_circle_outline_outlined,
          "rightIcon": Icons.add_circle_outline,
          "signalIcon": Icons.signal_cellular_alt,
          "iconColor": const Color.fromARGB(255, 83, 175, 88),
          "textColor": const Color(0xC016BA45),
        };
      case "early_signs":
        return {
          "label": "Monitor",
          "gradient": LinearGradient(
            colors: [Colors.orange.shade200, Colors.orange.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          "leftIcon": Icons.warning_amber_rounded,
          "rightIcon": Icons.error_outline,
          "signalIcon": Icons.signal_cellular_alt,
          "iconColor": Colors.orange.shade700,
          "textColor": Colors.orange.shade900,
        };
      case "high_risk":
        return {
          "label": "Elevated",
          "gradient": LinearGradient(
            colors: [Colors.red.shade200, Colors.red.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          "leftIcon": Icons.error,
          "rightIcon": Icons.dangerous_outlined,
          "signalIcon": Icons.signal_cellular_alt,
          "iconColor": Colors.red.shade700,
          "textColor": Colors.red.shade900,
        };
      case "not_tested":
        return {
          // "label": "Not Tested",
          "gradient": LinearGradient(
            colors: [Colors.grey.shade300, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          // "leftIcon": Icons.help_outline,
          "rightIcon": Icons.help_outline,
          "signalIcon": Icons.signal_cellular_0_bar,
          "iconColor": Colors.grey.shade600,
          "textColor": Colors.grey.shade700,
        };
      default:
        return {
          "label": "Unknown",
          "gradient": LinearGradient(
            colors: [Colors.grey.shade300, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          "leftIcon": Icons.help_outline,
          "rightIcon": Icons.help_center_outlined,
          "signalIcon": Icons.signal_cellular_alt,
          "iconColor": Colors.grey.shade700,
          "textColor": Colors.grey.shade800,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final cohortInfo = _getCohortInfo(cohort);
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: screenWidth * 0.90,
          height: 110,
          decoration: BoxDecoration(
            gradient: cohortInfo["gradient"],
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side: Category + Status with icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: cohort == "not_tested" 
                          ? Colors.grey.shade700 // Grey text for not tested
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        cohortInfo["leftIcon"],
                        size: 22,
                        color: cohortInfo["iconColor"],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cohortInfo["label"] ?? "",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: cohortInfo["textColor"],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Right side: circular icon + signal icon
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(
                      cohortInfo["rightIcon"],
                      color: cohortInfo["iconColor"],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    cohortInfo["signalIcon"],
                    size: 20,
                    color: cohortInfo["iconColor"],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}