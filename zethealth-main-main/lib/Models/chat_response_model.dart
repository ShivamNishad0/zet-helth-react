class ChatResponseModel {
  final String status;
  final ChatResult result;

  ChatResponseModel({
    required this.status,
    required this.result,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      status: json['status'] ?? '',
      result: ChatResult.fromJson(json['result'] ?? {}),
    );
  }
}

class ChatResult {
  final String? message;
  final bool requiresPdf;
  final String? answer;
  final String? answerFormat;
  final bool chatHistorySaved;
  final String? mode;
  final String? question;
  final String? sessionId;
  final bool success;
  final String? userId;

  ChatResult({
    this.message,
    this.requiresPdf = false,
    this.answer,
    this.answerFormat,
    this.chatHistorySaved = false,
    this.mode,
    this.question,
    this.sessionId,
    this.success = false,
    this.userId,
  });

  factory ChatResult.fromJson(Map<String, dynamic> json) {
    return ChatResult(
      message: json['message'],
      requiresPdf: json['requires_pdf'] ?? false,
      answer: json['answer'],
      answerFormat: json['answer_format'],
      chatHistorySaved: json['chat_history_saved'] ?? false,
      mode: json['mode'],
      question: json['question'],
      sessionId: json['session_id']?.toString(),
      success: json['success'] ?? false,
      userId: json['user_id'],
    );
  }

  String get displayMessage {
    if (answer != null && answer!.isNotEmpty) {
      return answer!;
    }
    return message ?? 'No response received';
  }
}