import 'package:flutter/material.dart';

class FloatingActionButtons extends StatefulWidget {
  final VoidCallback onPickPDF;
  final VoidCallback onConvertImages;

  const FloatingActionButtons({
    super.key,
    required this.onPickPDF,
    required this.onConvertImages,
  });

  @override
  State<FloatingActionButtons> createState() => _FloatingActionButtonsState();
}

class _FloatingActionButtonsState extends State<FloatingActionButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 140, // Move up to avoid ads
      right: 16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isExpanded) ...[
            ScaleTransition(
              scale: _scaleAnimation,
              child: FloatingActionButton(
                heroTag: "convert_images",
                onPressed: () {
                  widget.onConvertImages();
                  _toggleExpanded();
                },
                backgroundColor: Colors.orange,
                child: const Icon(Icons.image, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            ScaleTransition(
              scale: _scaleAnimation,
              child: FloatingActionButton(
                heroTag: "pick_pdf",
                onPressed: () {
                  widget.onPickPDF();
                  _toggleExpanded();
                },
                backgroundColor: Colors.blue,
                child: const Icon(Icons.upload_file, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
          ],
          FloatingActionButton(
            heroTag: "main_fab",
            onPressed: _toggleExpanded,
            backgroundColor: Theme.of(context).primaryColor,
            child: AnimatedRotation(
              turns: _isExpanded ? 0.125 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isExpanded ? Icons.close : Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
