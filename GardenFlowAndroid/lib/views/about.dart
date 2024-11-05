import 'package:flutter/material.dart';
import 'package:garden_flow/utility/app_colors.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});
  @override
  State<AboutPage> createState() => _AboutPage();
}

class _AboutPage extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: const Text('About'), backgroundColor: AppColors.accentColor, foregroundColor: Colors.white),
      body: Center(
        child: SizedBox(
          width: 350,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GridAbout(),
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

class GridAbout extends StatefulWidget {
  const GridAbout({super.key});

  @override
  State<GridAbout> createState() => _GridAbout();
}

class _GridAbout extends State<GridAbout> {
  final List<Map<String, dynamic>> cardsInstruction = [
    {
      "title": "Download APK",
      "description":
          "To download the application, make sure you use android phone then visit any browser, search for https://plpwateringsystem.we bsite, tap 'Install' to begin the download process."
    },
    {
      "title": "Unique Identifier",
      "description":
          "After installing the app, the unique identifier displayed within the application and proceed to register it with the admin to gain access and utilize the application's login and signup"
    },
    {
      "title": "Login Page",
      "description":
          "Once you've registered the unique identifier, create a user account by selecting 'Sign Up,' subsequently enabling login access, and also have a feature such as activating or deactivating watering notifications within the application and reset password."
    },
    {
      "title": "Main Page",
      "description":
          "After creating your account, the admin can accept and reject your request account if the admin accept the requestyou can access the main page of the mobile application where you'll find options for user settings, weather map monitoring, sensor values monitoring, water pump control, misting pump control, and roof control functionalities available for use."
    },
    {
      "title": "User Settings",
      "description":
          "In the user settings, you can change your account password, generate sensor and weather values, and conveniently log out upon completing your usage of the application "
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
        itemCount: cardsInstruction.length,
        itemBuilder: (_, index) {
          return Card(
              elevation: 2,
              color: AppColors.tertiaryColor,
              child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        cardsInstruction.elementAt(index)["title"],
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(height: 5), // Spacing between the texts
                      Text(
                        cardsInstruction.elementAt(index)["description"],
                        style: TextStyle(fontSize: 14),
                      )
                    ],
                  )));
        });
  }
}
