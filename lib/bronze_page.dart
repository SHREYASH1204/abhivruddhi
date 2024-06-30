import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'points_model.dart';

class BronzePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int points = Provider.of<PointsModel>(context).points;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bronze Level Vouchers'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('5% off Bus Fare'),
            onTap: points >= 10 ? () {
              _showRedeemDialog(context, '5% off Bus Fare');
              Provider.of<PointsModel>(context, listen: false).redeemPoints(10);
            } : null,
            enabled: points >= 10,
          ),
          ListTile(
            title: Text('Free Movie Ticket'),
            onTap: points >= 150 ? () {
              _showRedeemDialog(context, 'Free Movie Ticket');
              Provider.of<PointsModel>(context, listen: false).redeemPoints(150);
            } : null,
            enabled: points >= 150,
          ),
          ListTile(
            title: Text('Early Access to Public Event'),
            onTap: points >= 200 ? () {
              _showRedeemDialog(context, 'Early Access to Public Event');
              Provider.of<PointsModel>(context, listen: false).redeemPoints(200);
            } : null,
            enabled: points >= 200,
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
