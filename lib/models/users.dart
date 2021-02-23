import 'package:flutter/foundation.dart';

class Users {
  final String deviceID;
  final String deviceName;

  Users({
    @required this.deviceID,
    @required this.deviceName,
  });

  Users.fromJson(Map<String, dynamic> json)
      : deviceID = json['deviceID'],
        deviceName = json['deviceName'];

  Map<String, dynamic> toJson() => {
        'deviceID': deviceID,
        'deviceName': deviceName,
      };
}
