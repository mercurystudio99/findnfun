// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:dating_app/constants/activity_const.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:dating_app/models/user_model.dart';

class ActivityModel extends Model {
  final _firestore = FirebaseFirestore.instance;

  static final ActivityModel _actModel = ActivityModel._internal();
  factory ActivityModel() {
    return _actModel;
  }
  ActivityModel._internal();

  final _storageRef = FirebaseStorage.instance;

  Future<String> uploadFile({
    required File file,
    required String path,
    required String userId,
  }) async {
    // Image name
    String imageName =
        userId + DateTime.now().millisecondsSinceEpoch.toString();
    // Upload file
    final UploadTask uploadTask = _storageRef
        .ref()
        .child(path + '/' + userId + '/' + imageName)
        .putFile(file);
    final TaskSnapshot snapshot = await uploadTask;
    String url = await snapshot.ref.getDownloadURL();
    // return file link
    return url;
  }

  void addActivity({
    required String userid,
    required String activityId,
    required bool status,
    required RangeValues ageRange,
    required double maxDistance,
    required Map images,
    required String apBio,
    required String aPath,
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) {
    saveActivityData(data: {
      AP_USER_ID: userid,
      ACTIVITY_ID: activityId,
      AP_CREATE_DATE: Timestamp.now(),
      AP_LAST_UPDATE: Timestamp.now(),
      AP_STATUS: status ? 'active' : 'inactive',
      AP_SETTINGS: {
        AP_SHOW_ME: "male",
        AP_MIN_AGE: ageRange.start.round(),
        AP_MAX_AGE: ageRange.end.round(),
        AP_MAX_DISTANCE: maxDistance
      },
      AP_GALLERY: images,
      AP_BIO: apBio,
      AP_TOTAL_LIKES: 0,
      AP_TOTAL_DISLIKES: 0,
      AP_CATIVITY_PATH: aPath,
    }).then((_) {
      onSuccess();
      debugPrint('updateAdminSignInInfo() -> success');
    }).catchError((error) {
      onError();
      debugPrint('updateAdminSignInInfo() -> error: $error');
    });
  }

  Future<void> saveActivityData({required Map<String, dynamic> data}) {
    debugPrint(data.toString());
    _firestore
        .collection(C_USERS)
        .doc(data[AP_USER_ID])
        .collection("activity_profile")
        .add(data);
    return Future.value();
  }

  void removeActivity({
    required String docid,
    required String userid,
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) {
    removeAnActivity(data: {
      'userid': userid,
      'docId': docid,
    }).then((_) {
      onSuccess();
      debugPrint('updateAdminSignInInfo() -> success');
    }).catchError((error) {
      onError();
      debugPrint('updateAdminSignInInfo() -> error: $error');
    });
  }

  Future<void> removeAnActivity({required Map<String, dynamic> data}) {
    debugPrint(data.toString());
    _firestore
        .collection(C_USERS)
        .doc(data['userid'])
        .collection("activity_profile")
        .doc(data['docId'])
        .delete();
    return Future.value();
  }

  TreeNode simpleTree = TreeNode.root();
  Future<TreeNode> getFutureTree() async {
    simpleTree = TreeNode.root();
    final snapshot = await FirebaseFirestore.instance
        .collection(C_ACTIVITIES)
        .where('activity_enabled', isEqualTo: true)
        .get();
    snapshot.docs.map((doc) => {_buildNode(doc)}).toList();
    await Future.delayed(Duration(seconds: 1), () => {});
    return simpleTree;
  }

  Future<void> _buildNode(DocumentSnapshot doc) async {
    simpleTree.add(TreeNode(key: doc.id.toString(), data: doc.data()!));
    await _buildChildNode(doc, doc.id.toString());
  }

  Future<void> _buildChildNode(DocumentSnapshot doc, String pathtext) async {
    final childrenRef = await doc.reference
        .collection('activity_child')
        .where('activity_enabled', isEqualTo: true)
        .get();
    pathtext += "." + doc.id.toString();
    if (childrenRef.docs.isNotEmpty) {
      childrenRef.docs
          .map((doc) => {
                simpleTree
                    .elementAt(pathtext)
                    .add(TreeNode(key: doc.id.toString(), data: doc.data())),
                _buildChildNode(doc, pathtext),
              })
          .toList();
    }
  }

  Future<Map<String, dynamic>> getActivityByPath(
      {required String path, required String selfId}) async {
    String realPath = '';
    if (path == "/") {
      realPath = C_ACTIVITIES;
    } else {
      realPath = path.substring(2, path.length);
      realPath = C_ACTIVITIES +
          "/" +
          realPath.replaceAll('.', '/activity_child/') +
          '/activity_child';

      debugPrint(realPath);
    }

    final snapshot = await _firestore.collection(realPath).doc(selfId).get();
    return snapshot.data()!;
  }

  Future<bool> confirmCurrentActivity(String activityId) async {
    String userId = UserModel().getUserId();
    late bool exist;
    debugPrint(userId.toString() + "//" + activityId);
    try {
      await _firestore
          .collection(C_USERS + "/" + userId + "/activity_profile")
          .where('activity_id', isEqualTo: activityId)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          exist = true;
        } else {
          exist = false;
        }
      });
      return exist;
    } catch (e) {
      return false;
    }
  }

  // ignore: non_constant_identifier_names
  void EditActivity({
    required String userid,
    required String activityId,
    required bool status,
    required RangeValues ageRange,
    required double maxDistance,
    required Map images,
    required String apBio,
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) {
    editActivityData(data: {
      AP_USER_ID: userid,
      AP_CREATE_DATE: Timestamp.now(),
      AP_LAST_UPDATE: Timestamp.now(),
      AP_STATUS: status ? 'active' : 'inactive',
      AP_SETTINGS: {
        AP_SHOW_ME: "male",
        AP_MIN_AGE: ageRange.start.round(),
        AP_MAX_AGE: ageRange.end.round(),
        AP_MAX_DISTANCE: maxDistance
      },
      AP_GALLERY: images,
      AP_BIO: apBio,
      AP_TOTAL_LIKES: 0,
      AP_TOTAL_DISLIKES: 0,
    }, docId: activityId)
        .then((_) {
      onSuccess();
      debugPrint('updateAdminSignInInfo() -> success');
    }).catchError((error) {
      onError();
      debugPrint('updateAdminSignInInfo() -> error: $error');
    });
  }

  Future<void> editActivityData(
      {required Map<String, dynamic> data, required String docId}) {
    debugPrint(data.toString());
    _firestore
        .collection(C_USERS)
        .doc(data[AP_USER_ID])
        .collection("activity_profile")
        .doc(docId)
        .update(data);
    return Future.value();
  }
}
