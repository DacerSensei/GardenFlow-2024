import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:garden_flow/utility/app_colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:garden_flow/utility/firestore_database.dart';
import 'package:garden_flow/utility/toast.dart';
import 'package:garden_flow/utility/weather_api.dart';

class SensorData extends StatefulWidget {
  const SensorData({super.key});
  @override
  State<SensorData> createState() => _SensorData();
}

class _SensorData extends State<SensorData> {
  final List<String> sensorValues = ["100", "100", "100", "100", "100"];

  Stream<DatabaseEvent> _stream = FirebaseDatabase.instance.ref("/sensors").onValue;

  String phValueToString(String stringValue) {
    double value = double.parse(stringValue);
    if (value < 4) {
      return "Very Acidic";
    } else if (value > 4 && value < 6.5) {
      return "Acidic";
    } else if (value > 6.5 && value < 8) {
      return "Neutral";
    } else if (value > 8 && value < 11) {
      return "Alkaline";
    } else if (value >= 11) {
      return "Very Alkaline";
    } else {
      return "";
    }
  }

  @override
  void initState() {
    super.initState();
    DatabaseReference ref = FirebaseDatabase.instance.ref("/sensors");
    _stream = ref.onValue;

    ref.once().then((DatabaseEvent snapshot) async {
      var sensorData = snapshot.snapshot.value as Map<dynamic, dynamic>;

      SensorValues sensorValues = SensorValues(sensorData['soil-moisture'].toString(), sensorData['temperature'].toString(), sensorData['humidity'].toString(),
          sensorData['rain'].toString(), sensorData['water-level'].toString(), sensorData['ph'].toString());

      WeatherApiClient weatherAPI = new WeatherApiClient();
      Map<String, dynamic> weatherData = await weatherAPI.getCurrentWeather();
      WeatherValues weatherValues = WeatherValues(weatherData['current']['temp_c'].toString(), weatherData['location']['name'].toString(),
          weatherData['current']['humidity'].toString(), weatherData['current']['wind_kph'].toString());
      final firestoreService = FirestoreService();
      firestoreService.logSensors(sensorValues, weatherValues);
    }).catchError((error) {
      log(error.message);
      Toast.show(context, "Error: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: const Text('Sensors'), backgroundColor: AppColors.accentColor, foregroundColor: Colors.white),
      body: Center(
        child: SizedBox(
          width: 350,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sensor Values',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.accentColor),
                ),
                const SizedBox(height: 16.0),
                StreamBuilder<DatabaseEvent>(
                  stream: _stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      DataSnapshot data = snapshot.data!.snapshot;
                      Map<dynamic, dynamic> sensorValues = data.value as Map<dynamic, dynamic>;
                      return Column(
                        children: [
                          SensorCard(
                            sensorName: 'Soil Moisture',
                            sensorValue: '${sensorValues['soil-moisture'].toString()} %',
                            sensorIcon: Icons.landscape,
                          ),
                          SensorCard(
                            sensorName: 'Temperature',
                            sensorValue: '${sensorValues['temperature'].toString()}°C',
                            sensorIcon: Icons.thermostat,
                          ),
                          SensorCard(
                            sensorName: 'Humidity',
                            sensorValue: '${sensorValues['humidity'].toString()} %',
                            sensorIcon: Icons.air,
                          ),
                          SensorCard(
                            sensorName: 'Rain',
                            sensorValue: '${sensorValues['rain'].toString()} %',
                            sensorIcon: Icons.cloud,
                          ),
                          SensorCard(
                            sensorName: 'Water Level',
                            sensorValue: '${sensorValues['water-level'].toString()}cm',
                            sensorIcon: Icons.water,
                          ),
                          SensorCard(
                            sensorName: 'pH',
                            sensorValue: '${sensorValues['ph']} ${phValueToString(sensorValues['ph'])}',
                            sensorIcon: Icons.water_drop,
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all<Size>(const Size(200, 60)),
                    backgroundColor: WidgetStateProperty.all<Color>(AppColors.accentColor),
                    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Text('Back'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SensorCard extends StatelessWidget {
  final String sensorName;
  final String sensorValue;
  final IconData sensorIcon;

  const SensorCard({
    super.key,
    required this.sensorName,
    required this.sensorValue,
    required this.sensorIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: AppColors.tertiaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  sensorIcon,
                  size: 32.0,
                  color: AppColors.accentColor,
                ),
                const SizedBox(width: 10),
                Text(
                  sensorName,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Expanded(
                  child: SizedBox(width: 10),
                ),
                Text(
                  sensorValue,
                  style: const TextStyle(fontSize: 16.0, color: AppColors.accentColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
