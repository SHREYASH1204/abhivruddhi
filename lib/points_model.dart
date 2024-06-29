import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PointsModel with ChangeNotifier {
  int _points = 0;
  final String _userID;

  PointsModel(this._userID) {
    _fetchPoints();
  }

  int get points => _points;

  void _fetchPoints() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userID)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('points')) {
          _points = data['points'];
        } else {
          _points = 0;
        }
      } else {
        _points = 0;
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching points: $e');
    }
  }

  void addPoints(int points) {
    _points += points;
    _updatePoints();
  }

  void redeemPoints(int points) {
    if (_points >= points) {
      _points -= points;
      _updatePoints();
    }
  }

  void _updatePoints() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_userID).set({
        'points': _points,
      }, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      print('Error updating points: $e');
    }
  }
}
