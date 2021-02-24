import 'package:flutter/foundation.dart';

class Transactions {
  final String id;
  final String title;
  final double amount;
  final String deviceID;
  final String date;

  Transactions({
    @required this.id, 
    @required this.title,
    @required this.amount, 
    this.deviceID,
    @required this.date
    });
}
