import 'package:flutter/material.dart';

/// Czerwony radar-triangle.
/// mindPct -> góra, bodyPct -> prawa dolna, soulPct -> lewa dolna.
class PowerTriangle extends StatelessWidget {
  final int mindPct;
  final int bodyPct;
  final int soulPct;

  const PowerTriangle({
    super.key,
    required this.mindPct,
    required this.bodyPct,
    required this.soulPct,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2, // trochę wyższe niż szerokie
      child: CustomPaint(
        painter: _TrianglePainter(
          mindPct: mindPct,
          bodyPct: bodyPct,
          soulPct: soulPct,
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final int mindPct;
  final int bodyPct;
  final int soulPct;

  _TrianglePainter({
    required this.mindPct,
    required this.bodyPct,
    required this.soulPct,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final red = const Color(0xffc80032);
    final redSoft = const Color(0x66c80032);
    final stroke = Paint()
      ..color = red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = redSoft
      ..style = PaintingStyle.fill;

    // wierzchołki dużego trójkąta
    final top = Offset(size.width / 2, 0);
    final left = Offset(0, size.height);
    final right = Offset(size.width, size.height);

    // środek
    final center = Offset(
      (top.dx + left.dx + right.dx) / 3,
      (top.dy + left.dy + right.dy) / 3,
    );

    Offset interp(Offset v, int pct) {
      final t = pct.clamp(0, 100) / 100.0;
      return Offset(
        center.dx + (v.dx - center.dx) * t,
        center.dy + (v.dy - center.dy) * t,
      );
    }

    final pMind = interp(top, mindPct);
    final pBody = interp(right, bodyPct);
    final pSoul = interp(left, soulPct);

    // zewnętrzny trójkąt
    final outer = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(left.dx, left.dy)
      ..close();

    // wewnętrzny "radar"
    final inner = Path()
      ..moveTo(pMind.dx, pMind.dy)
      ..lineTo(pBody.dx, pBody.dy)
      ..lineTo(pSoul.dx, pSoul.dy)
      ..close();

    canvas.drawPath(inner, fillPaint);
    canvas.drawPath(outer, stroke);
    canvas.drawPath(inner, stroke);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.mindPct != mindPct ||
        oldDelegate.bodyPct != bodyPct ||
        oldDelegate.soulPct != soulPct;
  }
}

