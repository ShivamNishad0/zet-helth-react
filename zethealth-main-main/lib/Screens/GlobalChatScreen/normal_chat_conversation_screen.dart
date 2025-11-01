import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:zet_health/Screens/GlobalChatScreen/chat_history_screen.dart';
import '../../CommonWidget/CustomAppbar.dart';
import '../../Helper/ColorHelper.dart';
import '../../Helper/StyleHelper.dart';
import 'normal_chat_conversation_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class NormalChatConversationScreen extends StatefulWidget {
  const NormalChatConversationScreen({super.key});

  @override
  State<NormalChatConversationScreen> createState() => _NormalChatConversationScreenState();
}

class _NormalChatConversationScreenState extends State<NormalChatConversationScreen> {
  late final NormalChatConversationController controller;
  late final TextEditingController textController;
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(NormalChatConversationController());
    textController = TextEditingController();
    scrollController = ScrollController();
    
    // Listen to messages changes and scroll to bottom
    ever(controller.messages, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });
    
    // Also scroll when typing indicator changes
    ever(controller.isTyping, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });
    
    // Initial scroll to bottom when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _scrollToBottom();
      });
    });
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        backgroundColor: primaryColor,
        title: Row(
  mainAxisSize: MainAxisSize.min, // so it doesn't take full width
  children: [
    Text(
      'Zenie AI Chat',
      style: semiBoldWhite_16,
    ),
    const SizedBox(width: 6), // 2px space
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange, // background color for label
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Beta',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),
        actions: [
          IconButton(
            onPressed: () {
              controller.startNewChat();
            },
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'New Chat',
          ),
          IconButton(
            onPressed: () {
              // Refresh chat history before opening the screen
              controller.fetchChatHistory();
              Get.to(() => const ChatHistoryScreen());
            },
            icon: const Icon(Icons.menu, color: Colors.white),
            tooltip: 'Chat History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Top section with Lottie animation - only show when no messages
          Obx(() {
            if (controller.messages.isEmpty) {
              return Container(
                height: 150.h,
                width: double.infinity,
                child: Center(
                  child: Lottie.asset(
                    'assets/lottiechat.json', // You can change this to any lottie file you prefer
                    width: 200.w,
                    height: 200.h,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            }
            return const SizedBox.shrink(); // Hide when there are messages
          }),
          
          // Chat messages area
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: Obx(() {
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
                
                if (controller.messages.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Try asking about:',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // Replaced Expanded + ListView.builder with Column to prevent scrolling
                        Column(
                          children: List.generate(
                            controller.recommendationMessages.length,
                            (index) {
                              return GestureDetector(
                                onTap: () {
                                  controller.selectRecommendation(controller.recommendationMessages[index]);
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 6.h),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: whiteColor.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.lightbulb_outline,
                                        color: primaryColor.withOpacity(0.7),
                                        size: 16.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          controller.recommendationMessages[index],
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.grey[400],
                                        size: 12.sp,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(text: 'By chatting you agree to our '),
                                TextSpan(
                                  text: 'terms and conditions',
                                  style: TextStyle(
                                    color: primaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      const url = 'https://zethealth.com/terms-and-conditions/';
                                      if (await canLaunchUrl(Uri.parse(url))) {
                                        await launchUrl(Uri.parse(url));
                                      }
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          final message = controller.messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
                    ),
                    
                    // Typing Indicator
                    Obx(() => controller.isTyping.value
                        ? Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [primaryColor, Color(0xFF2EAF67)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: FaIcon(
                                    FontAwesomeIcons.robot,
                                    size: 18.sp,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'AI is analyzing your question...',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink()),
                    
                    // PDF Uploader
                    Obx(() => controller.showPdfUploader.value
                        ? _buildPdfUploader()
                        : const SizedBox.shrink()),
                  ],
                );
              }),
            ),
          ),
          // Bottom input section
          Container(
            padding: EdgeInsets.fromLTRB(12.w, 16.w, 12.w, 8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF000000).withOpacity(0.05),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(25.r),
                            border: Border.all(
                              color: Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: textController,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Color(0xFF1F2937),
                              fontWeight: FontWeight.w400,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.newline,
                            onTapOutside: (_) => FocusScope.of(context).unfocus(),
                            decoration: InputDecoration(
                              hintText: 'Ask Zenie anything...',
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 12.h,
                              ),
                            ),
                            onSubmitted: (value) {
                              if (textController.text.trim().isNotEmpty) {
                                controller.sendMessage(textController.text);
                                textController.clear();
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: () {
                          if (textController.text.trim().isNotEmpty) {
                            controller.sendMessage(textController.text);
                            textController.clear();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, Color(0xFF2EAF67)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25.r),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.paperPlane,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: () {
                      Get.bottomSheet(
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.r),
                              topRight: Radius.circular(20.r),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About Zenie',
                                style: semiBoldBlack_18,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Zenie is your intelligent health companion, designed to provide you with instant, reliable, and personalized health information. Whether you have questions about symptoms, need to understand your lab reports, or want to learn more about a specific medical condition, Zenie is here to help.',
                                style: regularBlack_14.copyWith(height: 1.5),
                              ),
                              SizedBox(height: 20.h),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text('Close', style: TextStyle(color: primaryColor)),
                                ),
                              )
                            ],
                          ),
                        ),
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: primaryColor,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Know more about Zenie',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSuggestedQuestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    final suggestions = [
      'Ask about symptoms and health concerns',
      'Get information about medical tests',
      'Learn about healthy lifestyle tips',
      'Understand medication side effects',
    ];

    return Column(
      children: [
        Text(
          'Quick Questions',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: suggestions.map((suggestion) {
            return GestureDetector(
              onTap: () {
                final controller = Get.find<NormalChatConversationController>();
                controller.selectRecommendation(suggestion);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  suggestion,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Show label with icon above AI messages
          if (!isUser) ...[
            Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, Color(0xFF2EAF67)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.robot,
                      size: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Zenie',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Make AI messages take less width (more to the left)
              isUser 
                  ? Flexible(
                      child: Container(
                        margin: EdgeInsets.only(top: 8.h),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, Color(0xFF2EAF67)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.r),
                            topRight: Radius.circular(20.r),
                            bottomLeft: Radius.circular(20.r),
                            bottomRight: Radius.circular(4.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.text,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              message.timestamp,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      constraints: BoxConstraints(
                        maxWidth: Get.width * 0.85,
                      ),
                      margin: EdgeInsets.only(top: 8.h),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                          bottomLeft: Radius.circular(4.r),
                          bottomRight: Radius.circular(20.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF000000).withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MarkdownBody(
                            data: message.text,
                            builders: {
                              'table': CustomTableBuilder(),
                            },
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                fontSize: 14.sp,
                                color: Color(0xFF1F2937),
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                              h1: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                              h2: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                              h3: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                              strong: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                              em: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF1F2937),
                              ),
                              listBullet: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF1F2937),
                              ),
                              code: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12.sp,
                                backgroundColor: Color(0xFFF3F4F6),
                                color: Color(0xFF1F2937),
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: Color(0xFFE5E7EB),
                                  width: 1,
                                ),
                              ),
                              tableHead: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                              tableBody: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF1F2937),
                              ),
                              tableBorder: TableBorder.all(
                                color: Color(0xFFE5E7EB),
                                width: 1,
                              ),
                              tableHeadAlign: TextAlign.left,
                              tableColumnWidth: const IntrinsicColumnWidth(),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            message.timestamp,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
              if (isUser) ...[
                SizedBox(width: 12.w),
                Container(
                  margin: EdgeInsets.only(top: 8.h),
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF000000).withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.user,
                    size: 18.sp,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPdfUploader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, Color(0xFF2EAF67)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: FaIcon(
                  FontAwesomeIcons.filePdf,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medical Report Required',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Please upload your medical report to continue',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Info box
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.circleInfo,
                  color: Colors.blue[600],
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Supported format: PDF only • Max file size: 10MB',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Upload button
          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.isUploadingPdf.value 
                  ? null 
                  : () => controller.pickAndUploadPdf(),
              icon: controller.isUploadingPdf.value
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : FaIcon(
                      FontAwesomeIcons.upload,
                      size: 16.sp,
                      color: Colors.white,
                    ),
              label: Text(
                controller.isUploadingPdf.value 
                    ? 'Uploading...' 
                    : 'Choose PDF File',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 2,
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class CustomTableBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'table') {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _buildTable(element, preferredStyle),
      );
    }
    return null;
  }

  Widget _buildTable(md.Element element, TextStyle? preferredStyle) {
    final rows = <TableRow>[];
    int rowIndex = 0;

    for (final child in element.children ?? <md.Node>[]) {
      if (child is md.Element && (child.tag == 'thead' || child.tag == 'tbody')) {
        for (final row in child.children ?? <md.Node>[]) {
          if (row is md.Element && row.tag == 'tr') {
            final cells = <Widget>[];
            final bool isHeader = child.tag == 'thead';
            final Color rowColor = rowIndex % 2 == 0 ? Colors.white : Color(0xFFF8F9FA);

            for (final cell in row.children ?? <md.Node>[]) {
              if (cell is md.Element && (cell.tag == 'th' || cell.tag == 'td')) {
                cells.add(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    color: isHeader ? Color(0xFFF3F4F6) : rowColor,
                    child: Text(
                      cell.textContent,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: isHeader ? FontWeight.w600 : FontWeight.w400,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                );
              }
            }
            if (cells.isNotEmpty) {
              rows.add(TableRow(children: cells));
              rowIndex++;
            }
          }
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Color(0xFFE5E7EB),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        color: Colors.white,
      ),
      child: Table(
        border: TableBorder.all(
          color: Color(0xFFE5E7EB),
          width: 1,
          borderRadius: BorderRadius.circular(12.r),
        ),
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: IntrinsicColumnWidth(),
          2: IntrinsicColumnWidth(),
          3: IntrinsicColumnWidth(),
          4: IntrinsicColumnWidth(),
        },
        children: rows,
      ),
    );
  }
}