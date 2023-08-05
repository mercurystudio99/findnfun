// ignore_for_file: prefer_const_constructors

import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/activity_model.dart';
import 'package:dating_app/screens/activity/activity_suggest.dart';
import 'package:dating_app/screens/activity/add_activity.dart';
import 'package:flutter/material.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:dating_app/widgets/show_scaffold_msg.dart';

class SelectActsScreen extends StatefulWidget {
  const SelectActsScreen({Key? key}) : super(key: key);

  @override
  _SelectActsScreenState createState() => _SelectActsScreenState();
}

class _SelectActsScreenState extends State<SelectActsScreen> {
  final ScrollController _gridViewController = ScrollController();
  late AppLocalizations _i18n;
  late String countryCode;

  final GlobalKey<SliverTreeViewState> _simpleTreeKey =
      GlobalKey<SliverTreeViewState>();
  final AutoScrollController scrollController = AutoScrollController();

  Future<TreeNode>? futureTree;

  String activityId = "";
  String selectedName = '';
  String activityPath = "";

  @override
  void initState() {
    super.initState();
    _initTree();
  }

  _initTree() {
    setState(() {
      futureTree = ActivityModel().getFutureTree();
    });
  }

  _getRequests() async {
    // _updateData();
  }

  @override
  void dispose() {
    _gridViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    countryCode = _i18n.locale.toString();
    return Scaffold(
        appBar: AppBar(
          title: Text(_i18n.translate("SELECT_ACTIVITY")),
          actions: [
            SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () async {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const ActivitySuggestScreen()));
                        },
                        icon: const Icon(
                          Icons.wechat,
                          size: 30,
                          color: Colors.black87,
                        )),
                    IconButton(
                        onPressed: () async {
                          if (activityId == '') {
                            showScaffoldMessage(
                                context: context,
                                message: _i18n.translate(
                                    "profile_activity_category_mustbe_selected"));
                            return;
                          } else {
                            if (await ActivityModel()
                                .confirmCurrentActivity(activityId)) {
                              showScaffoldMessage(
                                  context: context,
                                  message: _i18n.translate(
                                      "profile_activity_already_exist"));
                              return;
                            }
                          }
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => AddActivityScreen(
                                        activityId: activityId,
                                        selectedName: selectedName,
                                        activityPath: activityPath,
                                      )))
                              .then((value) => _getRequests());
                        },
                        icon: const Icon(
                          Icons.check,
                          size: 30,
                          color: Colors.black87,
                        )),
                  ],
                ))
          ],
        ),
        body: FutureBuilder<TreeNode>(
            future: futureTree,
            builder: (BuildContext context, AsyncSnapshot<TreeNode> snapshot) {
              if (snapshot.hasData) {
                return CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverTreeView.simple(
                      tree: snapshot.data!,
                      onTreeReady: (controller) => {
                        for (var i = 0;
                            i < controller.tree.children.length;
                            i++)
                          {
                            controller.collapseNode(controller.elementAt(
                                snapshot.data!.childrenAsList[i].path))
                          }
                      },
                      expansionBehavior: ExpansionBehavior.collapseOthers,
                      showRootNode: false,
                      expansionIndicatorBuilder: (context, node) =>
                          ChevronIndicator.rightDown(
                        tree: node,
                        color: Colors.white,
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.centerRight,
                      ),
                      key: _simpleTreeKey,
                      scrollController: scrollController,
                      builder: (context, node) =>
                          Card(child: buildListItem(node)),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Error"),
                );
              } else {
                return Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            }));
  }

  Widget buildListItem(TreeNode node) {
    String activityName = node.data['activity_name'];
    String description = node.data!['activity_description'];

    if (node.data['activity_languages']!.length > 0) {
      for (var i = 0; i < node.data['activity_languages'].length; i++) {
        if (node.data['activity_languages'][i]['lang'] == countryCode) {
          activityName = node.data['activity_languages'][i]['name'];
        }
      }
    }
    return Card(
      color: Colors.blue[(10 - node.level) % 10 * 100],
      child: ListTile(
        title: Row(
          children: [
            Text(
              activityName.capitalize(),
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            node.children.isNotEmpty
                ? Text(
                    ' (' + node.children.length.toString() + ')',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  )
                : const SizedBox.shrink()
          ],
        ),
        subtitle: Text(
          description == null ? '' : description.capitalize(),
          style: const TextStyle(color: Colors.white),
        ),
        iconColor: Colors.white,
        dense: false,
        trailing: node.children.isNotEmpty
            ? SizedBox.shrink()
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 1.5,
                    child: Radio(
                        fillColor: MaterialStateProperty.all(Colors.white),
                        value: node.key,
                        groupValue: activityId,
                        onChanged: (value) {
                          setState(() {
                            activityId = value.toString();
                            selectedName = activityName;
                            activityPath = node.parent!.path;
                          }); //selected value
                        }),
                  )
                ],
              ),
      ),
    );
  }
}
