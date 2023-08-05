import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:dating_app/datas/app_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/constants/constants.dart';

class AppModel extends Model {
  // Variables
  late AppInfo appInfo;

  /// Create Singleton factory for [AppModel]
  ///
  static final AppModel _appModel = AppModel._internal();
  factory AppModel() {
    return _appModel;
  }
  AppModel._internal();
  // End

  /// Set data to AppInfo object
  void setAppInfo(Map<String, dynamic> appDoc) {
    appInfo = AppInfo.fromDocument(appDoc);
    notifyListeners();
    debugPrint('AppInfo object -> updated!');
  }

  final _firestore = FirebaseFirestore.instance;

  Future<int> getFreeAcctMaxDistance() async {
    final DocumentSnapshot<Map<String, dynamic>> appInfo =
        await _firestore.collection(C_APP_INFO).doc('settings').get();
    return appInfo.data()?[FREE_ACCOUNT_MAX_DISTANCE] ?? 100;
  }
}
