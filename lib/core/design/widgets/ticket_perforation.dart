import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';

/// The ticket's perforation: a dashed line with a notch at each edge, each
/// notch filled with the screen background (DESIGN_SYSTEM §3 "Ticket
/// notch"). Symmetric, so it needs no RTL handling.
class TicketPerforation extends StatelessWidget {
  const TicketPerforation({
    super.key,
    required this.lineColor,
    required this.notchColor,
  });

  final Color lineColor;
  final Color notchColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TesskraSizes.ticketNotchDiameter,
      child: CustomPaint(
        painter: _PerforationPainter(
          lineColor: lineColor,
          notchColor: notchColor,
        ),
      ),
    );
  }
}

class _PerforationPainter extends CustomPainter {
  _PerforationPainter({required this.lineColor, required this.notchColor});

  final Color lineColor;
  final Color notchColor;

  @override
  void paint(Canvas canvas, Size size) {
    const radius = TesskraSizes.ticketNotchDiameter / 2;
    final y = size.height / 2;
    final line = Paint()
      ..color = lineColor
      ..strokeWidth = TesskraBorders.standard;
    var x = radius + TesskraSpacing.s1;
    while (x < size.width - radius - TesskraSpacing.s1) {
      final end = (x + TesskraBorders.dashLength).clamp(
        x,
        size.width - radius - TesskraSpacing.s1,
      );
      canvas.drawLine(Offset(x, y), Offset(end, y), line);
      x += TesskraBorders.dashLength + TesskraBorders.dashGap;
    }
    final notch = Paint()..color = notchColor;
    canvas
      ..drawCircle(Offset(0, y), radius, notch)
      ..drawCircle(Offset(size.width, y), radius, notch);
  }

  @override
  bool shouldRepaint(_PerforationPainter old) =>
      old.lineColor != lineColor || old.notchColor != notchColor;
}
