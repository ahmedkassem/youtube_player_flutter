// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../utils/youtube_player_controller.dart';

/// A widget to display playback quality changing button.
class PlaybackQualityButton extends StatefulWidget {
  /// Creates [PlaybackQualityButton] widget.
  const PlaybackQualityButton({
    super.key,
    this.controller,
    this.icon,
  });

  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController? controller;

  /// Defines icon for the button.
  final Widget? icon;

  @override
  State<PlaybackQualityButton> createState() => _PlaybackQualityButtonState();
}

class _PlaybackQualityButtonState extends State<PlaybackQualityButton> {
  late YoutubePlayerController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = YoutubePlayerController.of(context);
    if (controller == null) {
      assert(
        widget.controller != null,
        '\n\nNo controller could be found in the provided context.\n\n'
        'Try passing the controller explicitly.',
      );
      _controller = widget.controller!;
    } else {
      _controller = controller;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('=== PlaybackQualityButton: build called ===');
    return PopupMenuButton<String>(
      onSelected: (quality) {
        debugPrint(
            'PlaybackQualityButton: onSelected called with quality=$quality');
        _controller.setPlaybackQuality(quality);
      },
      tooltip: 'Playback Quality',
      itemBuilder: (context) {
        debugPrint('PlaybackQualityButton: itemBuilder called');
        return [
          _popUpItem('Auto', 'auto'),
          _popUpItem('2160p', 'hd2160'),
          _popUpItem('1440p', 'hd1440'),
          _popUpItem('1080p', 'hd1080'),
          _popUpItem('720p', 'hd720'),
          _popUpItem('480p', 'large'),
          _popUpItem('360p', 'medium'),
          _popUpItem('240p', 'small'),
        ];
      },
      child: GestureDetector(
        onTap: () {
          debugPrint('PlaybackQualityButton: Settings icon tapped!');
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
          child: widget.icon ??
              const Icon(
                Icons.settings,
                color: Colors.white,
                size: 20.0,
              ),
        ),
      ),
    );
  }

  PopupMenuEntry<String> _popUpItem(String text, String quality) {
    // Note: If playbackQuality is null (initial state), no item will be checked
    // until a quality event fires from YouTube. This is expected behavior.
    return CheckedPopupMenuItem(
      checked: _controller.value.playbackQuality == quality,
      value: quality,
      child: Text(text),
    );
  }
}
