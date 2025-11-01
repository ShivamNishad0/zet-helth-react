import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/UploadedPdfModel.dart';
import 'package:zet_health/Screens/ChatScreen/ChatSessionsController.dart';
import 'package:zet_health/Screens/ChatScreen/ChatScreen.dart';

import '../../CommonWidget/CustomAppbar.dart';
import '../../CommonWidget/CustomWidgets.dart';
import '../../Helper/AssetHelper.dart';
import '../../Helper/ColorHelper.dart';
import '../../Helper/StyleHelper.dart';

class ChatSessionsScreen extends StatefulWidget {
  final UploadedPdfModel pdfModel;
  
  const ChatSessionsScreen({super.key, required this.pdfModel});

  @override
  State<ChatSessionsScreen> createState() => _ChatSessionsScreenState();
}

class _ChatSessionsScreenState extends State<ChatSessionsScreen> with WidgetsBindingObserver {
  late ChatSessionsController controller;

  String _stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'#+\s*'), '') // Remove headers (# ## ###)
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1') // Remove bold (**text**)
        .replaceAll(RegExp(r'\*([^*]+)\*'), r'$1') // Remove italic (*text*)
        .replaceAll(RegExp(r'__([^_]+)__'), r'$1') // Remove bold (__text__)
        .replaceAll(RegExp(r'_([^_]+)_'), r'$1') // Remove italic (_text_)
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1') // Remove inline code (`text`)
        .replaceAll(RegExp(r'```[^`]*```'), '') // Remove code blocks
        .replaceAll(RegExp(r'>\s*'), '') // Remove blockquotes
        .trim();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize controller with a unique tag to avoid conflicts
    controller = Get.put(ChatSessionsController(), tag: 'chat_sessions_${widget.pdfModel.reportId}');
    controller.loadChatSessions(widget.pdfModel);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Clean up the controller
    try {
      Get.delete<ChatSessionsController>(tag: 'chat_sessions_${widget.pdfModel.reportId}');
    } catch (e) {
      // Ignore disposal errors
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh sessions when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      controller.refreshSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press safely
        return true; // Allow normal back navigation
      },
      child: Scaffold(
      backgroundColor: pageBgColor,
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        title: Column(
          children: [
            Text('Chat Sessions', style: semiBoldBlack_16),
          ],
        ),
        leading: CustomSquareButton(
          backgroundColor: whiteColor,
          leftMargin: 15.w,
          icon: backArrow,
          shadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            )
          ],
          onTap: () {
            _safeNavigateBack();
          },
        ),
      ),
      body: Column(
        children: [
        // Chat Sessions List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Loading chat sessions...',
                        style: regularGray_14,
                      ),
                    ],
                  ),
                );
              }
              
              if (controller.chatSessions.isEmpty) {
                return _buildEmptyState();
              }
              
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                itemCount: controller.chatSessions.length,
                itemBuilder: (context, index) {
                  final session = controller.chatSessions[index];
                  return _buildSessionCard(session, index);
                },
              );
            }),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30.w),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: FaIcon(
              FontAwesomeIcons.comments,
              size: 50.sp,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'No Chat Sessions Yet',
            style: semiBoldBlack_18,
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Start your first conversation with AI about this medical report.',
              style: regularGray_14,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 30.h),
          ElevatedButton.icon(
            onPressed: _startNewChat,
            icon: FaIcon(
              FontAwesomeIcons.plus,
              size: 16.sp,
              color: whiteColor,
            ),
            label: Text(
              'Start New Chat',
              style: semiBoldWhite_14,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: whiteColor,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(ChatSession session, int index) {
    return GestureDetector(
      onTap: () {
        _openChatSession(session);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: borderColor2),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),
            Text(
              _stripMarkdown(session.latestMessage).length > 150 
                  ? '${_stripMarkdown(session.latestMessage).substring(0, 150)}...'
                  : _stripMarkdown(session.latestMessage),
              style: regularBlack_12.copyWith(fontStyle: FontStyle.italic),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
             Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.comments,
                    size: 16.sp,
                    color: primaryColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${session.messageCount} messages',
                        style: regularGray_11,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      session.formattedLastActivity,
                      style: regularGray_11,
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: session.latestMessageType == 'ai' 
                            ? primaryColor.withOpacity(0.1)
                            : greyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        session.latestMessageType == 'ai' ? 'AI' : 'You',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: session.latestMessageType == 'ai' 
                              ? primaryColor
                              : greyColor2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _safeNavigateBack() {
    // Use Flutter's native navigation only
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _startNewChat() async {
    // Navigate to ChatScreen with new session
    final result = await Get.to(
      () => ChatScreen(
        pdfModel: widget.pdfModel,
        sessionId: null, // null means new session
      ),
      transition: Transition.rightToLeft,
    );
    
    // Check if we should refresh the sessions
    if (result != null && result['shouldRefresh'] == true) {
      controller.refreshSessions();
    }
  }

  void _openChatSession(ChatSession session) async {
    // Navigate to ChatScreen with existing session
    final result = await Get.to(
      () => ChatScreen(
        pdfModel: widget.pdfModel,
        sessionId: session.sessionId,
      ),
      transition: Transition.rightToLeft,
    );
    
    // Check if we should refresh the sessions
    if (result != null && result['shouldRefresh'] == true) {
      controller.refreshSessions();
    }
  }
}

class ChatSession {
  final String sessionId;
  final String reportId;
  final String lastActivity;
  final String latestMessage;
  final String latestMessageType;
  final int messageCount;

  ChatSession({
    required this.sessionId,
    required this.reportId,
    required this.lastActivity,
    required this.latestMessage,
    required this.latestMessageType,
    required this.messageCount,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      sessionId: (json['session_id'] ?? '').toString(),
      reportId: (json['report_id'] ?? '').toString(),
      lastActivity: (json['last_activity'] ?? '').toString(),
      latestMessage: (json['latest_message'] ?? '').toString(),
      latestMessageType: (json['latest_message_type'] ?? '').toString(),
      messageCount: json['message_count'] as int? ?? 0,
    );
  }

  String get formattedLastActivity {
    try {
      final dateTime = DateTime.parse(lastActivity);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}