import 'package:garden_flow/utility/firestore_database.dart';
import 'package:garden_flow/utility/firebase_auth.dart';
import 'package:garden_flow/utility/weather_api.dart';

import 'package:garden_flow/views/dashboard.dart';
import 'package:garden_flow/views/login.dart';

import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTree();
}

class _WidgetTree extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show a loading indicator while waiting
          }

          if (snapshot.hasData) {
            final firestoreService = FirestoreService();
            final uuid = snapshot.data!.uid;
            return FutureBuilder(
                future: firestoreService.getUserInfoByUUID(uuid),
                builder: (context, userInfoSnapshot) {
                  if (userInfoSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final userInfo = userInfoSnapshot.data!;
                  String firstName, lastName, mobileNumber, imageLink, email, type, status;
                  firstName = userInfo['first-name'];
                  lastName = userInfo['last-name'];
                  mobileNumber = userInfo['mobile-number'];
                  imageLink = userInfo['image-link'];
                  email = userInfo['email'];
                  type = userInfo['type'];
                  status = userInfo['status'];

                  if (type.toLowerCase() != "utility") {
                    return const LoginPage();
                  }

                  if (status.toLowerCase() == "pending") {
                    return const LoginPage();
                  } else if (status.toLowerCase() == "rejected") {
                    return const LoginPage();
                  }

                  Credentials.email = email;
                  Credentials.firstName = firstName;
                  Credentials.mobileNumber = mobileNumber;
                  Credentials.lastName = lastName;
                  Credentials.uuid = uuid;

                  return FutureBuilder<Map<String, dynamic>>(
                    future: WeatherApiClient().getCurrentWeather(),
                    builder: (context, weatherSnapshot) {
                      if (weatherSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final weatherData = weatherSnapshot.data!;
                      double temperature = weatherData['current']['temp_c'];
                      int humidity = weatherData['current']['humidity'];
                      double windSpeed = weatherData['current']['wind_kph'];
                      String location = weatherData['location']['name'];
                      String weatherIconUrl = 'http:${weatherData['current']['condition']['icon']}';

                      return DashboardPage(
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        imageLink: imageLink,
                        temperature: temperature,
                        humidity: humidity,
                        windSpeed: windSpeed,
                        weatherIconUrl: weatherIconUrl,
                        location: location,
                      );
                    },
                  );
                });
          } else {
            return const LoginPage();
          }
        });
  }
}
