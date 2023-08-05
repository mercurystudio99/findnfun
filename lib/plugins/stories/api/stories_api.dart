import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/plugins/stories/constants/constants.dart';
import 'package:dating_app/plugins/stories/datas/story.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/plugins/geoflutterfire/geoflutterfire.dart';

class StoriesApi {
  /// Variables
  ///
  /// Get firestore instance
  final _firestore = FirebaseFirestore.instance;

  /// Initialize geoflutterfire instance
  final _geo = Geoflutterfire();

  /// Get user settings
  final Map<String, dynamic>? _settings = UserModel().user.userSettings;

  // Save Story
  Future<void> saveStory({
    required String storyType,
    required String storyCaption,
    required String storyColor,
    required File? storyFile,
    required File? storyThumbnailFile,
  }) async {
    // Variables
    String storyUrl = '';
    String storyThumbnailUrl = '';

    /// Set Geolocation point to Story Profile
    final GeoFirePoint _geoPoint = _geo.point(
        latitude: UserModel().user.userGeoPoint.latitude,
        longitude: UserModel().user.userGeoPoint.longitude);

    // Check Media type to process upload
    if (storyType != 'text') {
      /// Upload file
      storyUrl = await UserModel().uploadFile(
          file: storyFile!,
          path: 'uploads/stories',
          userId: UserModel().user.userId);
      // Check Video Story
      if (storyType == 'video') {
        /// Upload video thumbnail file
        storyThumbnailUrl = await UserModel().uploadFile(
            file: storyThumbnailFile!,
            path: 'uploads/stories/thumbnails',
            userId: UserModel().user.userId);
      }
    }

    // Save Story
    await _firestore.collection(C_STORIES).add({
      USER_ID: UserModel().user.userId,
      USER_GENDER: UserModel().user.userGender,
      STORY_STATUS: 'active',
      STORY_TYPE: storyType,
      STORY_URL: storyUrl,
      STORY_THUMBNAIL_URL: storyThumbnailUrl,
      STORY_CAPTION: storyCaption,
      STORY_COLOR: storyColor,
      TIMESTAMP: FieldValue.serverTimestamp(),
    });

    // Save Last Story in Profiles Group
    await _firestore
        .collection(C_STORY_PROFILES)
        .doc(UserModel().user.userId)
        .set({
      USER_ID: UserModel().user.userId,
      USER_GENDER: UserModel().user.userGender,
      USER_GEO_POINT: _geoPoint.data,
      STORY_STATUS: 'active',
      STORY_TYPE: storyType,
      STORY_URL: storyUrl,
      STORY_THUMBNAIL_URL: storyThumbnailUrl,
      STORY_CAPTION: storyCaption,
      STORY_COLOR: storyColor,
      TIMESTAMP: FieldValue.serverTimestamp(),
      TOTAL_STORIES: FieldValue.increment(1)
    }, SetOptions(merge: true));
  }

  // Delete the Story
  Future<void> deleteStory({required Story story}) async {
    // Check Story media type
    if (story.mediaType == MediaType.image) {
      // Delete the story image file
      await FirebaseStorage.instance.refFromURL(story.url).delete();
    } else if (story.mediaType == MediaType.video) {
      // Delete the story video file
      await FirebaseStorage.instance.refFromURL(story.url).delete();

      // Delete the story thumbnail file
      await FirebaseStorage.instance.refFromURL(story.thumbnailUrl).delete();
    }

    // Get updated user stories list
    final List<Story> stories = await getStories(story.userId);
    // Get current total stories
    final int total = stories.length;

    // Delete Story Document
    (await _firestore.collection(C_STORIES).doc(story.storyId).get())
        .reference
        .delete();

    // Check the total stories to decrement
    if (total > 1) {
      // Replace the Deleted Story with next one
      await _updateStoryProfile(stories.last, total);
    } else {
      // Also Delete the Story profile
      (await _firestore.collection(C_STORY_PROFILES).doc(story.userId).get())
          .reference
          .delete();
    }
  }

  Future<void> _updateStoryProfile(Story story, int total) async {
    // Get current total stories
    //
    int totalStories = total;
    // Check to decrement
    if (total > 1) {
      totalStories = totalStories - 1;
    }
    // Replace the Deleted Story with next Story
    await _firestore.collection(C_STORY_PROFILES).doc(story.userId).update({
      USER_ID: story.userId,
      USER_GENDER: story.userGender,
      STORY_TYPE: translateStoryType(story.mediaType),
      STORY_URL: story.url,
      STORY_THUMBNAIL_URL: story.thumbnailUrl,
      STORY_CAPTION: story.caption,
      STORY_COLOR: getHtmlColor(story.color),
      TIMESTAMP: FieldValue.serverTimestamp(),
      TOTAL_STORIES: totalStories
    });
  }

