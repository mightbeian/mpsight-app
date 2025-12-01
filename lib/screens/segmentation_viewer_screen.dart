/// Segmentation Viewer Screen
/// Interactive visualization of lesion segmentation results

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/segmentation_result.dart';

class SegmentationViewerScreen extends StatefulWidget {
  final SegmentationResult segmentation;
  final ui.Image? originalImage;

  const SegmentationViewerScreen({
    super.key,
    required this.segmentation,
    this.originalImage,
  });

  @override
  State<SegmentationViewerScreen> createState() =>
      _SegmentationViewerScreenState();
}

class _SegmentationViewerScreenState extends State<SegmentationViewerScreen> {
  bool _showOverlay = true;
  bool _showBoundingBoxes = true;
  double _overlayOpacity = 0.5;
  SegmentedLesion? _selectedLesion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Segmentation Analysis'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_showOverlay ? Icons.layers : Icons.layers_outlined),
            onPressed: () => setState(() => _showOverlay = !_showOverlay),
            tooltip: 'Toggle Overlay',
          ),
          IconButton(
            icon: Icon(_showBoundingBoxes
                ? Icons.crop_square
                : Icons.crop_square_outlined),
            onPressed: () =>
                setState(() => _showBoundingBoxes = !_showBoundingBoxes),
            tooltip: 'Toggle Bounding Boxes',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: _buildImageViewer(),
          ),
          _buildOpacitySlider(),
          Expanded(
            flex: 2,
            child: _buildLesionList(),
          ),
        ],
      ),
      bottomNavigationBar: _buildSummaryBar(),
    );
  }

  Widget _buildImageViewer() {
    return GestureDetector(
      onTapUp: _handleImageTap,
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: CustomPaint(
          size: Size(
            widget.segmentation.imageSize.width,
            widget.segmentation.imageSize.height,
          ),
          painter: SegmentationPainter(
            segmentation: widget.segmentation,
            showOverlay: _showOverlay,
            showBoundingBoxes: _showBoundingBoxes,
            overlayOpacity: _overlayOpacity,
            selectedLesion: _selectedLesion,
          ),
        ),
      ),
    );
  }

  Widget _buildOpacitySlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('Overlay Opacity:'),
          Expanded(
            child: Slider(
              value: _overlayOpacity,
              min: 0.0,
              max: 1.0,
              onChanged: (value) => setState(() => _overlayOpacity = value),
            ),
          ),
          Text('${(_overlayOpacity * 100).toInt()}%'),
        ],
      ),
    );
  }

  Widget _buildLesionList() {
    final lesions = widget.segmentation.lesionsBySize;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Detected Lesions (${lesions.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: lesions.length,
              itemBuilder: (context, index) {
                final lesion = lesions[index];
                final isSelected = _selectedLesion?.id == lesion.id;

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  title: Text('Lesion #${index + 1}'),
                  subtitle: Text(
                    'Area: ${lesion.areaPixels}px² • '
                    'Confidence: ${(lesion.confidence * 100).toStringAsFixed(1)}%',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${lesion.areaPercentage.toStringAsFixed(2)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Circularity: ${lesion.circularity.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onTap: () => setState(() {
                    _selectedLesion = isSelected ? null : lesion;
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              'Total Lesions',
              widget.segmentation.lesionCount.toString(),
            ),
            _buildSummaryItem(
              'Affected Area',
              '${widget.segmentation.totalAffectedAreaPercent.toStringAsFixed(2)}%',
            ),
            _buildSummaryItem(
              'Confluence',
              '${(widget.segmentation.confluenceScore * 100).toStringAsFixed(1)}%',
            ),
            _buildSummaryItem(
              'Regions',
              widget.segmentation.lesionsByRegion.length.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  void _handleImageTap(TapUpDetails details) {
    // Check if tap is within any lesion bounding box
    final localPosition = details.localPosition;

    for (final lesion in widget.segmentation.lesions) {
      if (lesion.boundingBox.contains(localPosition)) {
        setState(() => _selectedLesion = lesion);
        return;
      }
    }

    setState(() => _selectedLesion = null);
  }
}

class SegmentationPainter extends CustomPainter {
  final SegmentationResult segmentation;
  final bool showOverlay;
  final bool showBoundingBoxes;
  final double overlayOpacity;
  final SegmentedLesion? selectedLesion;

  SegmentationPainter({
    required this.segmentation,
    required this.showOverlay,
    required this.showBoundingBoxes,
    required this.overlayOpacity,
    this.selectedLesion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background placeholder
    final bgPaint = Paint()..color = Colors.grey.shade200;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bgPaint,
    );

    // Draw "Original Image" text placeholder
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Original Image\n${size.width.toInt()} × ${size.height.toInt()}',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    // Draw segmentation overlay
    if (showOverlay && segmentation.lesions.isNotEmpty) {
      final overlayPaint = Paint()
        ..color = Colors.red.withOpacity(overlayOpacity)
        ..style = PaintingStyle.fill;

      for (final lesion in segmentation.lesions) {
        canvas.drawOval(lesion.boundingBox, overlayPaint);
      }
    }

    // Draw bounding boxes
    if (showBoundingBoxes) {
      for (final lesion in segmentation.lesions) {
        final isSelected = selectedLesion?.id == lesion.id;
        final boxPaint = Paint()
          ..color = isSelected ? Colors.blue : Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 3 : 1;

        canvas.drawRect(lesion.boundingBox, boxPaint);

        // Draw centroid
        final centroidPaint = Paint()
          ..color = isSelected ? Colors.blue : Colors.green
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          lesion.centroid,
          isSelected ? 6 : 4,
          centroidPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(SegmentationPainter oldDelegate) {
    return showOverlay != oldDelegate.showOverlay ||
        showBoundingBoxes != oldDelegate.showBoundingBoxes ||
        overlayOpacity != oldDelegate.overlayOpacity ||
        selectedLesion != oldDelegate.selectedLesion;
  }
}
