import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pdf_file.dart';
import '../services/pdf_service.dart';
import '../utils/app_colors.dart';
import '../widgets/pdf_card.dart';
import '../widgets/safe_banner_ad_widget.dart';
import 'pdf_viewer_screen.dart';

class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  final PDFService _pdfService = PDFService();
  List<PDFFile> _recentFiles = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'date';

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();
  }

  Future<void> _loadRecentFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allFiles = await _pdfService.getPDFFiles();
      final prefs = await SharedPreferences.getInstance();
      final recentPaths = prefs.getStringList('recent_files') ?? [];

      // Get recent files in order
      final recentFiles = <PDFFile>[];
      for (final path in recentPaths) {
        final file = allFiles.firstWhere(
          (f) => f.path == path,
          orElse: () => PDFFile(
            name: '',
            path: '',
            size: 0,
            dateModified: DateTime.now(),
          ),
        );
        if (file.name.isNotEmpty) {
          recentFiles.add(file);
        }
      }

      setState(() {
        _recentFiles = recentFiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading recent files: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
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
        backgroundColor: AppColors.darkCard,
        title: const Text('Delete PDF',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${pdfFile.name}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _pdfService.deletePDF(pdfFile.path);
                _loadRecentFiles();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PDF deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                _showErrorSnackBar('Error deleting PDF: $e');
              }
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  List<PDFFile> get _filteredAndSortedFiles {
    List<PDFFile> filtered = _recentFiles.where((file) {
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
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: AppBar(
            backgroundColor: AppColors.darkBackground,
            title: const Text('Recent files'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: _RecentSearchDelegate(_recentFiles),
                  );
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    _sortBy = value;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'name', child: Text('Sort by Name')),
                  const PopupMenuItem(
                      value: 'date', child: Text('Sort by Date')),
                  const PopupMenuItem(
                      value: 'size', child: Text('Sort by Size')),
                ],
                icon: const Icon(Icons.sort),
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _recentFiles.isEmpty
                  ? _buildEmptyState()
                  : Column(
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
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
        ),
        // Banner Ad - Safe implementation
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeBannerAdWidget(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkCard,
            ),
            child: const Icon(
              Icons.person,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recently read PDF documents\nwill appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentSearchDelegate extends SearchDelegate {
  final List<PDFFile> files;

  _RecentSearchDelegate(this.files);

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
