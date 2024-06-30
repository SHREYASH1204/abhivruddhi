import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'points_model.dart';

class GoldPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int points = Provider.of<PointsModel>(context).points;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gold Level Vouchers'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('50% off on Electronics'),
            onTap: points >= 500 ? () {
              _showRedeemDialog(context, '50% off on Electronics');
              Provider.of<PointsModel>(context, listen: false).redeemPoints(500);
            } : null,
            enabled: points >= 500,
          ),
          ListTile(
            title: Text('Free Concert Ticket'),
            onTap: points >= 1000 ? () {
              _showRedeemDialog(context, 'Free Concert Ticket');
              Provider.of<PointsModel>(context, listen: false).redeemPoints(1000);
            } : null,
            enabled: points >= 1000,
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
