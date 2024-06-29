import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'points_model.dart';

class ReportIssuePage extends StatefulWidget {
  @override
  _ReportIssuePageState createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final TextEditingController _controller = TextEditingController();
  CameraController? _cameraController;
  Uint8List? _imageData;
  String? _imageUrl;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.locationWhenInUse,
    ].request();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
    );

    await _cameraController?.initialize();
    setState(() {});
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera not initialized')),
      );
      return;
    }

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
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  void _submitIssue() async {
    final text = _controller.text;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User or location data not available')),
      );
      return;
    }

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
        'location': GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
      });

      Provider.of<PointsModel>(context, listen: false).addPoints(10);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting issue: $e')),
      );
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
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Describe the issue',
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
                child: Text('Take a Picture'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: Text('Get Current Location'),
              ),
              if (_currentPosition != null)
                Text(
                    'Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}'),
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

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
