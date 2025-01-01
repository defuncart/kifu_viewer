import 'package:app_store_screenshots/app_store_screenshots.dart';
import 'package:flutter/material.dart';
import 'package:kifu_viewer/theme/app_themes.dart';

void main() {
  generateAppIcon(
    onBuildIcon: (size) => AppIcon(size: size),
  );

  generateAppIconMacOS(
    onBuildIcon: (size) => AppIcon(size: size),
  );
}

class AppIcon extends StatelessWidget {
  const AppIcon({
    required this.size,
    super.key,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: AppThemes.light.colorScheme.primary,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size * 0.713, size * 0.678),
            painter: ShogiCustomPainter(
              color: Colors.white,
            ),
          ),
          Positioned(
            top: size * 0.35,
            child: Text(
              'Kifu\nViewer',
              style: TextStyle(
                fontSize: size * 0.15,
                fontStyle: FontStyle.italic,
                color: Colors.white,
                height: 1.25,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class ShogiCustomPainter extends CustomPainter {
  const ShogiCustomPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(size.width * 0.094, size.height * 0.173)
      ..lineTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.906, size.height * 0.173)
      ..close();

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.015
      ..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
