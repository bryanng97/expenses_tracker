import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses_tracker/models/transactions.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionProvider with ChangeNotifier {
  final databaseReference = FirebaseFirestore.instance;
  List<Transactions> _trxList = [];
  String deviceID;

  TransactionProvider(this._trxList);

  List<Transactions> get trx {
    return _trxList;
  }

  Future<void> getTransaction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final extractDetail =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    var deviceID = extractDetail['deviceID'];

    final List<Transactions> trxRecord = [];
    if (databaseReference.collection("transaction") != null) {
      await databaseReference
          .collection("transaction")
          .orderBy('date', descending: true)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((f) {
          if (f['deviceID'] == deviceID) {
            trxRecord.add(Transactions(
                id: f['id'].toString(),
                title: f['title'],
                amount: f['amount'],
                deviceID: f['deviceID'],
                date: DateTime.parse(f['date'])));
          }
          _trxList = trxRecord;
        });
      });
    } else {
      _trxList = [];
    }
  }

  Future<void> addTransaction(txTitle, txAmt, chosenDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final extractDetail =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    var deviceID = extractDetail['deviceID'];

    var id = DateTime.now().toIso8601String();
    var convertedChosenDate = DateTime.parse(chosenDate).toIso8601String();

    await databaseReference.collection("transaction").doc(id).set({
      'id': '${id.toString()}',
      'title': txTitle,
      'amount': double.parse(txAmt),
      'deviceID': '$deviceID',
      'date': convertedChosenDate
    });
  }
}
