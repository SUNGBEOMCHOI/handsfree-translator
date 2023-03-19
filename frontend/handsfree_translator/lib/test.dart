import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

Future<void> uploadDummyAudioFile() async {
  // Replace with the path to your dummy audio file
  String filePath = 'C:/Users/chois/Desktop/handsfree_translator/test_en.mp3';
  // String filePath = 'C:/Users/chois/Desktop/handsfree_translator/test_ko.mp3';

  // Create a File instance from the file path
  File audioFile = File(filePath);

  // Prepare the HTTP POST request with the audio file
  Uri url = Uri.parse('http://127.0.0.1:8000/translator/audio/upload/');
  http.MultipartRequest request = http.MultipartRequest('POST', url);
  http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
    'audio_file',
    audioFile.path,
    filename: basename(audioFile.path),
  );
  request.files.add(multipartFile);

  request.fields['audio_file_name'] = 'test_en.mp3';
  // request.fields['audio_file_name'] = 'test_ko.mp3';
  request.fields['request_type'] = 'en2ko';
  // request.fields['request_type'] = 'ko2en';

  // Send the HTTP POST request
  http.StreamedResponse response = await request.send();

  // Handle the response
  if (response.statusCode == 200) {
    print('Audio file uploaded successfully.');
  } else {
    print('Failed to upload the audio file.');
  }
}

void main() {
  uploadDummyAudioFile();
}