  /// Get Story Profiles Stream
  Stream<List<DocumentSnapshot<Map<String, dynamic>>>> getStoryProfiles() {
    // Build query
    Query<Map<String, dynamic>> query = _firestore
        .collection(C_STORY_PROFILES)
        .where(STORY_STATUS, isEqualTo: 'active');


    // Get current user geo center
    final GeoFirePoint center = _geo.point(
        latitude: UserModel().user.userGeoPoint.latitude,
        longitude: UserModel().user.userGeoPoint.longitude);

    // Get Story Profiles Stream
    Stream<List<DocumentSnapshot<Map<String, dynamic>>>> stream = _geo
        .collection(collectionRef: query)
        .within(
            center: center,
            radius: _settings![USER_MAX_DISTANCE].toDouble(),
            field: USER_GEO_POINT,
            strictMode: true);

    return stream;
  }

  // Get User Stories
  Future<List<Story>> getStories(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> query = await _firestore
        .collection(C_STORIES)
        .where(USER_ID, isEqualTo: userId)
        .orderBy(TIMESTAMP, descending: true)
        .get();
    // Story object
    List<Story> _stories = [];
    // Check result
    if (query.docs.isNotEmpty) {
      // Loop data to add stories
      for (var storyDoc in query.docs) {
        // Get Story object
        final Story story = Story.fromDocument(storyDoc);
        // Add story object
        _stories.add(story);
      }
    }
    return _stories;
  }

  /// Flag Story
  Future<void> flagStory(
      {bool isStoryProfile = false,
      required Story story,
      required String reason}) async {
    // Get the updated user stories list
    final List<Story> stories = await getStories(story.userId);
    // Get current total stories
    final int total = stories.length;

    // Get Story ID
    String storyId = story.storyId;

    // Check origin
    if (isStoryProfile) {
      // Get the "First Story ID" from the list to be Reported.
      storyId = stories.first.storyId;
    }

    // Update Story Status
    //
    await _firestore.collection(C_STORIES).doc(storyId).update({
      STORY_STATUS: 'flagged',
      // Flag info
      FLAG_REASON: reason,
      FLAGGED_BY_USER_ID: UserModel().user.userId,
      STORY_FLAGGED_TIME: FieldValue.serverTimestamp()
    });

    if (total > 1) {
      // Update the Story Profile
      await _updateStoryProfile(stories[1], total);
    } else {
      // Update the Story Profile
      await _updateStoryProfile(stories.first, total);
    }
  }

  //
  // DELETE ALL STORIES for current user when deleting their profile account.
  //
  Future<void> deleteAllStories() async {
    // Query all stories posted by current user.
    final QuerySnapshot<Map<String, dynamic>> queryStories = await _firestore
        .collection(C_STORIES)
        .where(USER_ID, isEqualTo: UserModel().user.userId)
        .get();

    // Check result
    if (queryStories.docs.isNotEmpty) {
      // Init process
      debugPrint('deleteAllStories() -> processing...');

      // Loop data to add stories
      for (var storyDoc in queryStories.docs) {
        // Get Story object
        final Story story = Story.fromDocument(storyDoc);

        // Check Story media type
        if (story.mediaType == MediaType.image) {
          // Delete the story image file
          await FirebaseStorage.instance.refFromURL(story.url).delete();
        } else if (story.mediaType == MediaType.video) {
          // Delete the story video file
          await FirebaseStorage.instance.refFromURL(story.url).delete();

          // Delete the story thumbnail file
          await FirebaseStorage.instance
              .refFromURL(story.thumbnailUrl)
              .delete();
        }

        // Delete Story Document
        (await _firestore.collection(C_STORIES).doc(story.storyId).get())
            .reference
            .delete();

        // Delete Story profile as well.
        (await _firestore.collection(C_STORY_PROFILES).doc(story.userId).get())
            .reference
            .delete();
      }
      // Debug
      debugPrint('deleteAllStories() -> finished...');
    } else {
      // Debug
      debugPrint('No Story found for this user');
    }
  }

  // Filter the Story Profiles Genders
  void filterProfilesGenders(List<DocumentSnapshot> allProfiles) {
    /// Get user settings
    final Map<String, dynamic>? settings = UserModel().user.userSettings;

    // Handle Show Me option
    if (settings != null) {
      // Check show me option
      if (settings[USER_SHOW_ME] != null) {
        // Control show me option
        switch (settings[USER_SHOW_ME]) {
          case 'men':
            // Remove all Female Profiles to keep only Male-Genders
            _removeStoryGenders(allProfiles, 'Female');
            break;

          case 'women':
            // Remove all Male Profiles to keep only Female-Genders
            _removeStoryGenders(allProfiles, 'Male');
            break;
          case 'everyone':
            // Do nothing - app will get everyone
            break;
        }
      } else {
        // Filter to show the opposite gender
        _removeStoryGenders(allProfiles, UserModel().user.userGender);
      }
    }
  }

  // Remove the Story Profile gender
  void _removeStoryGenders(List<DocumentSnapshot> profiles, String gender) {
    // Remove the Story Genders
    profiles.removeWhere((storyProfile) {
      // Check the Current User Profile ID to be Ignored
      if (UserModel().user.userId == storyProfile[USER_ID]) {
        return false;
      }
      return storyProfile[USER_GENDER] == gender;
    });
  }

}
