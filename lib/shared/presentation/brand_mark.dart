import 'package:material_ui/material_ui.dart';

/// Three stacked ledger leaves, shared with the platform launcher artwork.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 39});
  final double size;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: const _MarkPainter());
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 42);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 42, 42),
        const Radius.circular(11),
      ),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6586FF), Color(0xFF3C57D6)],
        ).createShader(const Rect.fromLTWH(0, 0, 42, 42)),
    );
    for (final (y, color) in [
      (25.0, const Color(0xFFB8C8FF)),
      (19.5, const Color(0xFFD4DFFF)),
      (14.0, Colors.white),
    ]) {
      final path = Path()
        ..moveTo(8.5, y + 2)
        ..lineTo(21, y - 4.8)
        ..lineTo(33.5, y + 2)
        ..lineTo(21, y + 8.8)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => false;
}
