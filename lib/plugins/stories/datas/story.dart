import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/plugins/stories/constants/constants.dart';
import 'package:flutter/material.dart';

enum MediaType { video, image, text }

class Story {
  final String userId;
  final String userGender;
  final String storyId;
  final MediaType mediaType;
  final String url;
  final String thumbnailUrl;
  final String caption;
  final DateTime date;
  final Color color;
  final int totalStories;

  Story(
      {required this.userId,
      required this.storyId,
      required this.userGender,
      required this.mediaType,
      required this.caption,
      required this.date,
      required this.url,
      required this.thumbnailUrl,
      required this.color,
      required this.totalStories});

  /// factory Story object
  factory Story.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Story(
        userId: doc.data()![USER_ID],
        userGender: doc.data()?[USER_GENDER] ?? '',
        storyId: doc.id,
        mediaType: _getMediaType(doc.data()![STORY_TYPE]),
        caption: doc.data()?[STORY_CAPTION] ?? '',
        url: doc.data()?[STORY_URL] ?? '',
        thumbnailUrl: doc.data()?[STORY_THUMBNAIL_URL] ?? '',
        color: getColorObject(doc.data()?[STORY_COLOR]) as Color,
        date: doc.data()?[TIMESTAMP] == null
            ? DateTime.now()
            : doc.data()?[TIMESTAMP].toDate(),
        totalStories: doc.data()?[TOTAL_STORIES] ?? 0);
  }
}

// Covert HTML Color Code to Color object
Color? getColorObject(String? htmlColor) {
  if (htmlColor != null && htmlColor != '') {
    return Color(int.parse(htmlColor.replaceAll('#', '0xff')));
  }
  return null;
}

// Covert Color object to HTML Color Code
String? getHtmlColor(Color? color) {
  if (color != null) {
    final String htmlColor =
        '#' + color.toString().split('0xff')[1].replaceAll(')', '');
    return htmlColor;
  }
  return null;
}

// Control story type
MediaType _getMediaType(String storyType) {
  //print(storyType);
  late MediaType mediaType;
  // Control Story type
  switch (storyType) {
    case 'video':
      mediaType = MediaType.video;
      break;
    case 'image':
      mediaType = MediaType.image;
      break;
    case 'text':
      mediaType = MediaType.text;
      break;
  }
  return mediaType;
}

// Control Story Media type
String translateStoryType(MediaType mediaType) {
  String media = '';
  // Control Story type
  switch (mediaType) {
    case MediaType.video:
      media = 'video';
      break;
    case MediaType.image:
      media = 'image';
      break;
    case MediaType.text:
      media = 'text';
      break;
  }
  return media;
}
