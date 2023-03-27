import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

String generateFilenameWithTimestamp(String baseFilename) {
  // Get the current date and time
  DateTime now = DateTime.now();

  // Format the date and time as a string
  String formattedDateTime = DateFormat('yyyyMMdd_HHmmss').format(now);

  // Get the file extension and filename without extension
  String extension = p.extension(baseFilename);
  String filenameWithoutExtension = p.basenameWithoutExtension(baseFilename);

  // Append the date and time to the filename without extension
  String newFilenameWithoutExtension =
      '${filenameWithoutExtension}_$formattedDateTime';

  // Add the extension back to the new filename
  String newFilename = '$newFilenameWithoutExtension$extension';

  return newFilename;
}
