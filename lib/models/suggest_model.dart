import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:dating_app/constants/activity_const.dart';

class SuggestModel extends Model {
  final _firestore = FirebaseFirestore.instance;

  static final SuggestModel _actModel = SuggestModel._internal();
  factory SuggestModel() {
    return _actModel;
  }
  SuggestModel._internal();

  // Future<List> getSuggestions() async {
  //   QuerySnapshot _querySnapshot =
  //       await _firestore.collection(C_ACTIVITIES).get();
  //   List list = _querySnapshot.docs.map((doc) => doc.data()).toList();
  //   return list;
  // }

  Future<void> updateSuggestData({required Map<String, dynamic> data}) {
    _firestore
        .collection(C_SUGGESTION)
        .doc(data[SUGGEST_ACTIVITY_ID])
        .update(data);
    return Future.value();
  }

  void updateSuggest({
    required String changeDescription,
    required String documentId,
    required String changedStatus,
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) {
    updateSuggestData(data: {
      SA_STATUS_DESCRIPTION: changeDescription,
      SA_STATUS: changedStatus,
      SA_STATUS_DATE: Timestamp.now(),
    }).then((_) {
      onSuccess();
      debugPrint('updateAdminSignInInfo() -> success');
    }).catchError((error) {
      onError();
      debugPrint('updateAdminSignInInfo() -> error: $error');
    });
  }

  void addSuggest({
    required String description,
    required String name,
    required String userid,
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) {
    addSuggestData(data: {
      SA_ACTIVITY_DESCRIPTION: description,
      SA_USER_ID: userid,
      SA_ACTIVITY_NAME: name,
      SA_CREATE_DATE: Timestamp.now(),
      SA_STATUS_DATE: Timestamp.now(),
      SA_STATUS: 'pending',
      SA_STATUS_DESCRIPTION: '',
      SUGGEST_ACTIVITY_ID: ""
    }).then((_) {
      onSuccess();
      debugPrint('updateAdminSignInInfo() -> success');
    }).catchError((error) {
      onError();
      debugPrint('updateAdminSignInInfo() -> error: $error');
    });
  }

  Future<void> addSuggestData({required Map<String, dynamic> data}) {
    _firestore.collection(C_SUGGESTION).add(data);
    return Future.value();
  }
}
