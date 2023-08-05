import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/api/visits_api.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/datas/user.dart';
import 'package:dating_app/dialogs/vip_dialog.dart';
import 'package:dating_app/helpers/app_helper.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/profile_screen.dart';
// import 'package:dating_app/widgets/build_title.dart';
import 'package:dating_app/widgets/loading_card.dart';
import 'package:dating_app/widgets/no_data.dart';
import 'package:dating_app/widgets/processing.dart';
import 'package:dating_app/widgets/profile_card.dart';
import 'package:dating_app/widgets/users_grid.dart';
import 'package:dating_app/screens/activity/select_activity.dart';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({Key? key}) : super(key: key);

  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  // Variables
  final ScrollController _gridViewController = ScrollController();
  final VisitsApi _visitsApi = VisitsApi();
  late AppLocalizations _i18n;
  List<DocumentSnapshot<Map<String, dynamic>>>? _userVisits;
  late DocumentSnapshot<Map<String, dynamic>> _userLastDoc;
  bool _loadMore = true;

  /// Load more users
  void _loadMoreUsersListener() async {
    _gridViewController.addListener(() {
      if (_gridViewController.position.pixels ==
          _gridViewController.position.maxScrollExtent) {
        /// Load more users
        if (_loadMore) {
          _visitsApi
              .getUserVisits(loadMore: true, userLastDoc: _userLastDoc)
              .then((users) {
            /// Update users list
            if (users.isNotEmpty) {
              _updateUserList(users);
            } else {
              setState(() => _loadMore = false);
            }
            debugPrint('load more users: ${users.length}');
          });
        } else {
          debugPrint('No more users');
        }
      }
    });
  }

  /// Update list
  void _updateUserList(List<DocumentSnapshot<Map<String, dynamic>>> users) {
    if (mounted) {
      setState(() {
        _userVisits!.addAll(users);
        if (users.isNotEmpty) {
          _userLastDoc = users.last;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _visitsApi.getUserVisits().then((users) {
      // Check result
      if (users.isNotEmpty) {
        if (mounted) {
          setState(() {
            _userVisits = users;
            _userLastDoc = users.last;
          });
        }
      } else {
        setState(() => _userVisits = []);
      }
    });

    /// Listener
    _loadMoreUsersListener();
  }

  @override
  void dispose() {
    _gridViewController.dispose();
    super.dispose();
  }

  goToWebPage() {
    debugPrint("asdf");
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(_i18n.translate("ACTIVITIES")),
          actions: [
            SizedBox(
              width: 50,
              child: IconButton(
                  onPressed: () async {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SelectActsScreen()));
                  },
                  icon: const Icon(Icons.add)),
            )
          ],
        ),
        body: Column(
          children: [Expanded(child: _showProfiles())],
        ));
  }

  Widget _showProfiles() {
    if (_userVisits == null) {
      return Processing(text: _i18n.translate("loading"));
    } else if (_userVisits!.isEmpty) {
      return NoData(svgName: 'eye_icon', text: _i18n.translate("no_visit"));
    } else {
      return UsersGrid(
        gridViewController: _gridViewController,
        itemCount: _userVisits!.length + 1,
        itemBuilder: (context, index) {
          if (index < _userVisits!.length) {
            final userId = _userVisits![index][VISITED_BY_USER_ID];
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: UserModel().getUser(userId),
              builder: (context, snapshot) {
                /// Check result
                if (!snapshot.hasData) {
                  return const LoadingCard();
                } else if (snapshot.data?.data() == null) {
                  AppHelper()
                      .ambiguate(WidgetsBinding.instance)!
                      .addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _userVisits!.removeAt(index);
                      });
                    }
                  });

                  return const LoadingCard();
                } else {
                  final User user = User.fromDocument(snapshot.data!.data()!);
                  return ScopedModelDescendant<UserModel>(
                      builder: (context, child, userModel) {
                    return GestureDetector(
                      child: ProfileCard(user: user, page: 'require_vip'),
                      onTap: () {
                        if (userModel.userIsVip) {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return ProfileScreen(
                                    user: user, hideDislikeButton: true);
                              });

                          _visitsApi.visitUserProfile(
                            visitedUserId: user.userId,
                            userDeviceToken: user.userDeviceToken,
                            nMessage:
                                "${UserModel().user.userFullname.split(' ')[0]}, "
                                "${_i18n.translate("visited_your_profile_click_and_see")}",
                          );
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) => const VipDialog());
                        }
                      },
                    );
                  });
                }
              },
            );
          } else {
            return Container();
          }
        },
      );
    }
  }
}
