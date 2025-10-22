import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pdf_file.dart';
import '../utils/app_colors.dart';

class PDFCard extends StatefulWidget {
  final PDFFile pdfFile;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onToggleFavorite;
  final bool isListView;
  final bool isFavorite;

  const PDFCard({
    super.key,
    required this.pdfFile,
    required this.onTap,
    required this.onDelete,
    this.onToggleFavorite,
    this.isListView = false,
    this.isFavorite = false,
  });

  @override
  State<PDFCard> createState() => _PDFCardState();
}

class _PDFCardState extends State<PDFCard> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritePaths = prefs.getStringList('favorite_files') ?? [];
    setState(() {
      _isFavorite = favoritePaths.contains(widget.pdfFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isListView) {
      return _buildListCard(context);
    } else {
      return _buildGridCard(context);
    }
  }

  Widget _buildGridCard(BuildContext context) {
    return Card(
      color: AppColors.darkCard,
      elevation: 0,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: widget.pdfFile.thumbnailPath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(widget.pdfFile.thumbnailPath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPDFIcon();
                                },
                              ),
                            )
                          : _buildPDFIcon(),
                    ),
                    if (widget.onToggleFavorite != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isFavorite = !_isFavorite;
                            });
                            widget.onToggleFavorite!();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.darkBackground.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isFavorite ? Icons.star : Icons.star_border,
                              color: _isFavorite
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pdfFile.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.pdfFile.sizeFormatted,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.pdfFile.dateFormatted,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                    if (widget.pdfFile.isPasswordProtected) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.lock,
                              size: 12, color: AppColors.warning),
                          const SizedBox(width: 4),
                          const Text(
                            'Protected',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    return Card(
      color: AppColors.darkCard,
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: widget.pdfFile.thumbnailPath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(widget.pdfFile.thumbnailPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPDFIcon();
                    },
                  ),
                )
              : _buildPDFIcon(),
        ),
        title: Text(
          widget.pdfFile.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.pdfFile.sizeFormatted} • ${widget.pdfFile.dateFormatted}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (widget.pdfFile.isPasswordProtected)
              Row(
                children: [
                  const Icon(Icons.lock, size: 12, color: AppColors.warning),
                  const SizedBox(width: 4),
                  const Text(
                    'Password Protected',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onToggleFavorite != null)
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  color:
                      _isFavorite ? AppColors.accent : AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                  widget.onToggleFavorite!();
                },
              ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'open',
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new, color: AppColors.textPrimary),
                      SizedBox(width: 8),
                      Text('Open',
                          style: TextStyle(color: AppColors.textPrimary)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, color: AppColors.textPrimary),
                      SizedBox(width: 8),
                      Text('Share',
                          style: TextStyle(color: AppColors.textPrimary)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'open':
                    widget.onTap();
                    break;
                  case 'delete':
                    widget.onDelete();
                    break;
                  case 'share':
                    // TODO: Implement share functionality
                    break;
                }
              },
            ),
          ],
        ),
        onTap: widget.onTap,
      ),
    );
  }

  Widget _buildPDFIcon() {
    return const Center(
      child: Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 32),
    );
  }
}
