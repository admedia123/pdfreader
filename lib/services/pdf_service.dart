import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import '../models/pdf_file.dart';

class PDFService {
  static const String _pdfDirectoryName = 'PDFReader';

  Future<String> get _pdfDirectory async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${directory.path}/$_pdfDirectoryName');
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    return pdfDir.path;
  }

  Future<List<PDFFile>> getPDFFiles() async {
    try {
      final pdfDir = await _pdfDirectory;
      final directory = Directory(pdfDir);
      final files = await directory.list().toList();

      List<PDFFile> pdfFiles = [];

      for (final file in files) {
        if (file is File && file.path.toLowerCase().endsWith('.pdf')) {
          final stat = await file.stat();
          pdfFiles.add(
            PDFFile(
              name: file.path.split('/').last,
              path: file.path,
              size: stat.size,
              dateModified: stat.modified,
            ),
          );
        }
      }

      return pdfFiles;
    } catch (e) {
      throw Exception('Error getting PDF files: $e');
    }
  }

  Future<void> copyPDFToAppDirectory(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      final pdfDir = await _pdfDirectory;
      final fileName = sourcePath.split('/').last;
      final destinationPath = '$pdfDir/$fileName';

      await sourceFile.copy(destinationPath);
    } catch (e) {
      throw Exception('Error copying PDF file: $e');
    }
  }

  Future<String?> convertImagesToPDF(List<String> imagePaths) async {
    try {
      final pdf = pw.Document();

      for (final imagePath in imagePaths) {
        final imageFile = File(imagePath);
        final imageBytes = await imageFile.readAsBytes();
        final image = img.decodeImage(imageBytes);

        if (image != null) {
          final pdfImage = pw.MemoryImage(imageBytes);

          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) {
                return pw.Center(
                  child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
                );
              },
            ),
          );
        }
      }

      final pdfDir = await _pdfDirectory;
      final fileName = 'converted_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final pdfPath = '$pdfDir/$fileName';

      final file = File(pdfPath);
      await file.writeAsBytes(await pdf.save());

      return pdfPath;
    } catch (e) {
      throw Exception('Error converting images to PDF: $e');
    }
  }

  Future<void> deletePDF(String pdfPath) async {
    try {
      final file = File(pdfPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Error deleting PDF: $e');
    }
  }

  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<bool> hasStoragePermission() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  Future<String> getPDFThumbnail(String pdfPath) async {
    // This is a placeholder implementation
    // In a real app, you would use a PDF library to generate thumbnails
    return pdfPath; // Return the same path for now
  }

  Future<bool> isPDFPasswordProtected(String pdfPath) async {
    // This is a placeholder implementation
    // In a real app, you would check if the PDF is password protected
    return false;
  }

  Future<bool> validatePDFPassword(String pdfPath, String password) async {
    // This is a placeholder implementation
    // In a real app, you would validate the PDF password
    return true;
  }
}


