import 'dart:io';

import 'package:dating_app/dialogs/common_dialogs.dart';
import 'package:dating_app/dialogs/progress_dialog.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/plugins/stories/api/stories_api.dart';
import 'package:dating_app/plugins/stories/datas/story.dart';
import 'package:dating_app/widgets/default_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class AddStoryScreen extends StatefulWidget {
  // Variables
  final MediaType mediaType;
  final File? storyFile;

  const AddStoryScreen({Key? key, this.storyFile, required this.mediaType}) : super(key: key);

  @override
  _AddStoryScreenState createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  // Variables
  final _storyCaptionController = TextEditingController();
  final _storiesApi = StoriesApi();
  late AppLocalizations _i18n;
  late ProgressDialog _pr;
  bool _isComposing = false;
  File? _videoThumbnailFile;

  // Color picker options
  Color _pickedStoryColor = const Color(0xffe91e63); // Default Pink
  Color _currentColorPicker = const Color(0xffe91e63); // Default Pink

  // Change Story Color
  void _changeStoryColor() {
    setState(() => _pickedStoryColor = _currentColorPicker);
    debugPrint(_currentColorPicker.toString());
  }

  // Get Video thumbnail
  Future<void> _getVideoThumbnail() async {
    // Check the story media type
    if (widget.mediaType == MediaType.video) {
      await VideoThumbnail.thumbnailFile(
        video: widget.storyFile!.path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 400,
      ).then((String? path) {
        // Check the path
        if (path != null) {
          // Get video thumbnail file
          if (mounted) {
            setState(() {
              _videoThumbnailFile = File(path);
            });
          }
        }
      });
    }
  }

  // Show video thumbnail
  Widget _showVideoThumbnail() {
    if (_videoThumbnailFile == null) {
      return Icon(Icons.videocam,
          size: 70, color: Theme.of(context).primaryColor);
    } else {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(_videoThumbnailFile!, fit: BoxFit.cover),
          const Center(
            child:
                Icon(Icons.play_circle_outline, size: 70, color: Colors.white),
          )
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Get Video thumbnail
    _getVideoThumbnail();
  }

  @override
  void dispose() {
    super.dispose();
    _storyCaptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    _pr = ProgressDialog(context, isDismissible: false);
    Color? backgroundColor;
    Widget body = _writeTextStory();

    // Check Story media type to show background color
    if (widget.mediaType == MediaType.text) {
      backgroundColor = _pickedStoryColor;
      body = _writeTextStory();
    } else {
      body = _showPickedFileStory();
    }

    // Scaffold
    return Scaffold(
      appBar: AppBar(
        title: Text(_i18n.translate('add_a_story')),
        actions: [
          // Check to show the Color picker for text story
          if (widget.mediaType == MediaType.text)
            IconButton(
                icon: Icon(Icons.color_lens, color: _pickedStoryColor),
                onPressed: () => _pickStoryColor()),
        ],
      ),
      backgroundColor: backgroundColor,
      body: body,
      // Check to display send story button only for [MediaType.text]
      floatingActionButton: _isComposing
          ? FloatingActionButton(
              child: const Icon(Icons.send),
              onPressed: () async {
                // Send text Story
                _sendStory();
              })
          : null,
    );
  }

  // Send the story
  void _sendStory() async {
    // Variables
    final String? storyText = _storyCaptionController.text;
    String storyType;

    // Control the Story media type
    switch (widget.mediaType) {
      case MediaType.video:
        storyType = 'video';
        break;
      case MediaType.image:
        storyType = 'image';
        break;
      case MediaType.text:
        storyType = 'text';
        break;
    }
    // Clean text input and disable composing to avoid sending the story twice
    if (storyType == 'text') {
      setState(() {
        _isComposing = false;
      });
    }
    // Clear text input
    _storyCaptionController.clear();

    // Show processing dialog
    _pr.show(_i18n.translate("processing"));

    // Send text Story
    await _storiesApi.saveStory(
        storyType: storyType,
        storyCaption: storyText ?? '',
        storyFile: widget.storyFile,
        storyThumbnailFile: _videoThumbnailFile,
        storyColor: getHtmlColor(_pickedStoryColor) as String);

     // Close processing dialog
     _pr.hide();

    // Show message to user
    successDialog(context, message: _i18n.translate('story_sent_successfully'),
        positiveAction: () {
      // Close dialog
      Navigator.of(context).pop();
      // Close screen
      Navigator.of(context).pop();
    });
  }

  // Show picked file story
  Widget _showPickedFileStory() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          // Show Story File
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: widget.mediaType == MediaType.video
                  // Show video thumbnail
                  ? _showVideoThumbnail()
                  // Show Story Image
                  : Image.file(widget.storyFile!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 25),
          // Story Caption
          TextField(
            controller: _storyCaptionController,
            decoration: InputDecoration(
                labelText: _i18n.translate('story_caption'),
                hintText: _i18n.translate('write_story_caption_optional'),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                prefixIcon: const Icon(Icons.edit)),
          ),
          const SizedBox(
            height: 25,
          ),
          // Send Story button
          SizedBox(
              width: double.maxFinite,
              child: DefaultButton(
                  child: Text(_i18n.translate('SEND'),
                      style: const TextStyle(fontSize: 18)),
                  onPressed: () async {
                    // Send the Story
                    _sendStory();
                  }))
        ],
      ),
    );
  }

  // Write text story
  Widget _writeTextStory() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: TextField(
          maxLines: null,
          cursorColor: Colors.white70,
          autofocus: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: _i18n.translate('write_a_story'),
            hintStyle: const TextStyle(
              color: Colors.white70,
              decoration: TextDecoration.none,
            ),
            contentPadding: const EdgeInsets.all(10),
          ),
          controller: _storyCaptionController,
          onChanged: (text) {
            // Update UI
            setState(() {
              _isComposing = text.trim().isNotEmpty;
            });
          },
          style: const TextStyle(
              fontSize: 35,
              color: Colors.white,
              decoration: TextDecoration.none),
        ),
      ),
    );
  }

  // Pick Story Color
  void _pickStoryColor() {
    // Show color options
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
            title: Text(_i18n.translate('pick_a_color'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: _currentColorPicker,
                onColorChanged: (newColor) {
                  _currentColorPicker = newColor;
                },
              ),
            ),
            actions: <Widget>[
              // Close button
              TextButton(
                  child: Text(_i18n.translate('CANCEL'),
                      style: const TextStyle(fontSize: 18, color: Colors.grey)),
                  onPressed: () => Navigator.of(context).pop()),

              TextButton(
                child: Text(_i18n.translate('CHANGE'),
                    style: TextStyle(
                        fontSize: 18, color: Theme.of(context).primaryColor)),
                onPressed: () {
                  // Change Story Color
                  _changeStoryColor();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
