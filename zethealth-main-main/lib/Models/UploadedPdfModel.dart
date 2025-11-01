class UploadedPdfModel {
  String? reportId;
  String? filename;
  String? pdfUrl;
  String? createdAt;
  String? processedAt;
  String? userId;
  String? chatModel;
  String? chatProvider;
  int? chunksCount;
  int? fileSize;
  int? totalCharacters;
  String? embeddingModel;
  String? faissPath;
  bool? hasLocalFaiss;
  bool? hasSupabasePdf;
  Map<String, dynamic>? metadata;

  UploadedPdfModel({
    this.reportId,
    this.filename,
    this.pdfUrl,
    this.createdAt,
    this.processedAt,
    this.userId,
    this.chatModel,
    this.chatProvider,
    this.chunksCount,
    this.fileSize,
    this.totalCharacters,
    this.embeddingModel,
    this.faissPath,
    this.hasLocalFaiss,
    this.hasSupabasePdf,
    this.metadata,
  });

  UploadedPdfModel.fromJson(Map<String, dynamic> json) {
    reportId = json['report_id']?.toString();
    filename = json['filename']?.toString();
    pdfUrl = json['pdf_url']?.toString();
    createdAt = json['created_at']?.toString();
    processedAt = json['processed_at']?.toString();
    userId = json['user_id']?.toString() ?? json['metadata']?['user_id']?.toString();
    chatModel = json['chat_model']?.toString();
    chatProvider = json['chat_provider']?.toString();
    chunksCount = json['chunks_count'];
    fileSize = json['file_size'];
    totalCharacters = json['total_characters'];
    embeddingModel = json['embedding_model']?.toString();
    faissPath = json['faiss_path']?.toString();
    hasLocalFaiss = json['has_local_faiss'];
    hasSupabasePdf = json['has_supabase_pdf'];
    metadata = json['metadata'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['report_id'] = reportId;
    data['filename'] = filename;
    data['pdf_url'] = pdfUrl;
    data['created_at'] = createdAt;
    data['processed_at'] = processedAt;
    data['user_id'] = userId;
    data['chat_model'] = chatModel;
    data['chat_provider'] = chatProvider;
    data['chunks_count'] = chunksCount;
    data['file_size'] = fileSize;
    data['total_characters'] = totalCharacters;
    data['embedding_model'] = embeddingModel;
    data['faiss_path'] = faissPath;
    data['has_local_faiss'] = hasLocalFaiss;
    data['has_supabase_pdf'] = hasSupabasePdf;
    data['metadata'] = metadata;
    return data;
  }

  // Helper method to get formatted file name
  String get displayFileName {
    if (filename != null && filename!.isNotEmpty) {
      // Remove the report_id prefix and .pdf extension for cleaner display
      String cleanName = filename!;
      if (cleanName.startsWith('report_')) {
        cleanName = cleanName.substring(7); // Remove 'report_' prefix
      }
      if (cleanName.endsWith('.pdf')) {
        cleanName = cleanName.substring(0, cleanName.length - 4); // Remove '.pdf'
      }
      return cleanName;
    }
    return reportId ?? 'Unknown Report';
  }

  // Helper method to get formatted date
  String get formattedProcessedDate {
    if (processedAt != null) {
      try {
        DateTime dateTime = DateTime.parse(processedAt!);
        return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return processedAt!;
      }
    }
    return 'Processing...';
  }

  // Helper method to get file size in readable format
  String get formattedFileSize {
    if (fileSize != null) {
      if (fileSize! < 1024) {
        return '${fileSize} B';
      } else if (fileSize! < 1024 * 1024) {
        return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    }
    return '';
  }
}