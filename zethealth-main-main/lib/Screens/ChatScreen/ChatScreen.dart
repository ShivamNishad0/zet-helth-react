import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/UploadedPdfModel.dart';
import 'package:zet_health/Screens/ChatScreen/ChatScreenController.dart';

import '../../CommonWidget/CustomAppbar.dart';
import '../../CommonWidget/CustomWidgets.dart';
import '../../Helper/AssetHelper.dart';
import '../../Helper/ColorHelper.dart';
import '../../Helper/StyleHelper.dart';

class ChatScreen extends StatefulWidget {
  final UploadedPdfModel pdfModel;
  final String? sessionId;
  
  const ChatScreen({super.key, required this.pdfModel, this.sessionId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  ChatScreenController chatController = Get.put(ChatScreenController());
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    chatController.initializeChat(widget.pdfModel, widget.sessionId);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
    
    // Listen to messages changes and scroll to bottom when messages are loaded
    ever(chatController.messages, (_) {
      if (chatController.messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _scrollToBottom();
          });
        });
      }
    });
    
    // Also listen to loading state changes to scroll when chat history is loaded
    ever(chatController.isLoading, (isLoading) {
      if (!isLoading && chatController.messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 200), () {
            _scrollToBottom();
          });
        });
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (scrollController.hasClients && scrollController.position.maxScrollExtent > 0) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleBackNavigation() {
    // Navigate back and refresh the chat sessions screen
    Get.back(result: {'shouldRefresh': true});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBackNavigation();
        return false; // Prevent default back navigation since we handle it manually
      },
      child: Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        onTap: _handleBackNavigation,
        title: Column(
          children: [
            Text('Zenie Health Assistant', style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            )),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 15.w),
            child: CustomSquareButton(
              backgroundColor: Colors.white,
              icon: searchDotsIcon,
              shadow: [
                BoxShadow(
                  color: Color(0xFF000000).withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                )
              ],
              onTap: () {
                _showChatOptions();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: Obx(() => chatController.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    itemCount: chatController.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatController.messages[index];
                      // Scroll to bottom after the last item is built
                      if (index == chatController.messages.length - 1) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Future.delayed(const Duration(milliseconds: 50), () {
                            _scrollToBottom();
                          });
                        });
                      }
                      return _buildAnimatedMessageBubble(message, index);
                    },
                  )),
          ),
          
          // Typing Indicator
          Obx(() => chatController.isTyping.value
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
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
                        'Zenie is analyzing your report...',
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
          
          // Message Input
          Container(
            padding: EdgeInsets.all(20.w),
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
              child: Row(
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
                        controller: messageController,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xFF1F2937),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: 'Ask about your medical report...',
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
                          _sendMessage();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: _sendMessage,
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
            ),
          ),
      ]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor.withOpacity(0.1), Color(0xFF2EAF67).withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: FaIcon(
                FontAwesomeIcons.robot,
                size: 48.sp,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'AI Medical Assistant',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                'Your intelligent health companion. Ask me anything about your medical report - I can explain results, identify concerns, and guide you through next steps.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20.h),
            _buildSuggestedQuestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    final suggestions = [
      'Explain my test results',
      'What do these values mean?',
      'Any concerning findings?',
      'Recommended next steps?',
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
                messageController.text = suggestion;
                _sendMessage();
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

  Widget _buildAnimatedMessageBubble(ChatMessage message, int index) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(message.isUser ? 0.3 : -0.3, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      )),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeIn,
        )),
        child: _buildMessageBubble(message),
      ),
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
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
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
                        maxWidth: MediaQuery.of(context).size.width * 0.85, // Increased to 80% since no left icon
                      ),
                      margin: EdgeInsets.only(top: 8.h),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
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
                              // Add table styling for better appearance
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

  void _sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    chatController.sendMessage(text);
    messageController.clear();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _showChatOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF000000).withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Chat Options',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 24.h),
            _buildOptionTile(
              icon: FontAwesomeIcons.trash,
              title: 'Clear Chat',
              subtitle: 'Delete all messages',
              onTap: () {
                Get.back();
                _showClearChatDialog();
              },
            ),
            _buildOptionTile(
              icon: FontAwesomeIcons.download,
              title: 'Export Chat',
              subtitle: 'Save conversation as PDF',
              onTap: () {
                Get.back();
                chatController.exportChat();
              },
            ),
            _buildOptionTile(
              icon: FontAwesomeIcons.share,
              title: 'Share Chat',
              subtitle: 'Share with your doctor',
              onTap: () {
                Get.back();
                chatController.shareChat();
              },
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: FaIcon(
                icon,
                size: 20.sp,
                color: Color(0xFF6B7280),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    )
                  ),
                  Text(
                    subtitle, 
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Color(0xFF6B7280),
                    )
                  ),
                ],
              ),
            ),
            FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 16.sp,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearChatDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: Colors.white,
        title: Text(
          'Clear Chat', 
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          )
        ),
        content: Text(
          'Are you sure you want to delete all messages? This action cannot be undone.',
          style: TextStyle(
            fontSize: 14.sp,
            color: Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel', 
              style: TextStyle(
                fontSize: 14.sp,
                color: Color(0xFF6B7280),
              )
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              chatController.clearChat();
            },
            child: Text(
              'Clear', 
              style: TextStyle(
                fontSize: 14.sp,
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              )
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String timestamp;
  final String? id;
  final String? createdAt;
  final List<dynamic>? sources;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.id,
    this.createdAt,
    this.sources,
  });
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