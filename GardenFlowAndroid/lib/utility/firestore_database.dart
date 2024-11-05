import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:garden_flow/utility/toast.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userCollection = 'users';
  final String _imeiCollection = 'imei';

  Future<List<Map<String, dynamic>>> getLogs() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('logs').get();

      List<Map<String, dynamic>> logs = snapshot.docs.map((doc) => doc.data()).toList();
      return logs;
    } catch (e) {
      print('Error retrieving logs: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>?> getIMEIList() async {
    try {
      final snapshot = await _firestore.collection(_imeiCollection).get();

      if (snapshot.size > 0) {
        final List<Map<String, dynamic>> dataList = [];
        for (var document in snapshot.docs) {
          dataList.add({
            'id': document.id,
            ...document.data(),
          });
        }
        print(dataList);
        return dataList;
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving user information: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserInfoByUUID(String uuid) async {
    try {
      final snapshot = await _firestore.collection(_userCollection).where('uuid', isEqualTo: uuid).get();
      if (snapshot.size > 0) {
        final userDocument = snapshot.docs.first.data();
        return userDocument;
      } else {
        print('User not found');
        return null;
      }
    } catch (e) {
      print('Error retrieving user information: $e');
      return null;
    }
  }

  Future<bool> signUp(String email, String password, String mobileNumber, String firstName, String lastName) async {
    // Create user in Firebase Authentication
    final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get the generated user ID
    final String userId = userCredential.user!.uid;

    // Create user document in Firestore
    final result = await _firestore.collection(_userCollection).add({'first-name': firstName, 'last-name': lastName, 'mobile-number': mobileNumber, 'email': email, 'uuid': userId, 'image-link': "https://pbs.twimg.com/media/FjU2lkcWYAgNG6d.jpg", 'type': "utility", 'status': "pending"});

    if (result.id.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> logSensors(SensorValues sensorValues, WeatherValues weatherValues) async {
    final result = await _firestore.collection("logs").add({
      'date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
      'time': DateFormat('h:mm a').format(DateTime.now()),
      'sensor-values': {'soilMoisture': sensorValues.soilMoisture, 'temperature': sensorValues.temperature, 'humidity': sensorValues.humidity, 'rain': sensorValues.rain, 'waterLevel': sensorValues.waterLevel, 'ph': sensorValues.ph},
      'uuid': Credentials.uuid,
      'first-name': Credentials.firstName,
      'last-name': Credentials.lastName,
      'mobile-number': Credentials.mobileNumber,
      'email': Credentials.email,
      'weather-values': {
        'temperature': weatherValues.temperature,
        'wind-speed': weatherValues.windSpeed,
        'humidity': weatherValues.humidity,
        'city': weatherValues.city,
      }
    });

    if (result.id.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<String> forgotPassword(BuildContext context) async {
    try {
      StringBuffer emailContent = StringBuffer();

      emailContent.write('<a href="https://google.com">');
      emailContent.write('Click to change your password');
      emailContent.write('</a>');

      String formattedEmailContent = '''
      <html>
      <body>
      <h2>Forgot Password</h2>
      ${emailContent.toString()}
      <hr>
      <p>This is an automated email. Please do not reply.</p>
      </body>
      </html>
      ''';
      return formattedEmailContent;
    } catch (e) {
      print('Error retrieving logs: $e');
      Toast.show(context, "$e");
      return '';
    }
  }

  Future<String> getEmailContent() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('logs').orderBy('date', descending: true).get();

      List<Map<String, dynamic>> logs = snapshot.docs.map((doc) => doc.data()).toList();

      StringBuffer emailContent = StringBuffer();

      emailContent.write('<table style="border-collapse: collapse;">');
      emailContent.write('<tr>');
      emailContent.write('<th style="border: 1px solid black; padding: 8px;">Name</th>');
      emailContent.write('<th style="border: 1px solid black; padding: 8px;">Email</th>');
      emailContent.write('<th style="border: 1px solid black; padding: 8px;">Date</th>');
      emailContent.write('<th style="border: 1px solid black; padding: 8px;">Time</th>');
      emailContent.write('<th style="border: 1px solid black; padding: 8px;">Sensor Values</th>');
      emailContent.write('<th style="border: 1px solid black; padding: 8px;">Weather Readings</th>');
      emailContent.write('</tr>');

      logs.forEach((log) {
        emailContent.write('<tr>');
        emailContent.write('<td style="border: 1px solid black; padding: 8px;">${log['first-name']} ${log['last-name']}</td>');
        emailContent.write('<td style="border: 1px solid black; padding: 8px;">${log['email']}</td>');
        emailContent.write('<td style="border: 1px solid black; padding: 8px;">${log['date']}</td>');
        emailContent.write('<td style="border: 1px solid black; padding: 8px;">${log['time']}</td>');
        emailContent.write('<td style="border: 1px solid black; padding: 8px;">');
        emailContent.write('<b>Soil Moisture:</b> ${log['sensor-values']['soilMoisture']}%<br>');
        emailContent.write('<b>Temperature:</b> ${log['sensor-values']['temperature']}°C<br>');
        emailContent.write('<b>Humidity:</b> ${log['sensor-values']['humidity']}%RH<br>');
        emailContent.write('<b>Rain:</b> ${log['sensor-values']['rain']}%<br>');
        emailContent.write('<b>Water Level:</b> ${log['sensor-values']['waterLevel']}cm<br>');
        emailContent.write('<b>pH Level:</b> ${log['sensor-values']['ph']}<br>');
        emailContent.write('</td>');
        emailContent.write('<td style="border: 1px solid black; padding: 8px;">');
        emailContent.write('<b>City:</b> ${log['weather-values']['city']}<br>');
        emailContent.write('<b>Humidity:</b> ${log['weather-values']['humidity']}%RH<br>');
        emailContent.write('<b>Temperature:</b> ${log['weather-values']['temperature']}°C<br>');
        emailContent.write('<b>Wind Speed:</b> ${log['weather-values']['wind-speed']}km/h<br>');
        emailContent.write('</td>');
        emailContent.write('</tr>');
      });

      emailContent.write('</table>');

      String formattedEmailContent = '''
<html>
<body>
<h2>Log Details</h2>
${emailContent.toString()}
<p>Thank you for your attention.</p>
<hr>
<p>This is an automated email. Please do not reply.</p>
</body>
</html>
''';

      return formattedEmailContent;
    } catch (e) {
      print('Error retrieving logs: $e');
      return '';
    }
  }

  Future<bool> changePassword(String newPassword) async {
    // Create user in Firebase Authentication

    // Create user document in Firestore
    final result = await _firestore.collection(_userCollection).add({'first-name': newPassword});

    if (result.id.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}

class SensorValues {
  String soilMoisture, temperature, humidity, rain, waterLevel, ph;

  SensorValues(this.soilMoisture, this.temperature, this.humidity, this.rain, this.waterLevel, this.ph);
}

class WeatherValues {
  String temperature, city, humidity, windSpeed;

  WeatherValues(this.temperature, this.city, this.humidity, this.windSpeed);
}

class Credentials {
  static String? uuid;
  static String? firstName;
  static String? mobileNumber;
  static String? lastName;
  static String? email;
}
