import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import '../models/pdf_file.dart';

class PDFViewerScreen extends StatefulWidget {
  final PDFFile pdfFile;

  const PDFViewerScreen({super.key, required this.pdfFile});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  late PDFViewController _pdfViewController;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isReady = false;
  String _errorMessage = '';
  bool _isNightMode = false;
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onViewCreated(PDFViewController controller) {
    _pdfViewController = controller;
  }

  void _onPageChanged(int? page, int? total) {
    setState(() {
      _currentPage = page ?? 0;
      _totalPages = total ?? 0;
    });
  }

  void _onRenderCompleted(int? pages) {
    setState(() {
      _isReady = true;
      _totalPages = pages ?? 0;
    });
  }

  void _onError(dynamic error) {
    setState(() {
      _errorMessage = error.toString();
    });
  }

  void _toggleNightMode() {
    setState(() {
      _isNightMode = !_isNightMode;
    });
  }

  void _zoomIn() {
    if (_zoomLevel < 3.0) {
      setState(() {
        _zoomLevel += 0.25;
      });
    }
  }

  void _zoomOut() {
    if (_zoomLevel > 0.5) {
      setState(() {
        _zoomLevel -= 0.25;
      });
    }
  }

  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
    });
  }

  void _goToPage(int page) {
    _pdfViewController.setPage(page);
  }

  void _sharePDF() {
    Share.shareXFiles([XFile(widget.pdfFile.path)]);
  }

  void _showPageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go to Page'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current page: $_currentPage of $_totalPages'),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Page number',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                final page = int.tryParse(value);
                if (page != null && page >= 1 && page <= _totalPages) {
                  _goToPage(page - 1);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid page number'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isNightMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: _isNightMode ? Colors.black87 : null,
        foregroundColor: _isNightMode ? Colors.white : null,
        title: Text(widget.pdfFile.name, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(_isNightMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleNightMode,
            tooltip: _isNightMode ? 'Light Mode' : 'Night Mode',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePDF,
            tooltip: 'Share PDF',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.zoom_in),
                        title: const Text('Zoom In'),
                        onTap: () {
                          _zoomIn();
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.zoom_out),
                        title: const Text('Zoom Out'),
                        onTap: () {
                          _zoomOut();
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.zoom_out_map),
                        title: const Text('Reset Zoom'),
                        onTap: () {
                          _resetZoom();
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.pageview),
                        title: const Text('Go to Page'),
                        onTap: () {
                          Navigator.pop(context);
                          _showPageSelector();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading PDF',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = '';
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : PDFView(
              filePath: widget.pdfFile.path,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: false,
              pageFling: true,
              pageSnap: true,
              onViewCreated: _onViewCreated,
              onPageChanged: _onPageChanged,
              onRender: _onRenderCompleted,
              onError: _onError,
              onPageError: (page, error) {
                setState(() {
                  _errorMessage = 'Error on page $page: $error';
                });
              },
              defaultPage: _currentPage,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
              nightMode: _isNightMode,
            ),
      bottomNavigationBar: _isReady
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isNightMode ? Colors.black87 : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: _isNightMode ? Colors.grey[800]! : Colors.grey[300]!,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.first_page),
                    onPressed: _currentPage > 0 ? () => _goToPage(0) : null,
                    tooltip: 'First Page',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 0
                        ? () => _goToPage(_currentPage - 1)
                        : null,
                    tooltip: 'Previous Page',
                  ),
                  Text(
                    '${_currentPage + 1} / $_totalPages',
                    style: TextStyle(
                      color: _isNightMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _totalPages - 1
                        ? () => _goToPage(_currentPage + 1)
                        : null,
                    tooltip: 'Next Page',
                  ),
                  IconButton(
                    icon: const Icon(Icons.last_page),
                    onPressed: _currentPage < _totalPages - 1
                        ? () => _goToPage(_totalPages - 1)
                        : null,
                    tooltip: 'Last Page',
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
