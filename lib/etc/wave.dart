import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = const Color(0xFFf1f5f9).withOpacity(1.0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint0Fill);

    Path path_1 = Path();
    path_1.moveTo(0, 235);
    path_1.lineTo(24, 254.8);
    path_1.cubicTo(48, 274.7, 96, 314.3, 144, 316.2);
    path_1.cubicTo(192, 318, 240, 282, 288, 273.2);
    path_1.cubicTo(336, 264.3, 384, 282.7, 432, 304.5);
    path_1.cubicTo(480, 326.3, 528, 351.7, 576, 359.3);
    path_1.cubicTo(624, 367, 672, 357, 696, 352);
    path_1.lineTo(720, 347);
    path_1.lineTo(720, 0);
    path_1.lineTo(696, 0);
    path_1.cubicTo(672, 0, 624, 0, 576, 0);
    path_1.cubicTo(528, 0, 480, 0, 432, 0);
    path_1.cubicTo(384, 0, 336, 0, 288, 0);
    path_1.cubicTo(240, 0, 192, 0, 144, 0);
    path_1.cubicTo(96, 0, 48, 0, 24, 0);
    path_1.lineTo(0, 0);
    path_1.close();

    Paint paint1Fill = Paint()..style = PaintingStyle.fill;
    paint1Fill.color = const Color(0xffff9800).withOpacity(1.0);
    canvas.drawPath(path_1, paint1Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
