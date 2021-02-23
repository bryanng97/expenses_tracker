import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses_tracker/pages/add_transaction_page.dart';
import 'package:expenses_tracker/services/transactions_provider.dart';
import 'package:expenses_tracker/services/user_provider.dart';
import 'package:provider/provider.dart';

import './../widgets/transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final databaseReference = FirebaseFirestore.instance;
  var _userTransactions;

  String deviceName;
  String deviceID;

  var _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _isLoading = true;
    });

    () async {
      try {
        Future<Map<String, dynamic>> getDeviceInfo =
            Provider.of<UserProvider>(context, listen: false).getDeviceDetails();
        await getDeviceInfo.then((Map<String, dynamic> _info) {
          setState(() {
            deviceID = _info['deviceID'];
            deviceName = _info['deviceName'];
          });
        }).catchError((error) {
          throw error;
        });

        await Provider.of<TransactionProvider>(context, listen: false)
            .getTransaction()
            .whenComplete(() {
          setState(() {
            _userTransactions =
                Provider.of<TransactionProvider>(context, listen: false).trx;
          });
        }).catchError((err) {
          print(err);
        });

        await Provider.of<UserProvider>(context, listen: false)
            .registerUser()
            .catchError((err) {
          print(err);
        });
      } catch (err) {
        print(err);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }();
  }

  void _dltTx(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) {
        return tx.id == id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expenses Tracker',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (BuildContext context) => AddTransactionPage()))
                .then((value) {
              if (value == true) {
                setState(() {
                  _isLoading = true;
                });
                () async {
                  try {
                    await Provider.of<TransactionProvider>(context, listen: false)
                        .getTransaction()
                        .whenComplete(() {
                      setState(() {
                        _userTransactions =
                            Provider.of<TransactionProvider>(context, listen: false).trx;
                      });
                    }).catchError((err) {
                      print(err);
                    });
                  } catch (err) {
                    print(err);
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                }();
              }
            }),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
            //hello
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TransactionList(_userTransactions, _dltTx),
                ],
              ),
            ),
    );
  }
}
