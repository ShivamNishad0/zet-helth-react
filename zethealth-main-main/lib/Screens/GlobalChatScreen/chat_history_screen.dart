import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../CommonWidget/CustomAppbar.dart';
import '../../Helper/ColorHelper.dart';
import '../../Helper/StyleHelper.dart';
import 'normal_chat_conversation_controller.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NormalChatConversationController>();
    
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        backgroundColor: primaryColor,
        title: Text(
          'Chat History',
          style: semiBoldWhite_16,
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingHistory.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Loading chat history...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.chatSessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64.sp,
                  color: Color(0xFF9CA3AF),
                ),
                SizedBox(height: 16.h),
                Text(
                  'No chat history found',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Start a conversation to see your chat history here.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.chatSessions.length,
          itemBuilder: (context, index) {
            final session = controller.chatSessions[index];
            return _buildChatSessionTile(session, controller);
          },
        );
      }),
    );
  }

  Widget _buildChatSessionTile(ChatSession session, NormalChatConversationController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF000000).withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor.withOpacity(0.1), Color(0xFF2EAF67).withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.chat_bubble_outline,
            color: primaryColor,
            size: 20.sp,
          ),
        ),
        title: Text(
          _cleanAndTruncateMessage(session.latestMessage),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            color: Color(0xFF4B5563),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Text(
              '${session.messageCount} messages',
              style: TextStyle(
                fontSize: 12.sp,
                color: Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              _formatDate(session.lastActivity),
              style: TextStyle(
                fontSize: 11.sp,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Color(0xFF9CA3AF),
        ),
        onTap: () {
          // Load the selected session and go back to chat screen
          controller.loadSessionMessages(session.sessionId);
          Get.back();
        },
      ),
    );
  }

  String _cleanAndTruncateMessage(String message) {
    // Remove markdown syntax
    String cleanedMessage = message
        // Remove headers (##, ###, etc.)
        .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '')
        // Remove bold (**text** or __text__)
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
        .replaceAll(RegExp(r'__(.*?)__'), r'$1')
        // Remove italic (*text* or _text_)
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')
        .replaceAll(RegExp(r'_(.*?)_'), r'$1')
        // Remove links [text](url)
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1')
        // Remove code blocks ```
        .replaceAll(RegExp(r'```[^`]*```'), '')
        // Remove inline code `text`
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1')
        // Remove bullet points (*, -, +)
        .replaceAll(RegExp(r'^[\s]*[-\*\+]\s+', multiLine: true), '')
        // Remove numbered lists
        .replaceAll(RegExp(r'^[\s]*\d+\.\s+', multiLine: true), '')
        // Remove extra whitespace and newlines
        .replaceAll(RegExp(r'\n+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    
    if (cleanedMessage.length <= 100) return cleanedMessage;
    return '${cleanedMessage.substring(0, 100)}...';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today ${DateFormat('HH:mm').format(date)}';
      } else if (difference.inDays == 1) {
        return 'Yesterday ${DateFormat('HH:mm').format(date)}';
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE HH:mm').format(date);
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }
}
