import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'points_model.dart';

class ReportIssuePage extends StatefulWidget {
  @override
  _ReportIssuePageState createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  CameraController? _cameraController;
  Uint8List? _imageData;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    print("Camera permission status: $cameraStatus");

    if (!cameraStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera permission is required')),
      );
      return;
    }

    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
      );

      await _cameraController?.initialize();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing camera: $e')),
      );
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera not initialized')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final XFile file = await _cameraController!.takePicture();
      final imageData = await file.readAsBytes();
      setState(() {
        _imageData = imageData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking picture: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitIssue() async {
    final description = _descriptionController.text;
    final location = _locationController.text;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not available')),
      );
      return;
    }

    if (description.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a description and location')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

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
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    try {
      await FirebaseFirestore.instance.collection('issues').add({
        'userId': user.uid,
        'description': description,
        'location': location,
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showInstructions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Stand next to the garbage location and take a picture. This will help pinpoint the exact spot in photos.\n'
                  'Frame the photo so that the garbage can is clearly visible in the shot. This will make it easy to identify the location later.\n'
                  'You can also include other landmarks in the photo, such as a street sign or building, for additional reference.',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
        );
      },
    );
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
              ElevatedButton(
                onPressed: _showInstructions,
                child: Text('Instructions'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Describe the issue',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Enter the location',
                ),
              ),
              SizedBox(height: 10),
              _cameraController == null
                  ? CircularProgressIndicator()
                  : _imageData == null
                      ? Text('No image taken.')
                      : Image.memory(_imageData!),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _takePicture,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Take a Picture'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitIssue,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Submit Issue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
