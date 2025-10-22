class PDFFile {
  final String name;
  final String path;
  final int size;
  final DateTime dateModified;
  final String? thumbnailPath;
  final bool isPasswordProtected;
  final String? password;

  PDFFile({
    required this.name,
    required this.path,
    required this.size,
    required this.dateModified,
    this.thumbnailPath,
    this.isPasswordProtected = false,
    this.password,
  });

  String get sizeFormatted {
    if (size < 1024) {
      return '${size}B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  String get dateFormatted {
    final now = DateTime.now();
    final difference = now.difference(dateModified);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateModified.day}/${dateModified.month}/${dateModified.year}';
    }
  }

  PDFFile copyWith({
    String? name,
    String? path,
    int? size,
    DateTime? dateModified,
    String? thumbnailPath,
    bool? isPasswordProtected,
    String? password,
  }) {
    return PDFFile(
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      dateModified: dateModified ?? this.dateModified,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isPasswordProtected: isPasswordProtected ?? this.isPasswordProtected,
      password: password ?? this.password,
    );
  }
}


