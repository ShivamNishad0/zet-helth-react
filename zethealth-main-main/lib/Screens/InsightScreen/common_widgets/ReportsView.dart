import 'package:flutter/material.dart';
import 'package:zet_health/Helper/ColorHelper.dart';
import 'package:zet_health/Models/CategorizeValueModel.dart';

class ReportsView extends StatelessWidget {
  final CategorizeValueResponse? report;
  final VoidCallback onDownload;

  const ReportsView({super.key, this.report, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return const Center(
        child: Text("No reports available"),
      );
    }

    final cohorts = report!.cohorts ?? {};

    // Collect all parameters from all categories across cohorts with their status
    final List<Map<String, dynamic>> allParameters = [];

    // Helper function to add parameters from all cohorts
    void addParametersFromCohorts() {
      for (final cohortEntry in cohorts.entries) {
        final cohortKey = cohortEntry.key;
        final cohortData = cohortEntry.value as Map<String, dynamic>;
        final categories = cohortData["categories"] as Map<String, dynamic>;
        
        for (final categoryData in categories.values) {
          final params = (categoryData as Map<String, dynamic>)["parameters"] as List<dynamic>;
          for (final param in params) {
            allParameters.add({
              ...param as Map<String, dynamic>,
              "cohort": cohortKey,
            });
          }
        }
      }
    }

    addParametersFromCohorts();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.download, size: 18),
              label: const Text(
                "Download Report",
                style: TextStyle(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          
          ...allParameters.map((param) {
            // Determine status color and text based on parameter's status
            final status = (param["status"] as String).toLowerCase();
            late final Color statusColor;
            late final String statusText;
            late final IconData trendIcon;

            if (status.contains("high") || status.contains("risk") || status.contains("abnormal")) {
              statusColor = Colors.red.shade700;
              statusText = "High Risk";
              trendIcon = Icons.trending_down;
            } else if (status.contains("early") || status.contains("warning") || status.contains("borderline")) {
              statusColor = Colors.orange.shade800;
              statusText = "Early Signs";
              trendIcon = Icons.trending_flat;
            } else if (status.contains("normal") || status.contains("good") || status.contains("optimal")) {
              statusColor = Colors.green.shade700;
              statusText = "Good";
              trendIcon = Icons.trending_up;
            } else {
              // Default case for unknown status
              statusColor = Colors.grey;
              statusText = param["status"] ?? "Unknown";
              trendIcon = Icons.trending_neutral;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    param["parameter"],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  "${param["value"]}",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${param["unit"]}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Reference ${param["reference_range"]}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                            if (param["interpretation"] != null && param["interpretation"].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  param["interpretation"],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              trendIcon,
                              size: 24,
                              color: statusColor,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: statusColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}