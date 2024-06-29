import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IssuesFeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Feed'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('issues').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final issues = snapshot.data!.docs;
          return ListView.builder(
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              return ListTile(
                title: Text(issue['text']),
                leading: issue['imageUrl'] != null
                    ? Image.network(issue['imageUrl'])
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(issue['stars'].toString()),
                    IconButton(
                      icon: Icon(Icons.star),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .runTransaction((transaction) async {
                          final freshSnapshot =
                              await transaction.get(issue.reference);
                          final freshStars = freshSnapshot['stars'];
                          transaction.update(
                              issue.reference, {'stars': freshStars + 1});
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
