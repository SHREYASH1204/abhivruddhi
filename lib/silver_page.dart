import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'points_model.dart';

class SilverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int points = Provider.of<PointsModel>(context).points;

    return Scaffold(
      appBar: AppBar(
        title: Text('Silver Level Vouchers'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('10% off Groceries'),
            onTap: points >= 100 ? () {
              _showRedeemDialog(context, '10% off Groceries');
              Provider.of<PointsModel>(context, listen: false).redeemPoints(100);
            } : null,
            enabled: points >= 100,
          ),
          ListTile(
            title: Text('Free Meal at Restaurant'),
            onTap: points >= 300 ? () {
              _showRedeemDialog(context, 'Free Meal at Restaurant');
              Provider.of<PointsModel>(context, listen: false).redeemPoints(300);
            } : null,
            enabled: points >= 300,
          ),
        ],
      ),
    );
  }

  void _showRedeemDialog(BuildContext context, String voucher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Voucher Redeemed'),
          content: Text('You have successfully redeemed the $voucher voucher!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
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
