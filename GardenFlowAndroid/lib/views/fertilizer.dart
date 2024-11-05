import 'package:flutter/material.dart';
import 'package:garden_flow/utility/app_colors.dart';
import 'package:garden_flow/utility/toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math' as math;

class FertilizerPump extends StatefulWidget {
  const FertilizerPump({super.key});

  @override
  State<FertilizerPump> createState() => _FertilizerPump();
}

class _FertilizerPump extends State<FertilizerPump> {
  double percentage = 50.0;
  Stream<DatabaseEvent> _stream = FirebaseDatabase.instance.ref("/sensors").onValue;

  @override
  void initState() {
    super.initState();

    DatabaseReference ref = FirebaseDatabase.instance.ref("/sensors");
    _stream = ref.onValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Fertilizer Control'),
        backgroundColor: AppColors.accentColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            DataSnapshot data = snapshot.data!.snapshot;
            Map<dynamic, dynamic> sensorValues = data.value as Map<dynamic, dynamic>;
            int newPercentage = sensorValues['soil-moisture'] as int;
            percentage = newPercentage.toDouble();
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.plumbing_sharp),
                const Text(
                  'Fertilizer Pump',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentColor,
                  ),
                ),
                const SizedBox(height: 50),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (sensorValues['mist-open'].toString() == "true") {
                        Toast.show(context, "Fertilizer is already open!");
                      } else {
                        updateMistStatus("true");
                        Toast.show(context, "Sending command to open fertilizer.");
                      }
                    },
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all<Size>(const Size(260, 60)),
                      backgroundColor: WidgetStateProperty.all<Color>(AppColors.accentColor),
                      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                    ),
                    child: const Text('Turn On'),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (sensorValues['mist-open'].toString() == "false") {
                      Toast.show(context, "Fertilizer is already close!");
                    } else {
                      updateMistStatus("false");
                      Toast.show(context, "Sending command to close fertilizer.");
                    }
                  },
                  style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all<Size>(const Size(260, 60)),
                    backgroundColor: WidgetStateProperty.all<Color>(AppColors.accentColor),
                    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Text('Turn Off'),
                ),
                const SizedBox(height: 16.0),
              ],
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
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

void updateMistStatus(String isOpen) {
  DatabaseReference ref = FirebaseDatabase.instance.ref("/sensors/mist-open");
  ref.set(isOpen);
}
