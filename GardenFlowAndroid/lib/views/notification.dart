import 'package:flutter/material.dart';
import 'package:garden_flow/utility/app_colors.dart';
import 'package:garden_flow/utility/toast.dart';
import 'package:garden_flow/utility/local_notification.dart';
import 'dart:math' as math;

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPage();
}

class _NotificationPage extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: const Text('Weather App'),
          backgroundColor: AppColors.accentColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              if (await LocalNotification.isAlreadyInitializeScheduled()) {
                LocalNotification.clearNotification();
                Toast.show(context, "Notification has been disabled");
              } else {
                LocalNotification.showScheduledNotification(message: "It's time to water your plant", hour: 5, channel: 0);
                LocalNotification.showScheduledNotification(message: "It's time to water your plant", hour: 9, channel: 1);
                LocalNotification.showScheduledNotification(message: "It's time to water your plant", hour: 13, channel: 2);
                LocalNotification.showScheduledNotification(message: "It's time to water your plant", hour: 17, channel: 3);
                Toast.show(context, "Notification has been enabled");
              }
            },
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all<Size>(const Size(260, 60)),
              backgroundColor: WidgetStateProperty.all<Color>(AppColors.accentColor),
              foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            ),
            child: const Text('Enable/Disable Notification'),
          ),
        ));
  }
}

class CircularPercentageBar extends StatelessWidget {
  final double percentage;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final TextStyle valueTextStyle;

  const CircularPercentageBar({
    Key? key,
    required this.percentage,
    this.strokeWidth = 10.0,
    this.backgroundColor = Colors.grey,
    this.progressColor = AppColors.primaryColor,
    this.valueTextStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.accentColor,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CircularPercentageBarPainter(
        percentage: percentage,
        strokeWidth: strokeWidth,
        backgroundColor: backgroundColor,
        progressColor: progressColor,
      ),
      child: Center(
        child: Text(
          '${percentage.toStringAsFixed(0)}%',
          style: valueTextStyle,
        ),
      ),
    );
  }
}

class _CircularPercentageBarPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  _CircularPercentageBarPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 70.0;
    const double startAngle = -math.pi / 2;
    final double sweepAngle = 2 * math.pi * (percentage / 100);

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Percentage bar
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
