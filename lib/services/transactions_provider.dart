import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses_tracker/models/transactions.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionProvider with ChangeNotifier {
  final databaseReference = FirebaseFirestore.instance;
  List<Transactions> _trxList = [];
  List<Transactions> _trxRecord = [];
  String deviceID;

  TransactionProvider();

  List<Transactions> get trx {
    return _trxList;
  }

  List<Transactions> get trxRecord {
    return _trxRecord;
  }

  Transactions findById(String id) {
    return _trxList.firstWhere((element) => element.id == id);
  }

  Future<void> getTransactions() async {
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
                date: f['date']));
          }
          _trxList = trxRecord;
          notifyListeners();
        });
      });
    } else {
      _trxList = [];
    }
  }

  Future<void> addTransaction(txTitle, txAmt, chosenDate, id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final extractDetail =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    var deviceID = extractDetail['deviceID'];

    var txID = id.isEmpty ? DateTime.now().toIso8601String() : id;

    await databaseReference.collection("transaction").doc(txID).set({
      'id': txID,
      'title': txTitle,
      'amount': double.parse(txAmt),
      'deviceID': '$deviceID',
      'date': chosenDate
    }, SetOptions(merge: true));
  }

  Future<void> getTransaction(txID) async {
    final List<Transactions> trxRecord = [];
    await databaseReference
        .collection("transaction")
        .doc(txID)
        .get()
        .then((snapshot) {
      trxRecord.add(Transactions(
        id: snapshot['id'].toString(),
        title: snapshot['title'],
        amount: snapshot['amount'],
        deviceID: snapshot['deviceID'],
        date: snapshot['date'],
      ));
      _trxRecord = trxRecord;
      notifyListeners();
    });
  }

  // sample calling rest API
  // Future<void> getTransactions() async {
  //   try {
  //     await retry(
  //       () async {
  //         final response =
  //             await http.post('apiURL', body: json.encode({body}), header: {
  //           'Accept': 'application/json',
  //           'Content-Type': 'application/json',
  //         }).timeout(Duration(seconds: 60), onTimeout: () {
  //           throw TimeoutException;
  //         }).catchError((err) {
  //           print(err);
  //         });

  //         print(response);
  //       },
  //       retryIf: (e) =>
  //           e is SocketException ||
  //           e is TimeoutException ||
  //           e is HttpException ||
  //           e is http.ClientException,
  //       maxAttempts: 3,
  //     );
  //   } catch (err) {
  //     print(err);
  //   }
  // }
}
