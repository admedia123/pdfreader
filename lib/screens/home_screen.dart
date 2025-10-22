import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pdf_file.dart';
import '../services/pdf_service.dart';
import '../widgets/pdf_card.dart';
import '../widgets/floating_action_buttons.dart';
import '../utils/app_colors.dart';
import 'pdf_viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PDFService _pdfService = PDFService();
  List<PDFFile> _pdfFiles = [];
  bool _isLoading = true;
  bool _isGridView = true;
  String _searchQuery = '';
  String _sortBy = 'name'; // name, date, size

  @override
  void initState() {
    super.initState();
    _loadPDFFiles();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGridView = prefs.getBool('isGridView') ?? true;
      _sortBy = prefs.getString('sortBy') ?? 'name';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGridView', _isGridView);
    await prefs.setString('sortBy', _sortBy);
  }

  Future<void> _loadPDFFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final files = await _pdfService.getPDFFiles();
      setState(() {
        _pdfFiles = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading PDF files: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _pickPDFFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (file.path != null) {
            await _pdfService.copyPDFToAppDirectory(file.path!);
          }
        }
        _showSuccessSnackBar('PDF files added successfully');
        _loadPDFFiles();
      }
    } catch (e) {
      _showErrorSnackBar('Error picking PDF file: $e');
    }
  }

  Future<void> _convertImagesToPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final pdfPath = await _pdfService.convertImagesToPDF(
          result.files.map((f) => f.path!).toList(),
        );
        if (pdfPath != null) {
          _showSuccessSnackBar('Images converted to PDF successfully');
          _loadPDFFiles();
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error converting images: $e');
    }
  }

  Future<void> _addToRecent(PDFFile pdfFile) async {
    final prefs = await SharedPreferences.getInstance();
    final recentPaths = prefs.getStringList('recent_files') ?? [];

    // Remove if already exists
    recentPaths.remove(pdfFile.path);
    // Add to beginning
    recentPaths.insert(0, pdfFile.path);

    // Keep only last 50 files
    if (recentPaths.length > 50) {
      recentPaths.removeRange(50, recentPaths.length);
    }

    await prefs.setStringList('recent_files', recentPaths);
  }

  Future<void> _toggleFavorite(PDFFile pdfFile) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritePaths = prefs.getStringList('favorite_files') ?? [];

    if (favoritePaths.contains(pdfFile.path)) {
      favoritePaths.remove(pdfFile.path);
    } else {
      favoritePaths.add(pdfFile.path);
    }

    await prefs.setStringList('favorite_files', favoritePaths);
    setState(() {});
  }

  void _openPDF(PDFFile pdfFile) {
    _addToRecent(pdfFile);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(pdfFile: pdfFile),
      ),
    );
  }

  void _deletePDF(PDFFile pdfFile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete PDF'),
        content: Text('Are you sure you want to delete "${pdfFile.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _pdfService.deletePDF(pdfFile.path);
                _showSuccessSnackBar('PDF deleted successfully');
                _loadPDFFiles();
              } catch (e) {
                _showErrorSnackBar('Error deleting PDF: $e');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<PDFFile> get _filteredAndSortedFiles {
    List<PDFFile> filtered = _pdfFiles.where((file) {
      return file.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'date':
          return b.dateModified.compareTo(a.dateModified);
        case 'size':
          return b.size.compareTo(a.size);
        default:
          return a.name.compareTo(b.name);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text('PDF Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _HomeSearchDelegate(_pdfFiles),
              );
            },
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
              _savePreferences();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
              _savePreferences();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
              const PopupMenuItem(value: 'size', child: Text('Sort by Size')),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'SORT',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.sort,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAndSortedFiles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No PDF files found'
                                  : 'No PDF files match your search',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Tap the + button to add PDF files'
                                  : 'Try a different search term',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : _isGridView
                        ? GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _filteredAndSortedFiles.length,
                            itemBuilder: (context, index) {
                              final pdfFile = _filteredAndSortedFiles[index];
                              return PDFCard(
                                pdfFile: pdfFile,
                                onTap: () => _openPDF(pdfFile),
                                onDelete: () => _deletePDF(pdfFile),
                                onToggleFavorite: () =>
                                    _toggleFavorite(pdfFile),
                              );
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredAndSortedFiles.length,
                            itemBuilder: (context, index) {
                              final pdfFile = _filteredAndSortedFiles[index];
                              return PDFCard(
                                pdfFile: pdfFile,
                                onTap: () => _openPDF(pdfFile),
                                onDelete: () => _deletePDF(pdfFile),
                                isListView: true,
                                onToggleFavorite: () =>
                                    _toggleFavorite(pdfFile),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButtons(
        onPickPDF: _pickPDFFile,
        onConvertImages: _convertImagesToPDF,
      ),
    );
  }
}

class _HomeSearchDelegate extends SearchDelegate {
  final List<PDFFile> files;

  _HomeSearchDelegate(this.files);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredFiles = files.where((file) {
      return file.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredFiles.length,
      itemBuilder: (context, index) {
        final pdfFile = filteredFiles[index];
        return ListTile(
          leading: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
          title: Text(
            pdfFile.name,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          subtitle: Text(
            '${pdfFile.size} • ${pdfFile.dateModified}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PDFViewerScreen(pdfFile: pdfFile),
              ),
            );
          },
        );
      },
    );
  }
}
