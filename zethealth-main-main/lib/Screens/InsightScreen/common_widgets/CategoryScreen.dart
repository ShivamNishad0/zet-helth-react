import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryScreen extends StatelessWidget {
  final String category;
  final String? insight;
  final List<dynamic> values;
  final String cohort;
  final String? recommendation;

  const CategoryScreen({
    super.key,
    required this.category,
    this.insight,
    required this.values,
    required this.cohort,
    this.recommendation,
  });

  // 🔹 Pick icon + color based on status
  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case "high":
        return Icons.add_circle_outline;
      case "low":
        return Icons.remove_circle_outline;
      case "normal":
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  Color _getStatusColor(String? status, Color cohortColor) {
    switch (status?.toLowerCase()) {
      case "high":
        return Colors.redAccent;
      case "low":
        return Colors.blueAccent;
      case "normal":
        return Colors.green;
      default:
        return cohortColor;
    }
  }

  List<Color> _getCohortGradientColors(String cohort) {
    switch (cohort.toLowerCase()) {
      case "high_risk":
        return [Colors.red.shade400, Colors.red.shade300];
      case "early_signs":
        return [Colors.orange.shade400, Colors.orange.shade300];
      case "all_is_well":
        return [Colors.green.shade400, Colors.green.shade300];
      case "not_tested": // Add this case
      return [Colors.grey.shade400, Colors.grey.shade300];
      default:
        return [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)];
    }
  }

  Color _getCohortPrimaryColor(String cohort) {
    switch (cohort.toLowerCase()) {
      case "high_risk":
        return Colors.red.shade400;
      case "early_signs":
        return Colors.orange.shade400;
      case "all_is_well":
        return Colors.green.shade400;
      case "not_tested":
      return Colors.grey.shade400;
      default:
        return const Color(0xFFFF6B6B);
    }
  }

  // 🔹 Get trend icon and color based on value comparison
  Map<String, dynamic> _getTrendInfo(dynamic item) {
    final currentValue = double.tryParse(item["value"]?.toString() ?? '0');
    final prevHistory = item["prev_history"] as List?;
    
    if (currentValue == null || prevHistory == null || prevHistory.isEmpty) {
      return {
        'icon': Icons.remove,
        'color': Colors.grey,
        'text': 'No previous data',
        'trend': 'stable'
      };
    }
    
    // Get the most recent previous value
    final mostRecentPrev = prevHistory.last;
    final prevValue = double.tryParse(mostRecentPrev["value"]?.toString() ?? '0');
    
    if (prevValue == null) {
      return {
        'icon': Icons.remove,
        'color': Colors.grey,
        'text': 'No previous data',
        'trend': 'stable'
      };
    }
    
    final difference = currentValue - prevValue;
    final percentageChange = (difference / prevValue) * 100;
    
    if (percentageChange > 10) {
      return {
        'icon': Icons.arrow_upward,
        'color': Colors.red,
        'text': '${percentageChange.toStringAsFixed(1)}% increase',
        'trend': 'increasing'
      };
    } else if (percentageChange < -10) {
      return {
        'icon': Icons.arrow_downward,
        'color': Colors.green,
        'text': '${percentageChange.abs().toStringAsFixed(1)}% decrease',
        'trend': 'decreasing'
      };
    } else {
      return {
        'icon': Icons.remove,
        'color': Colors.grey,
        'text': 'Minimal change (${percentageChange.toStringAsFixed(1)}%)',
        'trend': 'stable'
      };
    }
  }

  // 🔹 Generate chart data for trend visualization
  Widget _buildTrendChart(dynamic item, Color primaryColor) {
    final prevHistory = item["prev_history"] as List?;
    final currentValue = double.tryParse(item["value"]?.toString() ?? '0');
    
    if (currentValue == null || prevHistory == null || prevHistory.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Text(
            "No historical data available",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Create historical data including current value
    final historicalData = [
      ...prevHistory.map((history) => {
        'value': double.tryParse(history["value"]?.toString() ?? '0') ?? 0,
        'date': _formatDate(history["created_at"]),
        'status': history["status"],
      }),
      {
        'value': currentValue,
        'date': 'Current',
        'status': item["status"],
      }
    ];

    final minValue = historicalData.map((e) => e['value'] as double).reduce((a, b) => a < b ? a : b) * 0.9;
    final maxValue = historicalData.map((e) => e['value'] as double).reduce((a, b) => a > b ? a : b) * 1.1;

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < historicalData.length) {
                    final isCurrent = index == historicalData.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(
                        top: 4.0,
                        right: isCurrent ? 38.0 : 0.0,
                      ),
                      child: Text(
                        historicalData[index]['date'].toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                interval: 1,
                reservedSize: 20,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % 10 == 0 || value == minValue.round() || value == maxValue.round()) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 32,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          minX: 0,
          maxX: (historicalData.length - 1).toDouble(),
          minY: minValue,
          maxY: maxValue,
          lineBarsData: [
            LineChartBarData(
              spots: historicalData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value['value'] as double);
              }).toList(),
              isCurved: true,
              color: primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: primaryColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to format date
  String _formatDate(String? dateString) {
    if (dateString == null) return 'Previous';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}';
    } catch (e) {
      return 'Previous';
    }
  }

