import 'package:material_ui/material_ui.dart';

import '../../../app/localization/localization.dart';
import '../../../core/widgets/surface.dart';
import '../../../shared/domain/revenue.dart';

class RevenueSummary extends StatelessWidget {
  const RevenueSummary({super.key, required this.total});
  final LedgerAmount total;

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
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) => const RadialGradient(
                      radius: .75,
                      colors: [Colors.white, Colors.white, Colors.transparent],
                      stops: [0, .6, 1],
                    ).createShader(rect),
                    child: Image.asset(
                      'assets/art/ledger-study.webp',
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
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
                            context.formats.amount(total),
                            style: const TextStyle(
                              fontSize: 53,
                              color: Colors.white,
                              height: 1.2,
                              letterSpacing: -2.5,
                              fontWeight: FontWeight.w700,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 21),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _Scope(Icons.storefront_outlined, l.allOutlets),
                        _Scope(Icons.schedule_rounded, l.allTime),
                      ],
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

class _Scope extends StatelessWidget {
  const _Scope(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: const Color(0xFFB4C5E8)),
      const SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFFCFDCF4),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
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
