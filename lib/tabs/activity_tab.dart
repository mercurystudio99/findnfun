// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/activity/select_activity.dart';
import 'package:dating_app/widgets/no_data.dart';
import 'package:dating_app/widgets/processing.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/widgets/svg_icon.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:dating_app/models/activity_model.dart';
import 'package:dating_app/widgets/show_scaffold_msg.dart';
import 'package:dating_app/screens/activity/edit_activity.dart';

class ActivitiesTab extends StatefulWidget {
  const ActivitiesTab({Key? key}) : super(key: key);

  @override
  _ActivitiesTabState createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends State<ActivitiesTab> {
  late AppLocalizations _i18n;
  late String countryCode;
  Stream<QuerySnapshot<Map<String, dynamic>>>? activities;
  final _firestore = FirebaseFirestore.instance;
  int? freeMaxActivities;
  int? activitiesNum;
  late String userId;
  void getActivities() async {
    userId = UserModel().getUserId();
    freeMaxActivities = UserModel().getFreeActivities();
    setState(() {
      activities = _firestore
          .collection(C_USERS)
          .doc(userId)
          .collection('activity_profile')
          .snapshots();
    });
  }

  @override
  void initState() {
    getActivities();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    countryCode = _i18n.locale.toString();
    return StreamBuilder<QuerySnapshot>(
        stream: activities,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Processing(text: _i18n.translate("loading"));
          } else {
            if (snapshot.data!.docs.isEmpty) {
              return CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.purple,
                    title: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            _i18n.translate("ACTIVITIES"),
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          IconButton(
                              onPressed: () {
                                if (freeMaxActivities! == 0 ||
                                    activitiesNum! < freeMaxActivities!) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const SelectActsScreen()));
                                } else {
                                  showScaffoldMessage(
                                      context: context,
                                      message: _i18n.translate(
                                          "full_max_activity_profile_msg"));
                                }
                              },
                              icon: const Icon(
                                Icons.add,
                                size: 30,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 150,
                      child: NoData(
                          icon: SvgIcon(
                            "assets/icons/activity-heart.svg",
                            width: 100,
                            height: 100,
                          ),
                          text: _i18n.translate("no_activities")),
                    ),
                  )
                ],
              );
            } else {
              activitiesNum = snapshot.data!.docs.length;
              return CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.purple,
                    title: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            _i18n.translate("ACTIVITIES"),
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          IconButton(
                              onPressed: () {
                                if (freeMaxActivities! == 0 ||
                                    activitiesNum! < freeMaxActivities!) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const SelectActsScreen()));
                                } else {
                                  showScaffoldMessage(
                                      context: context,
                                      message: _i18n.translate(
                                          "full_max_activity_profile_msg"));
                                }
                              },
                              icon: const Icon(
                                Icons.add,
                                size: 30,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      Map<String, dynamic> data = snapshot.data!.docs[index]
                          .data()! as Map<String, dynamic>;
                      String docid = snapshot.data!.docs[index].id;
                      return GestureDetector(
                          onTap: () => {debugPrint(data['ap_bio'])},
                          child: Padding(
                              padding:
                                  EdgeInsets.only(top: 10, left: 10, right: 10),
                              child: makeCard(data, context, docid)));
                    }, childCount: snapshot.data!.docs.length),
                  )
                ],
              );
            }
          }
        });
  }

  FutureBuilder<Map<String, dynamic>> makeCard(
      Map<String, dynamic> data, BuildContext context, String docid) {
    late bool enabled = true;
    Widget thumbnail = SvgIcon(
      "assets/icons/temp-picture.svg",
      width: 80,
      height: 60,
    );
    Color cardColor =
        data['ap_status'] == "active" ? Color(0xff0050ef) : Color(0xffd3d3d3);
    String activityName = '';

    Future<Map<String, dynamic>> activityData = ActivityModel()
        .getActivityByPath(
            path: data['ap_activity_path'], selfId: data['activity_id']);

    activityData.then((value) => {
          debugPrint(enabled.toString()),
          if (value['activity_image_link'] != "")
            {
              thumbnail = Image.network(
                value['activity_image_link'],
                width: 80,
                height: 60,
              )
            },
          if (value['enabled_color'] != "")
            {
              cardColor = data['ap_status'] == "active"
                  ? Color(int.parse(
                          ("#" + value['enabled_color']).substring(1, 9),
                          radix: 16) +
                      0xFF000000)
                  : Color(0xffd3d3d3)
            },
          if (value['activity_languages']!.length > 0)
            {
              for (var i = 0; i < value['activity_languages'].length; i++)
                {
                  if (value['activity_languages'][i]['lang'] == countryCode)
                    {activityName = value['activity_languages'][i]['name']}
                }
            }
          else
            {activityName = value['activity_name']},
        });

    final Color nameColor =
        data['ap_status'] == "active" ? Colors.white : Colors.black;

    return FutureBuilder<Map<String, dynamic>>(
        future: activityData,
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.data?['activity_enabled'] != null &&
              !snapshot.data?['activity_enabled']) {
            return SizedBox.shrink();
          } else if (snapshot.data?['activity_enabled'] == null) {
            return SizedBox.shrink();
          }
          return Card(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7.0),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black54,
                      blurRadius: 5,
                      offset: Offset(0, 2))
                ],
                color: cardColor,
              ),
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: thumbnail),
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 240,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activityName,
                                style:
                                    TextStyle(color: nameColor, fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                  data['ap_status'] == "active"
                                      ? _i18n.translate('activity_active')
                                      : _i18n.translate('activity_inactive'),
                                  style: TextStyle(
                                      color: nameColor, fontSize: 14)),
                            ],
                          ),
                        )
                      ],
                    ),
                    Row(children: [
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => EditActivityScreen(
                                      activityId: docid,
                                      appData: data,
                                      selectedName: activityName,
                                    )));
                          },
                          color: nameColor,
                          icon: SvgIcon(
                            "assets/icons/edit.svg",
                            color: nameColor,
                            width: 20,
                          )),
                      IconButton(
                          onPressed: () async {
                            if (await confirm(
                              context,
                              title: Text(_i18n.translate('confirm_deletion')),
                              content: Text(
                                  _i18n.translate('would_you_like_remove')),
                              textOK: Text(_i18n.translate("Yes")),
                              textCancel: Text(_i18n.translate('No')),
                            )) {
                              return ActivityModel().removeActivity(
                                  docid: docid,
                                  userid: userId,
                                  onSuccess: () {
                                    // Show success message
                                    showScaffoldMessage(
                                        context: context,
                                        message: _i18n.translate(
                                            "profile_activity_remove_success_msg"));
                                  },
                                  onError: () {
                                    showScaffoldMessage(
                                        context: context,
                                        message: _i18n.translate(
                                            "profile_activity_remove_error_msg"));
                                  });
                            }
                          },
                          color: nameColor,
                          icon: SvgIcon(
                            "assets/icons/trash_icon.svg",
                            color: nameColor,
                            width: 20,
                          ))
                    ])
                  ],
                ),
              ),
            ),
          );
        });
  }
}