Map<String, String> _getNotTestedInfo(String category) {
  switch (category.toLowerCase()) {
    case "diabetes":
      return {
        "not_tested": "Your report does not include blood sugar-related tests.",
        "why_matters": "These tests help detect pre-diabetes, diabetes, and monitor sugar control.",
        "recommendation": "Consider adding Fasting Blood Sugar (FBS), HbA1c, and Post-Prandial Sugar for a complete view of your glucose health."
      };
    case "cardiac":
      return {
        "not_tested": "Cardiac health markers were not checked in your report.",
        "why_matters": "These tests help detect early signs of cardiovascular disease.",
        "recommendation": "Add ECG, Troponin, and 2D Echo to evaluate your heart function."
      };
    case "liver":
      return {
        "not_tested": "Liver enzyme levels have not been checked in your report.",
        "why_matters": "These tests help detect fatty liver, hepatitis, or enzyme imbalances.",
        "recommendation": "Add a Liver Function Test (LFT) to track your liver health."
      };
    case "kidney":
      return {
        "not_tested": "Kidney function parameters are missing in your report.",
        "why_matters": "These tests detect early kidney disease and check filtration capacity.",
        "recommendation": "Add a Kidney Function Test (KFT), Serum Creatinine, and BUN to monitor kidney health."
      };
    case "thyroid":
      return {
        "not_tested": "Thyroid hormone levels are not included in your report.",
        "why_matters": "Thyroid imbalance is a common cause of fatigue, weight changes, and metabolic issues.",
        "recommendation": "Add a Thyroid Profile (TSH, T3, T4) for better insights into your metabolism."
      };
    case "hormones":
      return {
        "not_tested": "Hormonal balance tests are not part of this report.",
        "why_matters": "Hormones regulate fertility, reproduction, and overall metabolism.",
        "recommendation": "Add tests like Testosterone, Estrogen, Progesterone, LH, and FSH for a deeper assessment."
      };
    case "blood":
      return {
        "not_tested": "Basic blood health parameters were not included in your report.",
        "why_matters": "These tests check for anemia, infection, and overall immunity.",
        "recommendation": "Add a Complete Blood Count (CBC) and Hemoglobin test to assess your blood profile."
      };
    case "immunity":
      return {
        "not_tested": "Immunity-related markers are not covered in your current report.",
        "why_matters": "These tests help assess your immune system strength and response capabilities.",
        "recommendation": "Consider adding Vitamin D, Complete Blood Count, and specific antibody tests for immune health assessment."
      };
    case "bones":
      return {
        "not_tested": "Bone strength parameters are missing from your report.",
        "why_matters": "These tests detect Vitamin D and Calcium deficiency, which affect bone health and fracture risk.",
        "recommendation": "Consider adding Vitamin D, Calcium, and Bone Density (DEXA) tests to check your bone health."
      };
    case "joints":
      return {
        "not_tested": "Joint health markers were not included in your report.",
        "why_matters": "These tests help detect arthritis, inflammation, and uric acid buildup.",
        "recommendation": "Add Uric Acid, RA Factor, ESR, and CRP to track joint and inflammation health."
      };
    case "nutrition":
      return {
        "not_tested": "Nutritional status markers are missing in this report.",
        "why_matters": "These tests help assess your dietary adequacy and nutrient absorption.",
        "recommendation": "Add Vitamin B12, Vitamin D, Iron Studies, and basic metabolic panel for nutritional assessment."
      };
    case "digestive":
      return {
        "not_tested": "Digestive health parameters were not tested in your report.",
        "why_matters": "These tests help detect digestive disorders, malabsorption, and gut health issues.",
        "recommendation": "Consider adding stool tests, inflammatory markers, and basic metabolic panel for digestive health."
      };
    case "lifestyle":
      return {
        "not_tested": "Lifestyle-related health markers are not included in your report.",
        "why_matters": "These tests help assess the impact of lifestyle choices on your overall health.",
        "recommendation": "Add Lipid Profile, Liver Function Tests, and Blood Sugar tests to monitor lifestyle health impacts."
      };
    case "vitals":
      return {
        "not_tested": "Vital signs like SPO2, BP, and Heart Rate are not part of this report.",
        "why_matters": "Vitals reflect your immediate well-being and day-to-day health status.",
        "recommendation": "Track SPO2, Heart Rate, and Blood Pressure regularly for better health monitoring."
      };
    default:
      return {
        "not_tested": "Your report does not include $category-related tests.",
        "why_matters": "These tests provide important insights into your health and help detect potential issues early.",
        "recommendation": "Consider adding relevant tests for a more complete view of your $category health."
      };
  }
}

  // 🔹 Generate historical timeline for the parameter
  Widget _buildHistoricalTimeline(dynamic item, Color primaryColor) {
    final prevHistory = item["prev_history"] as List?;
    
    if (prevHistory == null || prevHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text(
          "No historical data available",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Create timeline data including current value
    final timelineData = [
      ...prevHistory.map((history) => {
        'value': history["value"],
        'unit': history["unit"] ?? item["unit"],
        'date': _formatDate(history["created_at"]),
        'status': history["status"],
        'reference_range': history["reference_range"] ?? item["reference_range"],
      }),
      {
        'value': item["value"],
        'unit': item["unit"],
        'date': 'Current',
        'status': item["status"],
        'reference_range': item["reference_range"],
      }
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Historical Timeline",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...timelineData.map((data) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['date'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "${data['value']} ${data['unit']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Range: ${data['reference_range'] ?? '-'}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(data['status'], primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(data['status'], primaryColor).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    data['status'] ?? "Unknown",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(data['status'], primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getCohortGradientColors(cohort);
    final primaryColor = _getCohortPrimaryColor(cohort);
    final isNotTested = cohort.toLowerCase() == "not_tested";
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Gradient Header
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: double.infinity,
                height: 65,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.arrow_back,
                              color: primaryColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            if (isNotTested) ...[
              // Special layout for Not Tested categories
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cohort TEXT
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Not Tested",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                      
                      // Not Tested Information
                      _buildInfoCard(
                        icon: Icons.info_outline,
                        title: "Not Tested",
                        content: _getNotTestedInfo(category)["not_tested"]!,
                        color: primaryColor,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Why It Matters
                      _buildInfoCard(
                        icon: Icons.help_outline,
                        title: "Why It Matters",
                        content: _getNotTestedInfo(category)["why_matters"]!,
                        color: primaryColor,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Recommendation
                      _buildInfoCard(
                        icon: Icons.lightbulb_outline,
                        title: "Recommendation",
                        content: _getNotTestedInfo(category)["recommendation"]!,
                        color: primaryColor,
                        isRecommendation: true,
                      ),
                    ],
                  ),
                ),
              )
            ] else ...[
              if (insight != null && insight!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  insight!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),

            // 🔹 Cohort TEXT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  cohort.toLowerCase() == "high_risk"
                      ? "High Risk"
                      : cohort.toLowerCase() == "early_signs"
                          ? "Early Signs"
                          : "All Good",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ),

            // 🔹 Cards + Lifestyle Tips
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: values.isEmpty
                    ? const Center(
                        child: Text(
                          "No data available for this category",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: values.length + 1,
                        itemBuilder: (context, index) {
                          if (index < values.length) {
                            final item = values[index];
                            final status = item["status"] ?? "unknown";
                            final hasPreviousData = (item["prev_history"] as List?)?.isNotEmpty ?? false;
                            final trendInfo = hasPreviousData ? _getTrendInfo(item) : null;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  hoverColor: Colors.transparent, 
                                ),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  leading: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: _getStatusColor(status, primaryColor)
                                        .withOpacity(0.15),
                                    child: Icon(
                                      _getStatusIcon(status),
                                      color: _getStatusColor(status, primaryColor),
                                      size: 26,
                                    ),
                                  ),
                                  title: Text(
                                    item["parameter"] ?? "",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        "Value: ${item["value"]} ${item["unit"] ?? ""}",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        "Range: ${item["reference_range"] ?? "-"}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      // 🔹 Trend indicator
                                      if (hasPreviousData && trendInfo != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Row(
                                            children: [
                                              Icon(
                                                trendInfo['icon'],
                                                size: 16,
                                                color: trendInfo['color'],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                trendInfo['text'],
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: trendInfo['color'],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: const BorderRadius.vertical(
                                          bottom: Radius.circular(18),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // 🔹 Trend Chart
                                          if (hasPreviousData)
                                            _buildTrendChart(item, primaryColor),
                                          
                                          // 🔹 Historical Timeline
                                          if (hasPreviousData)
                                            _buildHistoricalTimeline(item, primaryColor),
                                            
                                            const SizedBox(height: 10),
                                          
                                          if (item["description"] != null) ...[
                                            Row(
                                              children: [
                                                Icon(Icons.notes,
                                                    size: 18,
                                                    color: primaryColor),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    item["description"],
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black87),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                          if (item["impact"] != null) ...[
                                            Row(
                                              children: [
                                                Icon(Icons.warning_amber,
                                                    size: 18,
                                                    color: primaryColor),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    item["impact"],
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: primaryColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                          if (item["interpretation"] != null)
                                            Row(
                                              children: [
                                                Icon(Icons.search,
                                                    size: 18,
                                                    color: primaryColor),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    item["interpretation"],
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontStyle: FontStyle.italic,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          } else {
                            // 🔹 Lifestyle Tips Block
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.eco,
                                      color: primaryColor, size: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Lifestyle Recommendations:",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          recommendation!,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
              ),
            ),
          ],
        ]),
      ),
    );
  }

   Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    bool isRecommendation = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: isRecommendation ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          // if (isRecommendation) ...[
          //   const SizedBox(height: 8),
          //   const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
          // ],
        ],
      ),
    );
  }
}