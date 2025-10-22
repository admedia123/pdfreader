import '../models/pdf_file.dart';

class DemoData {
  static List<PDFFile> getSamplePDFFiles() {
    return [
      PDFFile(
        name: 'Sample Document 1.pdf',
        path: '/storage/emulated/0/Download/Sample Document 1.pdf',
        size: 1024000, // 1MB
        dateModified: DateTime.now().subtract(const Duration(days: 1)),
        isPasswordProtected: false,
      ),
      PDFFile(
        name: 'Important Report.pdf',
        path: '/storage/emulated/0/Download/Important Report.pdf',
        size: 2048000, // 2MB
        dateModified: DateTime.now().subtract(const Duration(days: 3)),
        isPasswordProtected: true,
        password: 'secret123',
      ),
      PDFFile(
        name: 'User Manual.pdf',
        path: '/storage/emulated/0/Download/User Manual.pdf',
        size: 5120000, // 5MB
        dateModified: DateTime.now().subtract(const Duration(days: 7)),
        isPasswordProtected: false,
      ),
      PDFFile(
        name: 'Meeting Notes.pdf',
        path: '/storage/emulated/0/Download/Meeting Notes.pdf',
        size: 512000, // 512KB
        dateModified: DateTime.now().subtract(const Duration(hours: 2)),
        isPasswordProtected: false,
      ),
      PDFFile(
        name: 'Financial Report.pdf',
        path: '/storage/emulated/0/Download/Financial Report.pdf',
        size: 10240000, // 10MB
        dateModified: DateTime.now().subtract(const Duration(days: 14)),
        isPasswordProtected: true,
        password: 'finance2024',
      ),
      PDFFile(
        name: 'Product Catalog.pdf',
        path: '/storage/emulated/0/Download/Product Catalog.pdf',
        size: 15360000, // 15MB
        dateModified: DateTime.now().subtract(const Duration(days: 30)),
        isPasswordProtected: false,
      ),
    ];
  }

  static List<String> getSampleImagePaths() {
    return [
      '/storage/emulated/0/Pictures/image1.jpg',
      '/storage/emulated/0/Pictures/image2.jpg',
      '/storage/emulated/0/Pictures/image3.jpg',
    ];
  }

  static Map<String, dynamic> getAppInfo() {
    return {
      'name': 'PDF Reader',
      'version': '1.0.0',
      'description': 'Your Ultimate PDF Companion',
      'features': [
        'View PDF files',
        'Night mode reading',
        'Convert images to PDF',
        'Share PDF files',
        'Password protection',
        'Search and sort',
        'Grid and list views',
      ],
    };
  }
}


