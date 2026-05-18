import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

// ── Page 1: 3-hump kBg wave on top of dark hero ──────
// Painted in kBg so it masks the bottom of the cup.
// Light section rises UP into dark area in 3 smooth humps.
class BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = kBg;

    final path = Path();

    // Start: left edge at ~60% down
    path.moveTo(0, size.height * 0.60);

    // ── Hump 1 (left) ───────────────────────────────
    path.cubicTo(
      size.width * 0.07, size.height * 0.60,
      size.width * 0.12, size.height * 0.08,
      size.width * 0.25, size.height * 0.10,
    );
    path.cubicTo(
      size.width * 0.36, size.height * 0.12,
      size.width * 0.40, size.height * 0.62,
      size.width * 0.44, size.height * 0.62,
    );

    // ── Hump 2 (middle) ─────────────────────────────
    path.cubicTo(
      size.width * 0.48, size.height * 0.62,
      size.width * 0.53, size.height * 0.08,
      size.width * 0.63, size.height * 0.10,
    );
    path.cubicTo(
      size.width * 0.72, size.height * 0.12,
      size.width * 0.76, size.height * 0.62,
      size.width * 0.78, size.height * 0.62,
    );

    // ── Hump 3 (right) ──────────────────────────────
    path.cubicTo(
      size.width * 0.80, size.height * 0.62,
      size.width * 0.86, size.height * 0.08,
      size.width * 0.93, size.height * 0.12,
    );
    path.cubicTo(
      size.width * 0.97, size.height * 0.15,
      size.width * 1.00, size.height * 0.48,
      size.width * 1.00, size.height * 0.52,
    );

    // Fill downward to close
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Page 2: brown wave rising from bottom banner ──────
// kBrown fills from bottom up. Wave edge at the top
// creates the wavy transition between body and banner.
class TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kBrown
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(0, size.height);

    // ⬅
    path.lineTo(0, size.height * 0.35);

    // ── Wave 1 ─────────────
    path.cubicTo(
      size.width * 0.10, size.height * 0.15,
      size.width * 0.15, size.height * 0.55,
      size.width * 0.25, size.height * 0.35,
    );

    // ── Wave 2 (main) ─────
    path.cubicTo(
      size.width * 0.38, size.height * 0.05, // 
      size.width * 0.48, size.height * 0.65,
      size.width * 0.60, size.height * 0.35,
    );

    // ── Wave 3 ─────────────
    path.cubicTo(
      size.width * 0.75, size.height * 0.15,
      size.width * 0.90, size.height * 0.55,
      size.width, size.height * 0.35,
    );

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
// ── Pages 3 & 4: brown wave at top header ─────────────
class WaveHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = kBrown;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 1.1,
        size.width * 0.4,
        size.height * 0.78,
      )
      ..quadraticBezierTo(
        size.width * 0.65,
        size.height * 0.42,
        size.width * 0.8,
        size.height * 0.88,
      )
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height * 1.15,
        size.width,
        size.height * 0.75,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}