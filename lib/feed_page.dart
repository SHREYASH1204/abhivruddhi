import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_city/registration.dart';
import 'points_model.dart';
import 'report_issue.dart';
import 'homescreen.dart'; // Import the new AnnouncementPage

class PointsHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return RegistrationScreen();
    } else {
      return ChangeNotifierProvider(
        create: (_) => PointsModel(user.uid),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Community Points System'),
            backgroundColor: Color.fromARGB(255, 103, 222, 117),
          ),
          body: Container(
            color: Colors.white, // Set background to white
            child: Center(
              child: Consumer<PointsModel>(
                builder: (context, pointsModel, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Your Points: ${pointsModel.points}', style: Theme.of(context).textTheme.headlineMedium),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportIssuePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFF9C4), // Pastel yellow color
                          foregroundColor: Colors.black, // Black text color
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold, // Bold text
                          ),
                        ),
                        child: Text('Report Issue (Earn 10 points)'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _showInstructionsDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFF9C4), // Pastel yellow color
                          foregroundColor: Colors.black, // Black text color
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold, // Bold text
                          ),
                        ),
                        child: Text('View Points Levels'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(title: '',), // Navigate to the AnnouncementPage
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFF9C4), // Pastel yellow color
                          foregroundColor: Colors.black, // Black text color
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold, // Bold text
                          ),
                        ),
                        child: Text('Announcements'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    }
  }

  void _showInstructionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 236, 136, 170),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Bronze Level (100+ points):',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '• Small discounts on public services (e.g., 5% off bus fares).\n'
                    '• Entries into community raffles with smaller prizes (e.g., movie tickets).\n'
                    '• Early access to limited quantities of free public events.',
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Silver Level (500+ points):',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '• Medium discounts on public services (e.g., 10% off utilities).\n'
                    '• Entries into raffles with mid-tier prizes (e.g., gift certificates to local restaurants).\n'
                    '• Priority registration for popular community events.\n'
                    '• Access to exclusive online content or educational resources.',
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Gold Level (1000+ points):',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '• Large discounts on public services (e.g., 15% off government fees).\n'
                    '• Entries into raffles with high-value prizes (e.g., weekend getaways).\n'
                    '• Guaranteed spots in popular events.\n'
                    '• Exclusive discounts at partner businesses.\n'
                    '• Invitations to special recognition events.',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
