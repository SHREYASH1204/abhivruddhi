import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'points_model.dart';

class ReportIssuePage extends StatefulWidget {
  @override
  _ReportIssuePageState createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final TextEditingController _controller = TextEditingController();
  Uint8List? _imageData;
  String? _imageUrl;

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageData = await pickedFile.readAsBytes();
        setState(() {
          _imageData = imageData;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _submitIssue() async {
    final text = _controller.text;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? imageUrl;
    if (_imageData != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('issue_images')
            .child(user.uid)
            .child(DateTime.now().toString());
        final uploadTask = storageRef.putData(_imageData!);
        await uploadTask.whenComplete(() {});
        imageUrl = await storageRef.getDownloadURL();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
        return;
      }
    }

    try {
      await FirebaseFirestore.instance.collection('issues').add({
        'userId': user.uid,
        'text': text,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'stars': 0,
      });

      Provider.of<PointsModel>(context, listen: false).addPoints(10);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting issue: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report an Issue'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Describe the issue',
                ),
              ),
              SizedBox(height: 10),
              _imageData == null
                  ? Text('No image selected.')
                  : Image.memory(_imageData!),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick an image from gallery'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitIssue,
                child: Text('Submit Issue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
