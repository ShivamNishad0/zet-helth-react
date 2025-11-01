import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/UploadedPdfModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import 'package:zet_health/Screens/ChatScreen/ChatSessionsScreen.dart';

class ChatSessionsController extends GetxController {
  RxList<ChatSession> chatSessions = <ChatSession>[].obs;
  RxBool isLoading = false.obs;
  UploadedPdfModel? currentPdfModel;

  void loadChatSessions(UploadedPdfModel pdfModel) async {
    currentPdfModel = pdfModel;
    isLoading.value = true;
    String? reportId = pdfModel.reportId;
    
    try {
      // Get user ID from storage
      String? userId = AppConstants().getStorage.read(AppConstants.USER_MOBILE).toString();
      
      if (userId == null) {
        _safeShowToast('User not logged in');
        isLoading.value = false;
        return;
      }

      // Call the chat history API to get sessions
      final response = await _callChatHistoryApi(userId, reportId);

      print("response of chat session $response");

      
      if (response != null && response['status'] == 'completed') {
        List<dynamic> sessionsData = response['sessions'] ?? [];

        // Convert to ChatSession objects and sort by last activity
        List<ChatSession> sessions = sessionsData
            .map((sessionData) => ChatSession.fromJson(sessionData))
            .toList();
        
        // Sort by last activity (most recent first)
        sessions.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
        
        chatSessions.value = sessions;
      } else {
        _safeShowToast('Failed to load chat sessions');
      }
    } catch (e) {
      print('Error loading chat sessions: $e');
      _safeShowToast('Error loading chat sessions');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> _callChatHistoryApi(String userId, String? reportId) async {
    try {
      final url = 'https://staging.zethealth.com/chat-history/$userId?report_id=$reportId';

      print(url);

      // final response = await WebApiHelper().callGetApi(null, url, true);

      var dio = Dio();
      final response = await dio.get(
        url
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('API call failed with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error calling chat history API: $e');
      return null;
    }
  }

  void refreshSessions() {
    if (currentPdfModel != null) {
      loadChatSessions(currentPdfModel!);
    }
  }

  void _safeShowToast(String message) {
    try {
      // Check if we're still in a valid context before showing toast
      if (Get.context != null) {
        AppConstants().showToast(message);
      }
    } catch (e) {
      print('Error showing toast: $e');
      // Fallback to print if toast fails
      print('Toast message: $message');
    }
  }

  @override
  void onClose() {
    chatSessions.clear();
    super.onClose();
  }
}