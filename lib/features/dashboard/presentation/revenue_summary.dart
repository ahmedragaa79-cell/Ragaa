import 'package:material_ui/material_ui.dart';

import '../../../app/localization/localization.dart';
import '../../../core/widgets/surface.dart';

class RevenueSummary extends StatelessWidget {
  const RevenueSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [Color(0xFF1F3258), Color(0xFF14213C), Color(0xFF202E50)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: _Blueprint())),
            Positioned.fill(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FractionallySizedBox(
                  widthFactor: .48,
                  heightFactor: .97,
                  child: Image.asset(
                    'assets/art/ledger-study.webp',
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 23, 18, 21),
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: .68,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF9AB6FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Eyebrow(
                            l.summaryLabel,
                            color: const Color(0xFFBECFF7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.totalRevenue,
                          style: const TextStyle(
                            color: Color(0xFFDCE6FA),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            l.revenueUnavailable,
                            style: const TextStyle(
                              fontSize: 34,
                              color: Colors.white,
                              height: 1.2,
                              letterSpacing: -.5,
                              fontWeight: FontWeight.w700,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 21),
                    Text(
                      l.revenueUnavailableHint,
                      style: const TextStyle(
                        color: Color(0xFFCFDCF4),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blueprint extends CustomPainter {
  const _Blueprint();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x1AB3CAFF);
    for (double x = 12; x < size.width; x += 17) {
      for (double y = 11; y < size.height; y += 17) {
        canvas.drawCircle(Offset(x, y), .7, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_Blueprint oldDelegate) => false;
}
