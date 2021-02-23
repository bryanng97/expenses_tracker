import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:expenses_tracker/models/users.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _deviceID;
  String _deviceName;
  List<Users> _userList;
  final databaseReference = FirebaseFirestore.instance;

  UserProvider(this._userList);

  List<Users> get userList {
    return _userList;
  }

  String get deviceID {
    return _deviceID;
  }

  String get deviceName {
    return _deviceName;
  }

  Future<Map<String, dynamic>> getDeviceDetails() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        _deviceID = build.androidId; //UUID for Android
        _deviceName = build.model;
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        _deviceID = data.identifierForVendor; //UUID for iOS
        _deviceName = data.name;
      }

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'deviceID': _deviceID,
        'deviceName': _deviceName,
      });
      await prefs.setString('userData', userData);
    } on PlatformException {
      print('Failed to get platform version');
    }

    return {'deviceID': _deviceID, 'deviceName': _deviceName};
  }

  Future<void> registerUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final extractDetail =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    _deviceID = extractDetail['deviceID'];
    _deviceName = extractDetail['deviceName'];

    await databaseReference
        .collection("userData")
        .doc(deviceID.toString())
        .set({'deviceID': _deviceID, 'deviceName': _deviceName}, SetOptions(merge: true));
  }
}
