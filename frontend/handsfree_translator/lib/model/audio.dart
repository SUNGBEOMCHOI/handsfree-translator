import 'dart:convert';

class ApiResponse {
  final String uploadedAudioFileName;
  final String translatedAudioFileName;
  final String transcribedText;
  final String translatedText;
  final String requestType;

  ApiResponse({
    required this.uploadedAudioFileName,
    required this.translatedAudioFileName,
    required this.transcribedText,
    required this.translatedText,
    required this.requestType,
  });

  factory ApiResponse.fromHeaders(Map<String, String> headers) {
    return ApiResponse(
      uploadedAudioFileName: headers['uploaded_audio_file_name'] ?? '',
      translatedAudioFileName: headers['translated_audio_file_name'] ?? '',
      transcribedText:
          decodeHeaderValue(headers['transcribed_text'] ?? '') ?? '',
      translatedText: decodeHeaderValue(headers['translated_text'] ?? '') ?? '',
      requestType: headers['request_type'] ?? '',
    );
  }
}

String? decodeHeaderValue(String value) {
  RegExp exp = RegExp(r'=\?([^?]+)\?([bBqQ])\?([^?]+)\?=');
  Match? match = exp.firstMatch(value);

  if (match != null) {
    String charset = match.group(1) ?? '';
    String encoding = (match.group(2) ?? '').toUpperCase();
    String encodedText = match.group(3) ?? '';

    if (charset.toLowerCase() == 'utf-8' && encoding == 'B') {
      return utf8.decode(base64.decode(encodedText));
    }
  }

  return value;
}
