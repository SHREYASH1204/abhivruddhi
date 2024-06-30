import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'user_model.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text("No user logged in"));
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return Center(child: Text("Failed to fetch user data"));
        }

        UserModel userModel =
            UserModel.fromDocumentSnapshot(snapshot.data!);

        return Scaffold(
          appBar: AppBar(
            title: Text("Profile"),
            backgroundColor: Color.fromRGBO(141, 134, 201, 1),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: userModel.photo != null
                      ? NetworkImage(userModel.photo!)
                      : null,
                  child: userModel.photo == null ? Icon(Icons.person, size: 50) : null,
                ),
                SizedBox(height: 20),
                Text("Name: ${userModel.firstName} ${userModel.lastName}"),
                Text("Email: ${userModel.email}"),
                Text("Points: ${userModel.points}"),
              ],
            ),
          ),
        );
      },
    );
  }
}
