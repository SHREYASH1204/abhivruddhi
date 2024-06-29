import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_city/registration.dart';
import 'points_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'report_issue.dart';

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
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Your Points:'),
                Consumer<PointsModel>(
                  builder: (context, pointsModel, child) {
                    return Text(
                      '${pointsModel.points}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    );
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReportIssuePage()),
                    );
                  },
                  child: Text('Report Issue (Earn 10 points)'),
                ),
                // Other buttons...
              ],
            ),
          ),
        ),
      );
    }
  }
}
