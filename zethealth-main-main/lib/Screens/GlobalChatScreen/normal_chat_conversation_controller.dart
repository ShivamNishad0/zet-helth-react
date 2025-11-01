import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../Helper/AppConstants.dart';
import '../../Models/chat_response_model.dart';
import '../../Network/PdfApiHelper.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String timestamp;
  final String? id;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.id,
  });
}

class ChatSession {
  final String sessionId;
  final String? reportId;
  final String lastActivity;
  final String latestMessage;
  final String latestMessageType;
  final int messageCount;

  ChatSession({
    required this.sessionId,
    this.reportId,
    required this.lastActivity,
    required this.latestMessage,
    required this.latestMessageType,
    required this.messageCount,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      sessionId: json['session_id'] ?? '',
      reportId: json['report_id'],
      lastActivity: json['last_activity'] ?? '',
      latestMessage: json['latest_message'] ?? '',
      latestMessageType: json['latest_message_type'] ?? '',
      messageCount: json['message_count'] ?? 0,
    );
  }
}

class ChatHistoryResponse {
  final int count;
  final String? reportId;
  final String? sessionId;
  final List<ChatSession> sessions;
  final String status;
  final String type;
  final String userId;

  ChatHistoryResponse({
    required this.count,
    this.reportId,
    this.sessionId,
    required this.sessions,
    required this.status,
    required this.type,
    required this.userId,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponse(
      count: json['count'] ?? 0,
      reportId: json['report_id'],
      sessionId: json['session_id'],
      sessions: (json['sessions'] as List<dynamic>?)
          ?.map((session) => ChatSession.fromJson(session))
          .toList() ?? [],
      status: json['status'] ?? '',
      type: json['type'] ?? '',
      userId: json['user_id'] ?? '',
    );
  }
}

class NormalChatConversationController extends GetxController {
  var messages = <ChatMessage>[].obs;
  var isLoading = false.obs;
  var isTyping = false.obs;
  var isLoadingHistory = false.obs;
  var chatSessions = <ChatSession>[].obs;
  var isUploadingPdf = false.obs;
  var showPdfUploader = false.obs;
  String? sessionId;
  String? sessionReportId; // Store the report ID for the current session
  String? lastUserMessage; // Store the last user message that triggered PDF upload

  Future<void> sendMessage(String message) async {
    if (message.trim().isNotEmpty) {

      messages.add(ChatMessage(
        text: message.trim(),
        isUser: true,
        timestamp: DateFormat('HH:mm').format(DateTime.now()),
      ));
      
      // Show typing state
      isTyping.value = true;
      isLoading.value = true;

      if (sessionId == null) {
        sessionId = const Uuid().v4();
      }

      String? userId = AppConstants().getStorage.read(AppConstants.USER_MOBILE);
      
      // Use session report ID if available, otherwise extract from message
      String reportId = sessionReportId ?? _extractReportId(message.trim());
      
      print("=== SENDING MESSAGE ===");
      print("Session ID: $sessionId");
      print("Session Report ID: $sessionReportId");
      print("Extracted Report ID: ${_extractReportId(message.trim())}");
      print("Final Report ID: $reportId");
      print("Message: ${message.trim()}");
      
      try {
        final response = await http.post(
          Uri.parse('https://staging.zethealth.com/normal-chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': userId,
            'question': message.trim(),
            'report_id': reportId,
            'session_id': sessionId,
          }),
        );

        print("Response Status: ${response.statusCode}");
        print("Response Body: ${response.body}");

        if (response.statusCode == 200) {
          final responseJson = jsonDecode(response.body);
          print("Parsed JSON: $responseJson");
          
          final chatResponse = ChatResponseModel.fromJson(responseJson);
          print("Display Message: ${chatResponse.result.displayMessage}");
          print("Requires PDF: ${chatResponse.result.requiresPdf}");
          
          messages.add(ChatMessage(
            text: chatResponse.result.displayMessage,
            isUser: false,
            timestamp: DateFormat('HH:mm').format(DateTime.now()),
          ));
          
          // Check if PDF is required
          if (chatResponse.result.requiresPdf) {
            lastUserMessage = message.trim(); // Store the message that triggered PDF upload
            showPdfUploader.value = true; // Show PDF uploader
          }
        } else {
          messages.add(ChatMessage(
            text: 'Sorry, something went wrong. Please try again. Status: ${response.statusCode}',
            isUser: false,
            timestamp: DateFormat('HH:mm').format(DateTime.now()),
          ));
        }
      } catch (e) {
        print("Error: $e");
        messages.add(ChatMessage(
          text: 'Sorry, something went wrong. Error: ${e.toString()}',
          isUser: false,
          timestamp: DateFormat('HH:mm').format(DateTime.now()),
        ));
      } finally {
        isLoading.value = false;
        isTyping.value = false;
      }
    }
  }

