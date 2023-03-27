import 'dart:io';
import 'package:handsfree_translator/model/audio.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<ApiResponse?> uploadAudioFile(
    String filePath, String requestType) async {
  // Create a File instance from the file path
  File audioFile = File(filePath);

  // Prepare the HTTP POST request with the audio file
  String baseUrl = "http://choisb3631.pythonanywhere.com/";
  Uri url = Uri.parse('$baseUrl/translator/audio/upload/');
  http.MultipartRequest request = http.MultipartRequest('POST', url);
  http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
    'audio_file',
    audioFile.path,
    filename: basename(audioFile.path),
  );
  request.files.add(multipartFile);

  request.fields['audio_file_name'] = basename(audioFile.path);
  request.fields['request_type'] = requestType;

  // Send the HTTP POST request
  http.StreamedResponse streamedResponse = await request.send();
  // http.Response response = await http.Response.fromStream(streamresponse);

  // Handle the response
  if (streamedResponse.statusCode == 200) {
    String contentDisposition =
        streamedResponse.headers['content-disposition']!;
    final audioFileName = contentDisposition
        .split(';')
        .firstWhere((element) => element.contains('filename='))
        .split('=')[1]
        .replaceAll('"', '');

    final apiResponse = ApiResponse.fromHeaders(streamedResponse.headers);
    print(apiResponse.uploadedAudioFileName);
    print(apiResponse.translatedAudioFileName);
    print(apiResponse.transcribedText);
    print(apiResponse.translatedText);

    // Get the local directory to save the file
    final directory = await getApplicationDocumentsDirectory();

    // Create a new file with the given file name
    final file = File('${directory.path}/$audioFileName');

    // Write the response body (file content) to the file
    final fileSink = file.openWrite();
    await streamedResponse.stream.pipe(fileSink);
    print('File downloaded and saved at ${file.path}');
    print('Audio file uploaded successfully.');
    return apiResponse;
  } else {
    print('Failed to upload the audio file.');
    return null;
  }
}
