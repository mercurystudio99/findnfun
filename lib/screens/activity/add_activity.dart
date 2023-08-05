// ignore_for_file: prefer_const_constructors
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/widgets/show_scaffold_msg.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/models/activity_model.dart';

import 'package:dating_app/dialogs/progress_dialog.dart';
import 'package:dating_app/widgets/image_source_sheet.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:dating_app/datas/user.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen(
      {Key? key,
      required this.activityId,
      required this.selectedName,
      required this.activityPath})
      : super(key: key);
  final String activityId;
  final String selectedName;
  final String activityPath;

  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  // Variables
  late AppLocalizations _i18n;
  late final String userId;

  final _descriptionController = TextEditingController();

  RangeValues _currentRangeValues = RangeValues(18, 60);
  double distanceValue = 10;
  double maxDistance = 100;
  late bool profileActive = false;
  final int index = 1;
  final String imageUrl = "";

  // ignore: non_constant_identifier_names
  final Map<String, dynamic> activity_images = {
    "image_0": "",
    "image_1": "",
    "image_2": ""
  };

  Future<void> _getCurrentUserData() async {
    userId = UserModel().getUserId();
    User userObject = await UserModel().getUserObject(userId);
    final double minAge =
        await userObject.userSettings!['user_min_age'].toDouble();
    final double maxAge =
        await userObject.userSettings!['user_max_age'].toDouble();
    int freeAcctDistance;
    if (userObject.userSettings?['user_max_distance'] == null) {
      freeAcctDistance = 100;
    } else {
      freeAcctDistance = await AppModel().getFreeAcctMaxDistance();
    }
    setState(() {
      distanceValue = userObject.userSettings!['user_max_distance'].toDouble();
      maxDistance = freeAcctDistance.toDouble();
      _currentRangeValues = RangeValues(minAge, maxAge);
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.selectedName.capitalize()),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 30,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Positioned(
                            left: 10,
                            child: Text(
                                _i18n.translate("your_photos_for_activity")))
                      ],
                    ),
                  ),
                  imageUpload(context),
                  SizedBox(
                    height: 10,
                  ),
                  dividerBuilder(),
                  SizedBox(
                    height: 30,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Positioned(
                            left: 10,
                            child: Text(
                                _i18n.translate("tellus_aboutyou_activity")))
                      ],
                    ),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: "",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    maxLength: 1000,
                  ),
                  dividerBuilder(),
                  SizedBox(
                    height: 30,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Positioned(
                            left: 10,
                            child: Text(_i18n.translate("maximum_distance_is") +
                                " : " +
                                distanceValue.toStringAsFixed(0) +
                                "km  "))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Positioned(
                            left: 10,
                            child: Text(
                              _i18n.translate("show_people_within_radius"),
                              style: TextStyle(fontSize: 12),
                            ))
                      ],
                    ),
                  ),
                  Slider(
                    value: distanceValue,
                    min: 1,
                    max: 100,
                    onChanged: (double value) {
                      //by default value will be range from 0-1
                      setState(() {
                        distanceValue = value.floorToDouble();
                      });
                    },
                  ),
                  SizedBox(
                    height: 20,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Positioned(
                            left: 10,
                            child: Text(
                              _i18n.translate("need_more_radius"),
                              style: TextStyle(fontSize: 12),
                            ))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Positioned(
                            left: 10,
                            child: Text(
                              _i18n.translate(
                                  "upgrade_account_get_increase_distance"),
                              style: TextStyle(fontSize: 12),
                            ))
                      ],
                    ),
                  ),
                  dividerBuilder(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_i18n.translate("age_range")),
                            Text(
                              _i18n.translate("show_people_age_range"),
                              style: TextStyle(fontSize: 12),
                            )
                          ],
                        ),
                        Spacer(),
                        Text(_currentRangeValues.start.round().toString() +
                            " - " +
                            _currentRangeValues.end.round().toString())
                      ],
                    ),
                  ),
                  RangeSlider(
                    values: _currentRangeValues,
                    max: 100,
                    divisions: 82,
                    min: 17,
                    labels: RangeLabels(
                      _currentRangeValues.start.round().toString(),
                      _currentRangeValues.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _currentRangeValues = values;
                      });
                    },
                  ),
                  dividerBuilder(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_i18n.translate("active_profile")),
                            Text(
                              _i18n.translate(
                                  "your_profile_not_visible_discover_tab"),
                              style: TextStyle(fontSize: 12),
                            )
                          ],
                        ),
                        Spacer(),
                        Switch(
                          // This bool value toggles the switch.
                          value: profileActive,
                          onChanged: (bool value) {
                            // This is called when the user toggles the switch.
                            setState(() {
                              profileActive = value;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 80,
                    child: saveButtonBuilder(context),
                  ),
                ],
              )),
        ));
  }

  Divider dividerBuilder() {
    return Divider(
      thickness: 1.5,
      indent: 10,
      endIndent: 10,
      color: Colors.grey,
    );
  }

  Stack saveButtonBuilder(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Positioned(
          top: 0,
          right: 10,
          child: ElevatedButton(
            child: Text(
              _i18n.translate("SAVE"),
              style: TextStyle(fontSize: 20),
            ),
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 10)),
            onPressed: () {
              if (activity_images['image_0'] == "" &&
                  activity_images['image_1'] == "" &&
                  activity_images['image_2'] == "") {
                showScaffoldMessage(
                    context: context,
                    message: _i18n.translate(
                        "profile_activity_upload_image_atleastone_validate"));
                return;
              }
              if (_descriptionController.text.length < 30) {
                showScaffoldMessage(
                    context: context,
                    message: _i18n.translate(
                        'profile_activity_descript_atleasthirty_validate'));
                return;
              }

              saveActivity();
              // Navigator.of(context).pop();
            },
          ),
        )
      ],
    );
  }

  SingleChildScrollView imageUpload(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(alignment: WrapAlignment.spaceBetween, children: [
        SizedBox(
          height: (MediaQuery.of(context).size.width - 50) / 4,
          width: (MediaQuery.of(context).size.width - 50) / 3,
          child: imagePickContainer(0),
        ),
        SizedBox(
          width: 10,
        ),
        SizedBox(
          height: (MediaQuery.of(context).size.width - 50) / 4,
          width: (MediaQuery.of(context).size.width - 50) / 3,
          child: imagePickContainer(1),
        ),
        SizedBox(
          width: 10,
        ),
        SizedBox(
          height: (MediaQuery.of(context).size.width - 50) / 4,
          width: (MediaQuery.of(context).size.width - 50) / 3,
          child: imagePickContainer(2),
        ),
      ]),
    );
  }

  Container imagePickContainer(int imageIndex) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 3,
              offset: Offset(1, 1), // changes x,y position of shadow
            ),
          ],
          border: Border.all(color: Colors.black, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        splashColor: Colors.white,
        customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
                color: Colors.black,
                style: BorderStyle.solid,
                width: 2.0,
                strokeAlign: BorderSide.strokeAlignOutside)),
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: activity_images["image_$imageIndex"] != ""
                ? Image.network(activity_images["image_$imageIndex"])
                : Center(
                    child: Text(
                    _i18n.translate("click_to_upload_image"),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ))),
        onTap: () => {_selectImage(context, imageIndex)},
      ),
    );
  }

  void _selectImage(BuildContext context, int imageIndex) async {
    /// Initialization
    final i18n = AppLocalizations.of(context);
    final pr = ProgressDialog(context, isDismissible: false);

    await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => ImageSourceSheet(
              onImageSelected: (image) async {
                if (image != null) {
                  /// Show progress dialog
                  pr.show(i18n.translate("processing"));

                  // debugPrint(image.toString());
                  final imageLink = await ActivityModel().uploadFile(
                      file: image, path: "uploads/activities", userId: userId);
                  setState(() {
                    activity_images["image_$imageIndex"] = imageLink;
                  });

                  pr.hide();
                  // close modal
                  Navigator.of(context).pop();
                }
              },
            ));
  }

  void saveActivity() {
    // _pr.show(_i18n.translate('processing'));
    ActivityModel().addActivity(
        userid: userId,
        activityId: widget.activityId,
        status: profileActive,
        ageRange: _currentRangeValues,
        maxDistance: distanceValue,
        images: activity_images,
        apBio: _descriptionController.text,
        aPath: widget.activityPath,
        onSuccess: () {
          // Show success message
          Navigator.of(context).pop('');
          Navigator.of(context).pop('');
          showScaffoldMessage(
              context: context,
              message: _i18n.translate("profile_activity_add_success_msg"));
        },
        onError: () {
          // Show error message
          showScaffoldMessage(
              context: context,
              message: _i18n.translate('profile_activity_add_error_msg'));
        });
  }
}