  Future<void> fetchChatHistory() async {
    String? userId = AppConstants().getStorage.read(AppConstants.USER_MOBILE);
    if (userId == null) return;

    try {
      isLoadingHistory.value = true;
      final response = await http.get(
        Uri.parse('https://staging.zethealth.com/chat-history/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print("Chat History Response Status: ${response.statusCode}");
      print("Chat History Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        final historyResponse = ChatHistoryResponse.fromJson(responseJson);
        
        chatSessions.value = historyResponse.sessions;
        
        // Load the latest session if available
        // if (historyResponse.sessions.isNotEmpty) {
        //   final latestSession = historyResponse.sessions.first;
        //   await loadSessionMessages(latestSession.sessionId);
        // }
      } else {
        print("Failed to fetch chat history: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching chat history: $e");
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> loadSessionMessages(String sessionId) async {
    String? userId = AppConstants().getStorage.read(AppConstants.USER_MOBILE);
    if (userId == null) return;

    try {
      isLoading.value = true;
      this.sessionId = sessionId;
      
      // Find the session in chatSessions to get its report ID
      ChatSession? selectedSession = chatSessions.firstWhereOrNull(
        (session) => session.sessionId == sessionId
      );
      
      if (selectedSession != null && selectedSession.reportId != null && selectedSession.reportId!.isNotEmpty) {
        sessionReportId = selectedSession.reportId;
        print("=== LOADING SESSION WITH REPORT ID ===");
        print("Session ID: $sessionId");
        print("Session Report ID: $sessionReportId");
      } else {
        sessionReportId = null;
        print("=== LOADING SESSION WITHOUT REPORT ID ===");
        print("Session ID: $sessionId");
      }
      
      final response = await http.get(
        Uri.parse('https://staging.zethealth.com/chat-history/$userId?session_id=$sessionId'),
        headers: {'Content-Type': 'application/json'},
      );

      print("Session Messages Response Status: ${response.statusCode}");
      print("Session Messages Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        
        // Clear existing messages
        messages.clear();
        
        // Parse and add messages from the session
        if (responseJson['chat_history'] != null) {
          final messagesList = responseJson['chat_history'] as List;
          for (var messageData in messagesList) {
            messages.add(ChatMessage(
              text: messageData['message'] ?? '',
              isUser: messageData['message_type'] == 'human',
              timestamp: _formatTimestamp(messageData['created_at']),
              id: messageData['id']?.toString(),
            ));
          }
        }
      } else {
        print("Failed to load session messages: ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading session messages: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return DateFormat('HH:mm').format(DateTime.now());
    
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return DateFormat('HH:mm').format(DateTime.now());
    }
  }

  void clearChat() {
    messages.clear();
    sessionId = null;
  }

  void startNewChat() {
    clearChat();
    sessionId = null;
    sessionReportId = null;
    showPdfUploader.value = false;
    lastUserMessage = null;
  }

  Future<void> pickAndUploadPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        File file = File(filePath);
        
        // Check file size (10MB limit)
        int fileSizeInBytes = await file.length();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
        
        if (fileSizeInMB > 10) {
          Get.snackbar(
            'File Size Error',
            'File size should be less than 10MB',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        // Get user mobile number (user ID)
        String? userMobile = AppConstants().getStorage.read(AppConstants.USER_MOBILE)?.toString();
        if (userMobile == null) {
          Get.snackbar(
            'Error',
            'User not found. Please login again.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        // Start upload
        isUploadingPdf.value = true;
        
        // Upload PDF
        PdfApiHelper pdfApiHelper = PdfApiHelper();
        await pdfApiHelper.uploadPdfInBackgroundWithData(filePath, userMobile, (success, message, responseData) async {
          isUploadingPdf.value = false;
          
          if (success) {
            showPdfUploader.value = false;
            
            print("=== PDF UPLOAD SUCCESS ===");
            print("Response Data: $responseData");
            
            // Extract report ID from response data
            String? reportId = _extractReportIdFromResponse(responseData);
            
            if (reportId != null && reportId.isNotEmpty) {
              print("Extracted Report ID from response: $reportId");
              
              // Set the session report ID for future messages
              sessionReportId = reportId;
              print("Set session report ID: $sessionReportId");
              
              // Automatically resend the last user message with the report ID
              if (lastUserMessage != null) {
                print("Resending last message with report ID: $lastUserMessage");
                await _resendMessageWithReportId(lastUserMessage!, reportId);
                lastUserMessage = null; // Clear after resending
              }
            } else {
              print("No report ID found in response, trying to get latest report ID");
              // Fallback: Get the latest report ID for this user
              String? fallbackReportId = await _getLatestReportId(userMobile);
              
              if (fallbackReportId != null && fallbackReportId.isNotEmpty && lastUserMessage != null) {
                print("Using fallback report ID: $fallbackReportId");
                sessionReportId = fallbackReportId;
                print("Set session report ID from fallback: $sessionReportId");
                await _resendMessageWithReportId(lastUserMessage!, fallbackReportId);
                lastUserMessage = null;
              } else {
                Get.snackbar(
                  'Upload Successful',
                  'PDF uploaded successfully! You can now ask questions about your report.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            }
          } else {
            Get.snackbar(
              'Upload Failed',
              message ?? 'Failed to upload PDF',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        });
        
      }
    } catch (e) {
      isUploadingPdf.value = false;
      Get.snackbar(
        'Error',
        'Error picking file: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<String?> _getLatestReportId(String userId) async {
    try {
      // Get the latest report ID from the reports endpoint
      final response = await http.get(
        Uri.parse('https://staging.zethealth.com/reports/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print("Latest Report Response Status: ${response.statusCode}");
      print("Latest Report Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        
        // Assuming the response has a list of reports and we want the latest one
        if (responseJson['reports'] != null && responseJson['reports'].isNotEmpty) {
          final reports = responseJson['reports'] as List;
          if (reports.isNotEmpty) {
            // Get the first report (assuming it's the latest)
            return reports.first['id']?.toString() ?? reports.first['report_id']?.toString();
          }
        }
        
        // Alternative: if the response directly contains the latest report ID
        return responseJson['report_id']?.toString() ?? responseJson['id']?.toString();
      }
    } catch (e) {
      print("Error getting latest report ID: $e");
    }
    return null;
  }

  void closePdfUploader() {
    showPdfUploader.value = false;
    lastUserMessage = null;
  }

  String? _extractReportIdFromResponse(Map<String, dynamic>? responseData) {
    if (responseData == null) return null;
    
    print("Extracting report ID from response: $responseData");
    
    // Try different possible keys for report ID
    List<String> possibleKeys = [
      'report_id',
      'reportId', 
      'id',
      'report_uuid',
      'uuid',
      'file_id',
      'document_id'
    ];
    
    for (String key in possibleKeys) {
      if (responseData.containsKey(key) && responseData[key] != null) {
        String reportId = responseData[key].toString();
        if (reportId.isNotEmpty) {
          print("Found report ID with key '$key': $reportId");
          return reportId;
        }
      }
    }
    
    // Check nested objects
    if (responseData.containsKey('data') && responseData['data'] is Map) {
      Map<String, dynamic> data = responseData['data'];
      for (String key in possibleKeys) {
        if (data.containsKey(key) && data[key] != null) {
          String reportId = data[key].toString();
          if (reportId.isNotEmpty) {
            print("Found report ID in data with key '$key': $reportId");
            return reportId;
          }
        }
      }
    }
    
    print("No report ID found in response data");
    return null;
  }

  Future<void> _resendMessageWithReportId(String message, String reportId) async {
    print("=== RESENDING MESSAGE WITH REPORT ID ===");
    print("Message: $message");
    print("Report ID: $reportId");
    
    // Show typing state
    isTyping.value = true;
    isLoading.value = true;

    String? userId = AppConstants().getStorage.read(AppConstants.USER_MOBILE);
    
    try {
      final response = await http.post(
        Uri.parse('https://staging.zethealth.com/normal-chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'question': message.trim(),
          'report_id': reportId,
          'session_id': sessionId,
        }),
      );

      print("Resend Response Status: ${response.statusCode}");
      print("Resend Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        final chatResponse = ChatResponseModel.fromJson(responseJson);
        
        messages.add(ChatMessage(
          text: chatResponse.result.displayMessage,
          isUser: false,
          timestamp: DateFormat('HH:mm').format(DateTime.now()),
        ));
        
        print("Successfully resent message with report ID");
      } else {
        messages.add(ChatMessage(
          text: 'Sorry, something went wrong. Please try again. Status: ${response.statusCode}',
          isUser: false,
          timestamp: DateFormat('HH:mm').format(DateTime.now()),
        ));
      }
    } catch (e) {
      print("Error resending message: $e");
      messages.add(ChatMessage(
        text: 'Sorry, something went wrong. Error: ${e.toString()}',
        isUser: false,
        timestamp: DateFormat('HH:mm').format(DateTime.now()),
      ));
    } finally {
      isLoading.value = false;
      isTyping.value = false;
    }
  }

  String _extractReportId(String message) {
    // Look for UUID patterns in the message (common report ID format)
    // UUID pattern: 8-4-4-4-12 characters (e.g., 0caa9df5-8751-493c-b9e6-2cb0120dc26c)
    RegExp uuidRegex = RegExp(
      r'\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b'
    );
    
    Match? match = uuidRegex.firstMatch(message);
    if (match != null) {
      String reportId = match.group(0)!;
      print("Extracted Report ID: $reportId");
      return reportId;
    }
    
    // Alternative: Look for patterns like "report_id: xxx" or "report id: xxx"
    RegExp reportIdRegex = RegExp(
      r'report[_\s]*id[:\s]+([a-zA-Z0-9\-]+)',
      caseSensitive: false
    );
    
    match = reportIdRegex.firstMatch(message);
    if (match != null && match.group(1) != null) {
      String reportId = match.group(1)!;
      print("Extracted Report ID from pattern: $reportId");
      return reportId;
    }
    
    print("No Report ID found in message");
    return '';
  }

  void _showReportIdDialog(String reportId) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Upload Successful!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your medical report has been uploaded successfully. Here is your Report ID:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      reportId,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Copy to clipboard
                      Clipboard.setData(ClipboardData(text: reportId));
                      Get.snackbar(
                        'Copied!',
                        'Report ID copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                    icon: Icon(Icons.copy, color: Colors.blue),
                    tooltip: 'Copy Report ID',
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Include this Report ID in your messages to get analysis of your medical report.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Got it!',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Recommendation messages to show initially
final List<String> recommendationMessages = [
  "What are common symptoms of seasonal illnesses?",
  "How can I maintain a healthy daily routine?",
  "What are the benefits of regular exercise?",
  "How can I boost my immune system naturally?",
  "When should I get a general health checkup?",
  "What are tips for managing everyday stress?",
];

  void selectRecommendation(String recommendation) {
    sendMessage(recommendation);
  }

  @override
  void onInit() {
    super.onInit();
    // Load chat history when controller is initialized
    // fetchChatHistory();
  }
}
