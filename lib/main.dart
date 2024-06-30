import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_city/login.dart';
import 'package:smart_city/report_issue.dart';
import 'points_model.dart';
import 'points_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => PointsModel(FirebaseAuth.instance.currentUser!.uid)),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<bool?> checkIfUserIsLoggedIn() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool("isLoggedIn") ?? false;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart City App',
      home: FutureBuilder<bool?>(
        future: checkIfUserIsLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data ?? false) {
              return PointsHomePage();
            } else {
              return LoginScreen();
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
          return PointsHomePage();
        },
      ),
    );
  }
}
