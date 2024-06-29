import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PointsModel with ChangeNotifier {
  int _points = 0;
  final String _userID;

  PointsModel(this._userID) {
    _fetchPoints();
  }

  int get points => _points;

  Future<void> _fetchPoints() async {
    try {
      print('Fetching points for user: $_userID');
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userID)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('points')) {
          _points = data['points'];
          print('Points fetched: $_points');
        } else {
          _points = 0;
          print('Points not found, initializing to 0');
        }
      } else {
        _points = 0;
        print('Document does not exist, initializing to 0');
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching points: $e');
    }
  }

  Future<void> addPoints(int points) async {
    print('Adding $points points');
    await _fetchPoints();
    _points += points;
    await _updatePoints();
  }

  Future<void> redeemPoints(int points) async {
    if (_points >= points) {
      print('Redeeming $points points');
      await _fetchPoints();
      _points -= points;
      await _updatePoints();
    } else {
      print('Not enough points to redeem');
    }
  }

  Future<void> _updatePoints() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_userID).set({
        'points': _points,
      }, SetOptions(merge: true));
      print('Updating points to $_points');
      notifyListeners();
    } catch (e) {
      print('Error updating points: $e');
    }
  }
}
