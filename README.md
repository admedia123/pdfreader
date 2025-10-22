# PDF Reader - Flutter App

A powerful PDF reader application built with Flutter, inspired by PixPDF from Google Play Store.

## Features

### Core Features
- 📄 **View PDF Files**: Open and view PDF documents with smooth navigation
- 🌙 **Night Mode**: Dark theme for comfortable reading in low light
- 🖼️ **Image to PDF**: Convert multiple images to PDF documents
- 📤 **Share PDF**: Share PDF files via email, messaging apps, or cloud storage
- 🔒 **Password Protection**: Add password protection to your PDF files
- 🔍 **Search**: Search through your PDF collection
- 📱 **Responsive UI**: Beautiful and intuitive user interface

### Additional Features
- Grid and List view options
- Sort files by name, date, or size
- Zoom controls in PDF viewer
- Page navigation with thumbnails
- File management (delete, rename)
- Settings and preferences
- Splash screen with animations

## Screenshots

The app includes:
- Modern splash screen with logo animation
- Home screen with PDF file grid/list
- PDF viewer with navigation controls
- Settings screen for customization
- Night mode toggle
- Floating action buttons for quick actions

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd pdf_reader
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Dependencies

- `flutter_pdfview`: PDF viewing functionality
- `pdf`: PDF document manipulation
- `file_picker`: File selection
- `path_provider`: File system access
- `share_plus`: File sharing
- `permission_handler`: Runtime permissions
- `image_picker`: Image selection
- `image`: Image processing
- `shared_preferences`: Settings storage

## Permissions

The app requires the following permissions:
- `READ_EXTERNAL_STORAGE`: Access PDF files
- `WRITE_EXTERNAL_STORAGE`: Save converted PDFs
- `INTERNET`: For future cloud features

## Architecture

The app follows a clean architecture pattern:
- `models/`: Data models (PDFFile)
- `screens/`: UI screens (Home, PDFViewer, Settings)
- `widgets/`: Reusable UI components
- `services/`: Business logic (PDFService)
- `utils/`: Utilities (Theme, Constants)

## Features Implementation

### PDF Viewing
- Uses `flutter_pdfview` for smooth PDF rendering
- Supports zoom, pan, and page navigation
- Night mode for comfortable reading

### File Management
- Scans device for PDF files
- Copy files to app directory
- Delete and organize files

### Image to PDF Conversion
- Select multiple images
- Convert to PDF with proper formatting
- Save to app directory

### UI/UX
- Material Design 3
- Responsive layout
- Smooth animations
- Dark/Light theme support

## Future Enhancements

- [ ] PDF annotation and markup
- [ ] Cloud storage integration
- [ ] PDF editing capabilities
- [ ] OCR text recognition
- [ ] PDF form filling
- [ ] Bookmark and favorites
- [ ] Print functionality

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by PixPDF app on Google Play Store
- Built with Flutter framework
- Uses various open-source packages


