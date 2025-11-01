import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/UploadedPdfModel.dart';
import 'package:zet_health/Screens/ChatScreen/ChatScreen.dart';

class ChatScreenController extends GetxController {
  RxList<ChatMessage> messages = <ChatMessage>[].obs;
  RxBool isTyping = false.obs;
  RxBool isLoading = false.obs;
  UploadedPdfModel? currentPdfModel;
  String? currentSessionId;

  // Helper method to get the correct base URL based on platform
  String get _baseUrl {
      return 'https://staging.zethealth.com';
  }

  // Generate a unique session ID
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'session_${timestamp}_$random';
  }

  void initializeChat(UploadedPdfModel pdfModel, String? sessionId) async {
    currentPdfModel = pdfModel;
    currentSessionId = sessionId;
    
    if (sessionId != null && sessionId.isNotEmpty) {
      // Load existing chat history
      await loadChatHistory(sessionId);
    } else {
      // For new sessions, start with empty messages to show recommendations
      messages.clear();
    }
  }

  Future<void> loadChatHistory(String sessionId) async {
    isLoading.value = true;
    
    try {
      // Get user ID from storage
      String? userId = AppConstants().getStorage.read(AppConstants.USER_MOBILE);
      
      if (userId == null) {
        AppConstants().showToast('User not logged in');
        isLoading.value = false;
        return;
      }

      // Call the chat history API with session ID
      final response = await _callChatHistoryWithSessionApi(userId, sessionId);
      
      if (response != null && response['status'] == 'completed') {
        List<dynamic> chatHistory = response['chat_history'] ?? [];
        
        // Convert to ChatMessage objects and sort by created_at
        List<ChatMessage> loadedMessages = chatHistory.map((messageData) {
          return ChatMessage(
            text: messageData['message'] ?? '',
            isUser: messageData['message_type'] == 'human',
            timestamp: _formatTimestamp(messageData['created_at'] ?? ''),
            id: messageData['id'],
            createdAt: messageData['created_at'],
            sources: messageData['sources'],
          );
        }).toList();
        
        // Sort by created_at (oldest first)
        loadedMessages.sort((a, b) => (a.createdAt ?? '').compareTo(b.createdAt ?? ''));
        
        messages.value = loadedMessages;
      } else {
        AppConstants().showToast('Failed to load chat history');
      }
    } catch (e) {
      print('Error loading chat history: $e');
      AppConstants().showToast('Error loading chat history');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> _callChatHistoryWithSessionApi(String userId, String sessionId) async {
    try {
      // Using the endpoint: {baseUrl}/chat-history/{userId}?report_id={reportId}&session_id={sessionId}
      final reportId = currentPdfModel?.reportId ?? '';
      final url = '$_baseUrl/chat-history/$userId?report_id=$reportId&session_id=$sessionId';
      print('Chat history URL: $url');
      
      final response = await Dio().get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      
      if (response.statusCode == 200) {
         return response.data as Map<String, dynamic>;
      }
      return null;
      
    } catch (e) {
      print('Error calling chat history API: $e');
      return null;
    }
  }

  void sendMessage(String text) async {
    // Add user message
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: _getCurrentTime(),
    );
    messages.add(userMessage);

    // Show AI typing indicator
    isTyping.value = true;
    
    try {
      // Get user ID from storage
      String? userId = AppConstants().getStorage.read(AppConstants.USER_MOBILE);
      
      if (userId == null) {
        AppConstants().showToast('User not logged in');
        isTyping.value = false;
        return;
      }

      // Call the real chat API
      final response = await _callChatApi(userId, text);
      
      if (response != null && response['status'] == 'completed') {
        final result = response['result'];
        final aiResponse = result['answer'] ?? 'Sorry, I could not process your request.';
        
        // Add AI response message
        final aiMessage = ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: _getCurrentTime(),
          sources: result['sources'],
        );
        
        messages.add(aiMessage);
        
        // Update session ID if server returns a different one (fallback)
        if (result['session_id'] != null && result['session_id'] != currentSessionId) {
          currentSessionId = result['session_id'];
          print('Session ID updated from server: $currentSessionId');
        }
        
      } else {
        // Handle API error
        final errorMessage = ChatMessage(
          text: 'Sorry, I encountered an error while processing your request. Please try again.',
          isUser: false,
          timestamp: _getCurrentTime(),
        );
        messages.add(errorMessage);
        AppConstants().showToast('Failed to get AI response');
      }
      
    } catch (e) {
      print('Error sending message: $e');
      
      // Add error message
      final errorMessage = ChatMessage(
        text: 'Sorry, I encountered a network error. Please check your connection and try again.',
        isUser: false,
        timestamp: _getCurrentTime(),
      );
      messages.add(errorMessage);
      AppConstants().showToast('Network error occurred');
      
    } finally {
      isTyping.value = false;
    }
  }

  Future<Map<String, dynamic>?> _callChatApi(String userId, String question) async {
    try {
      final url = '$_baseUrl/chat';
      
      // Generate session ID if it doesn't exist or is empty
      if (currentSessionId == null || currentSessionId!.isEmpty) {
        currentSessionId = _generateSessionId();
        print('Generated new session ID: $currentSessionId');
      }
      
      final requestData = {
        'user_id': userId,
        'question': question,
        'report_id': currentPdfModel?.reportId ?? '',
        'session_id': currentSessionId!,
      };
      
      print('Sending chat request to: $url');
      print('Request data: $requestData');
      
      final response = await Dio().post(
        url,
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      
      print('Chat API response: ${response.data}');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
      
    } catch (e) {
      print('Error calling chat API: $e');
      return null;
    }
  }

  String _getCurrentTime() {
    return DateFormat('HH:mm').format(DateTime.now());
  }

  String _formatTimestamp(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return _getCurrentTime();
    }
  }

  void clearChat() {
    messages.clear();
    if (currentPdfModel != null) {
      initializeChat(currentPdfModel!, currentSessionId);
    }
    AppConstants().showToast('Chat cleared successfully');
  }

  void exportChat() {
    // TODO: Implement chat export functionality
    AppConstants().showToast('Exporting chat... (Feature coming soon)');
  }

  void shareChat() {
    // TODO: Implement chat sharing functionality
    AppConstants().showToast('Sharing chat... (Feature coming soon)');
  }

  @override
  void onClose() {
    messages.clear();
    super.onClose();
  }
}