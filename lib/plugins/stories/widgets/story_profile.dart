import 'package:dating_app/datas/user.dart';
import 'package:dating_app/dialogs/report_dialog.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/plugins/stories/datas/story.dart';
import 'package:dating_app/plugins/stories/widgets/cached_circle_avatar.dart';
import 'package:dating_app/plugins/stories/widgets/cached_image.dart';
import 'package:dating_app/widgets/badge.dart';
import 'package:dating_app/widgets/default_card_border.dart';
import 'package:flutter/material.dart';

class StoryProfile extends StatefulWidget {
  // Variables
  final Story story;
  final Function() onTap;

  const StoryProfile({Key? key, required this.story, required this.onTap})
      : super(key: key);

  @override
  _StoryProfileState createState() => _StoryProfileState();
}

class _StoryProfileState extends State<StoryProfile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Story cover
            Card(
                color: widget.story.mediaType == MediaType.video
                    ? Colors.pinkAccent[100]
                    : widget.story.color,
                clipBehavior: Clip.antiAlias,
                elevation: 4.0,
                margin: const EdgeInsets.all(0),
                shape: defaultCardBorder(),
                child: _showStory(context)),
            // Author image
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  // Show profile info
                  child: FutureBuilder<User>(
                      future: UserModel().getUserObject(widget.story.userId),
                      builder: (context, snapshot) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Author photo
                            Container(
                                padding: const EdgeInsets.all(3.0),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: snapshot.hasData
                                    ? CachedCicleAvatar(
                                        snapshot.data!.userProfilePhoto)
                                    : CircleAvatar(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        radius: 40)),
                            const SizedBox(height: 5),
                            // Profile name
                            Text(
                                snapshot.hasData
                                    ? snapshot.data!.userFullname.split(' ')[0]
                                    : '',
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))
                          ],
                        );
                      })),
            ),
            // Show Total Stories
            Positioned(
              top: 10, left: 5,
              child: MyBadge(
                  bgColor: Colors.white,
                  padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
                  icon: Icon(Icons.play_circle_outline,
                      size: 20, color: Theme.of(context).primaryColor),
                  textStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                  text: widget.story.totalStories.toString()), // Total stories
            ),

            // Check current User ID
            if (UserModel().user.userId != widget.story.userId)
              Positioned(
                top: 4,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.flag, color: Colors.white, size: 30),
                  // Report/Block profile dialog
                  onPressed: () => ReportDialog(
                          isStoryProfile: true,
                          story: widget.story,
                          userId: widget.story.userId)
                      .show(),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _showStory(BuildContext context) {
    // Local variables
    Widget content = Container();

    // Control Story type
    switch (widget.story.mediaType) {
      // Video Story
      case MediaType.video:
        // Show Video Thumbnail
        content = Stack(
          fit: StackFit.expand,
          children: [
            CachedImage(widget.story.thumbnailUrl,
                pIconData: Icons.play_circle_outline),
            // Show play icon
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 70),
                child: Icon(Icons.play_circle_outline,
                    size: 50, color: Colors.white),
              ),
            ),
          ],
        );
        break;
      // Image Story
      case MediaType.image:
        content =
            CachedImage(widget.story.url, pIconData: Icons.play_circle_outline);
        break;
      // Text Story
      case MediaType.text:
        content = Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(widget.story.caption,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, color: Colors.white)),
        );
        break;
    }
    return content;
  }
}
