import 'package:flutter/material.dart';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:garden_flow/utility/app_colors.dart';
import 'package:garden_flow/utility/toast.dart';
import 'package:garden_flow/utility/firestore_database.dart';
import 'package:garden_flow/utility/firebase_auth.dart';

import 'package:garden_flow/views/water_pump.dart';
import 'package:garden_flow/views/sensor_data.dart';
import 'package:garden_flow/views/fertilizer.dart';
import 'package:garden_flow/views/notification.dart';
import 'package:garden_flow/views/about.dart';
import 'package:garden_flow/views/change_password.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage(
      {super.key,
      required this.firstName,
      required this.lastName,
      required this.imageLink,
      required this.email,
      required this.temperature,
      required this.humidity,
      required this.windSpeed,
      required this.weatherIconUrl,
      required this.location});

  final double temperature;
  final int humidity;
  final double windSpeed;
  final String weatherIconUrl;
  final String location;
  final String firstName;
  final String lastName;
  final String imageLink;
  final String email;

  @override
  State<DashboardPage> createState() => _DashboardPage();
}

class _DashboardPage extends State<DashboardPage> {
  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: const Text('Garden Monitoring'),
          backgroundColor: AppColors.accentColor,
          foregroundColor: Colors.white,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const SizedBox(height: 80),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      widget.imageLink,
                    ),
                  ),
                  Text(widget.email),
                  Text('${widget.firstName} ${widget.lastName}'),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.password),
                title: const Text('Change Password'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Request Logs'),
                onTap: () async {
                  FirestoreService firestoreService = FirestoreService();
                  String content = await firestoreService.getEmailContent();
                  sendEmail(content);
                  Toast.show(context, 'Sensor access logs has been sent to ${Credentials.email}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await signOut();
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
          const SizedBox(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                  color: AppColors.tertiaryColor,
                  elevation: 2,
                  child: Padding(
                      padding: EdgeInsets.only(left: 80, right: 80, bottom: 20),
                      child: Column(children: [
                        Image.network(
                          widget.weatherIconUrl,
                          width: 160,
                          height: 160,
                          fit: BoxFit.fill,
                        ),
                        Text(
                          '${widget.temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.location,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        )
                      ]))),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.water,
                            size: 32,
                            color: AppColors.accentColor,
                          ),
                          Text(
                            '${widget.humidity}%',
                            style: const TextStyle(fontSize: 32, color: AppColors.accentColor),
                          )
                        ],
                      ),
                      const Text(
                        'Humidity',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.air,
                            size: 32,
                            color: AppColors.accentColor,
                          ),
                          Text(
                            '${widget.windSpeed.toStringAsFixed(1)} km/h',
                            style: const TextStyle(fontSize: 32, color: AppColors.accentColor),
                          )
                        ],
                      ),
                      const Text(
                        'Wind Speed',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              GridButton()
            ],
          ),
        ]))));
  }
}

class GridButton extends StatefulWidget {
  const GridButton({super.key});

  @override
  State<GridButton> createState() => _GridButton();
}

class _GridButton extends State<GridButton> {
  final List<Map<String, dynamic>> cardsButton = [
    {"title": "Sensor Data", "image": "resources/remote.png", "page": SensorData()},
    {"title": "Water Pump Control", "image": "resources/pump.png", "page": WaterPump()},
    {"title": "Fertilizer Control", "image": "resources/fertilizer.png", "page": FertilizerPump()},
    {"title": "Notification", "image": "resources/notification.png", "page": NotificationPage()},
    {"title": "About", "image": "resources/info.png", "page": AboutPage()}
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: cardsButton.length,
        itemBuilder: (_, index) {
          return GestureDetector(
              onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => cardsButton.elementAt(index)["page"]),
                    )
                  },
              child: Card(
                elevation: 2,
                color: AppColors.tertiaryColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                      child: Image.asset(
                        "${cardsButton.elementAt(index)['image']}",
                        alignment: Alignment.center,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("${cardsButton.elementAt(index)['title']}", style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(
                            height: 8.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
        });
  }
}

void sendEmail(String text) async {
  String username = 'pamantasanp@gmail.com';
  String password = 'kwujqwwymwqolovi';

  final smtpServer = gmail(username, password);

  final message = Message()
    ..from = Address(username, 'Watering System')
    ..recipients.add(Credentials.email)
    ..subject = 'Sensor Access Logs'
    ..html = text;

  try {
    await send(message, smtpServer);
  } catch (e) {
    print('Error sending email: $e');
  }
}
