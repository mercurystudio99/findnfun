import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/plugins/stories/api/stories_api.dart';
import 'package:dating_app/plugins/stories/datas/story.dart';
import 'package:dating_app/plugins/stories/screens/view_story_screen.dart';
import 'package:dating_app/plugins/stories/widgets/story_profile.dart';
import 'package:dating_app/widgets/no_data.dart';
import 'package:dating_app/widgets/processing.dart';
import 'package:dating_app/widgets/users_grid.dart';
import 'package:flutter/material.dart';

class StoriesTab extends StatefulWidget {
  const StoriesTab({Key? key}) : super(key: key);

  @override
  _StoriesTabState createState() => _StoriesTabState();
}

class _StoriesTabState extends State<StoriesTab> {
  // Variables
  final _storiesApi = StoriesApi();
  late AppLocalizations _i18n;

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);

    return StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
        stream: _storiesApi.getStoryProfiles(),
        builder: (context, snapshot) {
          // Check result
          if (!snapshot.hasData) {
            return Processing(text: _i18n.translate("loading"));
          } else if (snapshot.data!.isEmpty) {
            /// No Stories
            return NoData(
                icon: Icon(Icons.play_circle_outline,
                    size: 100, color: Theme.of(context).primaryColor),
                text: _i18n.translate("no_story"));
          } else {
            //
            // Handle the Story Profiles to Pin the Current User Profile
            //
            // Get all Story Profiles
            List<DocumentSnapshot<Map<String, dynamic>>> allProfiles =
                snapshot.data!;

            // Filter the Story Profile Genders
            _storiesApi.filterProfilesGenders(allProfiles);

            // Loop the Story Profiles
            for (var storyProfile in allProfiles) {
              // Check the current user story profile
              if (storyProfile.id == UserModel().user.userId) {
                // Remove the current user story profile from the list
                allProfiles.remove(storyProfile);
                // Make the current user story profile Featured - (Pinned)
                allProfiles.insert(0, storyProfile);
              }
            }

            /// Sort by newest Story Profiles
            allProfiles.sort((a, b) {
              final DateTime storyRegDateA = a[TIMESTAMP].toDate();
              final DateTime storyRegDateB = b[TIMESTAMP].toDate();
              return storyRegDateB.compareTo(storyRegDateA);
            });

            // Show Story Profiles
            return UsersGrid(
                itemCount: allProfiles.length,
                itemBuilder: (context, index) {
                  // Get Story document
                  final DocumentSnapshot<Map<String, dynamic>> storyDoc =
                      allProfiles[index];
                  // Get Story object
                  final Story story = Story.fromDocument(storyDoc);

                  // Show the latest story profiles
                  return StoryProfile(
                    story: story,
                    onTap: () async {
                      // Go to Story screen
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              StoryScreen(userId: story.userId)));
                    },
                  );
                });
          }
        });
  }
}
