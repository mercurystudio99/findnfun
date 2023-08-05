// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/models/suggest_model.dart';
import 'package:dating_app/widgets/show_scaffold_msg.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:flutter_native_splash/cli_commands.dart';

class ActivitySuggestScreen extends StatefulWidget {
  const ActivitySuggestScreen({Key? key}) : super(key: key);

  @override
  _ActivitySuggestScreenState createState() => _ActivitySuggestScreenState();
}

class _ActivitySuggestScreenState extends State<ActivitySuggestScreen> {
  // Variables
  late AppLocalizations _i18n;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;
  late final String userId;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  void _getCurrentUserUpdates() {
    /// Get user stream
    _userStream = UserModel().getUserStream();
    userId = UserModel().getUserId();

    /// Subscribe to user updates
    _userStream.listen((userEvent) {
      // Update user
      UserModel().updateUserObject(userEvent.data()!);
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUserUpdates();
  }

  @override
  void dispose() {
    super.dispose();
    _userStream.drain();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(_i18n.translate("ACTIVITY_SUGGEST")),
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
                            child: Text(_i18n.translate("NAME").capitalize()))
                      ],
                    ),
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: _i18n.translate("input_activity_to_suggest"),
                      prefixIcon: Icon(Icons.settings_suggest),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                    ),
                    autofocus: true,
                    keyboardType: TextInputType.multiline,
                  ),
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
                            child: Text(_i18n.translate("description")))
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
                    autofocus: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    maxLength: 1000,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 80,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Positioned(
                          top: 0,
                          right: 10,
                          child: ElevatedButton(
                            child: Text(
                              _i18n.translate("send_text"),
                              style: TextStyle(fontSize: 20),
                            ),
                            style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.fromLTRB(40, 10, 40, 10)),
                            onPressed: () {
                              if (_nameController.text == '') {
                                showScaffoldMessage(
                                    context: context,
                                    message:
                                        _i18n.translate("name_required_msg"));
                                return;
                              }
                              if (_descriptionController.text == '') {
                                showScaffoldMessage(
                                    context: context,
                                    message: _i18n
                                        .translate("description_required_msg"));
                                return;
                              }
                              saveActivity();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )),
        ));
  }

  void saveActivity() {
    SuggestModel().addSuggest(
        description: _descriptionController.text,
        name: _nameController.text,
        userid: userId,
        onSuccess: () {
          Navigator.of(context).pop('success');
          showScaffoldMessage(
              context: context,
              message: _i18n.translate('suggest_save_success_msg'));
        },
        onError: () {
          showScaffoldMessage(
              context: context,
              message: _i18n.translate('suggest_save_error_msg') +
                  "\n" +
                  _i18n.translate("suggest_save_error_retry_later"));
        });
  }
}
