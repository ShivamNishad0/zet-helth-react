import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Helper/ColorHelper.dart';
import 'package:zet_health/CommonWidget/CustomLoadingIndicator.dart';
import 'package:zet_health/Screens/DrawerView/NavigationDrawerController.dart';
import 'package:zet_health/Screens/InsightScreen/InsightScreenController.dart';
import 'package:zet_health/Screens/InsightScreen/common_widgets/CircularHealthScore.dart';
import 'package:zet_health/Screens/InsightScreen/common_widgets/HealthCategories.dart';
import 'package:zet_health/Screens/InsightScreen/common_widgets/HealthSummary.dart';
import 'package:zet_health/Screens/InsightScreen/common_widgets/No_Insights_Widget.dart';
import 'package:zet_health/Screens/InsightScreen/common_widgets/ReportsView.dart';
import 'package:zet_health/Screens/InsightScreen/common_widgets/Switch.dart';
import 'package:zet_health/Screens/InsightScreen/common_widgets/cohort_counts.dart';
import 'package:zet_health/Screens/InsightScreen/common_widgets/FAQSection.dart';
import 'package:zet_health/Screens/InsightScreen/common_widgets/recommendations_section.dart';
import 'package:zet_health/services/job_status_service.dart';

import '../../CommonWidget/CustomWidgets.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _detailsKey = GlobalKey();
  final Insightscreencontroller controller = Get.put(Insightscreencontroller());
  final NavigationDrawerController navigationDrawerController =
      Get.find<NavigationDrawerController>();
  final JobStatusService jobStatusService = Get.find<JobStatusService>(); // Add this
  
  bool _showDetails = false;
  bool _isReportsSelected = false;
  Function? userModelListen;

  @override
  void initState() {
    super.initState();
    
    // Register refresh callback with job status service
    jobStatusService.addRefreshCallback(_refreshInsights);
    
    if (navigationDrawerController.isLogin.value) {
      print("🔑 isLogin: ${navigationDrawerController.isLogin.value}");
      controller.fetchInsights();

      userModelListen = AppConstants()
          .getStorage
          .listenKey(AppConstants.USER_DETAIL, (value) {
        setState(() {
          controller.userModel.value = AppConstants().getUserDetails();
        });
      });
    }
  }

  @override
  void dispose() {
    // Remove refresh callback when screen is disposed
    jobStatusService.removeRefreshCallback(_refreshInsights);
    userModelListen?.call();
    super.dispose();
  }

  // Refresh method that will be called when job completes
  void _refreshInsights() {
    print('🔄 Refreshing insights due to job completion');
    if (mounted) {
      setState(() {
        // Force refresh the insights
        controller.fetchInsights(forceRefresh: true);
      });
    }
  }

  void onToggle() {}

  // ✅ Toggle details and scroll smoothly
  void _scrollToDetails() {
    setState(() => _showDetails = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_detailsKey.currentContext != null) {
        Scrollable.ensureVisible(
          _detailsKey.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _downloadReport() {
    final NavigationDrawerController navigationDrawerController =
        Get.find<NavigationDrawerController>();
    navigationDrawerController.pageIndex.value = 3;

    if (mounted) {
      setState(() {
        _isReportsSelected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          // Show processing indicator if job is in progress
          if (jobStatusService.isProcessing) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomLoadingIndicator(),
                SizedBox(height: 20),
                Text(
                  'Processing your medical report...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  jobStatusService.statusDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }

          if (!navigationDrawerController.isLogin.value) {
            return NoLoginWidget(onLoginSuccess: () {
              setState(() {
                controller.fetchInsights();
              });
            });
          }

          final user = controller.userModel.value;
          final insights = controller.insights.value;

          if (insights == null) {
            return const Center(child: CustomLoadingIndicator());
          } else if (insights.cohorts == null) {
            return NoInsightsWidget(onRefresh: _refreshInsights); // Pass refresh callback
          }

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'BETA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Text(
                            "Hi, ",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              user.userName ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ReportsInsightsSwitch(
                      isReportsSelected: _isReportsSelected,
                      onToggle: (value) {
                        setState(() {
                          _isReportsSelected = value;
                        });
                        onToggle();
                      },
                    ),
                  ],
                ),
                SizedBox(height: _isReportsSelected ? 10 : 40),
                if (_isReportsSelected)
                  ReportsView(report: insights, onDownload: _downloadReport)
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularHealthScore(
                        score: (insights.latestCompositeScore ?? 0).toDouble(),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Your Health Score",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (insights.healthSummary != null &&
                          insights.healthSummary!.isNotEmpty)
                        HealthSummary(summary: insights.healthSummary!),
                      const SizedBox(height: 40),
                      CohortCounts(counts: insights.counts),
                      const SizedBox(height: 26),
                      HealthCategories(cohorts: insights.cohorts),
                      const SizedBox(height: 30),
                      RecommendationsSection(
                          recommendations:
                              insights.personalizedRecommendations),
                      const SizedBox(height: 30),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.help_outline,
                              color: Colors.grey,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Have any query? Scroll to FAQ section.",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      FAQSection(),
                    ],
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}