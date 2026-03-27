# Playback Quality Button Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a quality change button to youtube_player_flutter allowing users to select video playback quality (240p through 2160p).

**Architecture:** Create PlaybackQuality enum for quality constants, add setPlaybackQuality method to controller, implement PlaybackQualityButton widget following PlaybackSpeedButton pattern, integrate into bottom controls bar.

**Tech Stack:** Flutter, YouTube IFrame Player API, flutter_inappwebview

---

## File Structure

### Files to Create
- `packages/youtube_player_flutter/lib/src/enums/playback_quality.dart` - Quality level constants and display name mapping
- `packages/youtube_player_flutter/lib/src/widgets/playback_quality_button.dart` - Quality button widget

### Files to Modify
- `packages/youtube_player_flutter/lib/src/utils/youtube_player_controller.dart` - Add setPlaybackQuality() method
- `packages/youtube_player_flutter/lib/src/widgets/widgets.dart` - Export new widget
- `packages/youtube_player_flutter/lib/src/player/raw_youtube_player.dart` - Add setPlaybackQuality JS function
- `packages/youtube_player_flutter/lib/src/player/youtube_player.dart` - Add button to bottom bar
- `packages/youtube_player_flutter/lib/youtube_player_flutter.dart` - Export PlaybackQuality enum

---

## Task 1: Create PlaybackQuality Enum

**Files:**
- Create: `packages/youtube_player_flutter/lib/src/enums/playback_quality.dart`

- [ ] **Step 1: Create the enum file**
```dart
// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Defines the playback quality levels for YouTube videos.
class PlaybackQuality {
  PlaybackQuality._();

  /// Auto quality (YouTube decides)
  static const String auto = 'auto';

  /// Small quality (~240p)
  static const String small = 'small';

  /// Medium quality (~360p)
  static const String medium = 'medium';

  /// Large quality (~480p)
  static const String large = 'large';

  /// HD 720p quality
  static const String hd720 = 'hd720';

  /// HD 1080p quality
  static const String hd1080 = 'hd1080';

  /// HD 1440p quality
  static const String hd1440 = 'hd1440';

  /// HD 2160p (4K) quality
  static const String hd2160 = 'hd2160';

  /// Returns a user-friendly display name for a quality level.
  static String getDisplayName(String quality) {
    switch (quality) {
      case 'small':
        return '240p';
      case 'medium':
        return '360p';
      case 'large':
        return '480p';
      case 'hd720':
        return '720p';
      case 'hd1080':
        return '1080p';
      case 'hd1440':
        return '1440p';
      case 'hd2160':
        return '2160p';
      case 'highres':
        return '4K+';
      case 'auto':
      default:
        return 'Auto';
    }
  }

  /// All available quality levels (excluding auto).
  static const List<String> values = [
    small,
    medium,
    large,
    hd720,
    hd1080,
    hd1440,
    hd2160,
  ];
}
```

- [ ] **Step 2: Verify file structure**
Run: `ls packages/youtube_player_flutter/lib/src/enums/`
Expected: `playback_rate.dart  playback_quality.dart  player_state.dart  thumbnail_quality.dart`

- [ ] **Step 3: Commit**
```bash
git add packages/youtube_player_flutter/lib/src/enums/playback_quality.dart
git commit -m "feat: add PlaybackQuality enum for quality level constants"
```

---

## Task 2: Add setPlaybackQuality to Controller

**Files:**
- Modify: `packages/youtube_player_flutter/lib/src/utils/youtube_player_controller.dart` (after line 284)

- [ ] **Step 1: Add import for PlaybackQuality**
After line 11 (after `import '../enums/playback_rate.dart';`), add:
```dart
import '../enums/playback_quality.dart';
```

- [ ] **Step 2: Add setPlaybackQuality method**
After line 284 (after `setPlaybackRate` method), add:
```dart

  /// Sets the suggested playback quality for the current video.
  /// The player will attempt to use the closest available quality if the
  /// requested quality is not available.
  void setPlaybackQuality(String quality) =>
      _callMethod('setPlaybackQuality("$quality")');
```

- [ ] **Step 3: Verify syntax**
Run: `cd packages/youtube_player_flutter && dart analyze lib/src/utils/youtube_player_controller.dart`
Expected: No issues found

- [ ] **Step 4: Commit**
```bash
git add packages/youtube_player_flutter/lib/src/utils/youtube_player_controller.dart
git commit -m "feat: add setPlaybackQuality method to YoutubePlayerController"
```

---

## Task 3: Add JavaScript setPlaybackQuality Function

**Files:**
- Modify: `packages/youtube_player_flutter/lib/src/player/raw_youtube_player.dart`

- [ ] **Step 1: Add JavaScript function to the embedded HTML template**
Inside the `player` string template (the HTML/JavaScript embedded in the Dart file), after the `setPlaybackRate` function (around line 386), add the following JavaScript code:
```dart

function setPlaybackQuality(quality) {
  player.setPlaybackQuality(quality);
  return '';
}
```

**Note:** This is JavaScript code being added inside the Dart multi-line string template (`player => '''...'''`). The function is part of the embedded HTML that runs in the WebView.

- [ ] **Step 2: Verify syntax**
Run: `cd packages/youtube_player_flutter && dart analyze lib/src/player/raw_youtube_player.dart`
Expected: No issues found

- [ ] **Step 3: Commit**
```bash
git add packages/youtube_player_flutter/lib/src/player/raw_youtube_player.dart
git commit -m "feat: add setPlaybackQuality JavaScript function to player"
```

---

## Task 4: Create PlaybackQualityButton Widget

**Files:**
- Create: `packages/youtube_player_flutter/lib/src/widgets/playback_quality_button.dart`

- [ ] **Step 1: Create the widget file**
```dart
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
    return PopupMenuButton<String>(
      onSelected: _controller.setPlaybackQuality,
      tooltip: 'Playback Quality',
      itemBuilder: (context) => [
        _popUpItem('Auto', 'auto'),
        _popUpItem('2160p', 'hd2160'),
        _popUpItem('1440p', 'hd1440'),
        _popUpItem('1080p', 'hd1080'),
        _popUpItem('720p', 'hd720'),
        _popUpItem('480p', 'large'),
        _popUpItem('360p', 'medium'),
        _popUpItem('240p', 'small'),
      ],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
        child: widget.icon ??
            const Icon(
              Icons.settings,
              color: Colors.white,
              size: 20.0,
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
```

- [ ] **Step 2: Verify syntax**
Run: `cd packages/youtube_player_flutter && dart analyze lib/src/widgets/playback_quality_button.dart`
Expected: No issues found

- [ ] **Step 3: Commit**
```bash
git add packages/youtube_player_flutter/lib/src/widgets/playback_quality_button.dart
git commit -m "feat: add PlaybackQualityButton widget"
```

---

## Task 5: Export Widget from widgets.dart

**Files:**
- Modify: `packages/youtube_player_flutter/lib/src/widgets/widgets.dart`

- [ ] **Step 1: Add export**
At the end of the file (after `export 'youtube_player_builder.dart';`), add:
```dart
export 'playback_quality_button.dart';
```

- [ ] **Step 2: Verify syntax**
Run: `cd packages/youtube_player_flutter && dart analyze lib/src/widgets/widgets.dart`
Expected: No issues found

- [ ] **Step 3: Commit**
```bash
git add packages/youtube_player_flutter/lib/src/widgets/widgets.dart
git commit -m "feat: export PlaybackQualityButton from widgets.dart"
```

---

## Task 6: Export Enum from Main Library

**Files:**
- Modify: `packages/youtube_player_flutter/lib/youtube_player_flutter.dart`

- [ ] **Step 1: Add export**
After line 5 (after `export 'src/enums/thumbnail_quality.dart';`), add:
```dart
export 'src/enums/playback_quality.dart';
```

- [ ] **Step 2: Verify syntax**
Run: `cd packages/youtube_player_flutter && dart analyze lib/youtube_player_flutter.dart`
Expected: No issues found

- [ ] **Step 3: Commit**
```bash
git add packages/youtube_player_flutter/lib/youtube_player_flutter.dart
git commit -m "feat: export PlaybackQuality enum from main library"
```

---

## Task 7: Integrate Button into Bottom Bar

**Files:**
- Modify: `packages/youtube_player_flutter/lib/src/player/youtube_player.dart` (around line 404)

- [ ] **Step 1: Add PlaybackQualityButton to bottom bar**
At line 405 (after `const PlaybackSpeedButton(),` and before `const SizedBox(width: 16),`), add:
```dart
                const PlaybackQualityButton(),
```

The bottom bar section should look like:
```dart
                const CurrentPosition(),
                const SizedBox(width: 8.0),
                ProgressBar(
                  isExpanded: true,
                  colors: widget.progressColors,
                ),
                const RemainingDuration(),
                const PlaybackSpeedButton(),
                const PlaybackQualityButton(),
                const SizedBox(width: 16),
```

- [ ] **Step 2: Verify syntax**
Run: `cd packages/youtube_player_flutter && dart analyze lib/src/player/youtube_player.dart`
Expected: No issues found

- [ ] **Step 3: Commit**
```bash
git add packages/youtube_player_flutter/lib/src/player/youtube_player.dart
git commit -m "feat: add PlaybackQualityButton to player bottom bar"
```

---

## Task 8: Run Package Analysis

- [ ] **Step 1: Run full package analysis**
Run: `cd packages/youtube_player_flutter && dart analyze`
Expected: No issues found

- [ ] **Step 2: Verify all files are tracked**
Run: `git status`
Expected: Nothing to commit, working tree clean

- [ ] **Step 3: Create summary commit if needed**
If any uncommitted changes remain:
```bash
git add -A
git commit -m "feat: complete playback quality button implementation"
```

---

## Verification Checklist

After implementation, verify:
- [ ] Package analysis passes with no errors
- [ ] All new files are committed
- [ ] PlaybackQuality enum is accessible from main library
- [ ] PlaybackQualityButton is exported from widgets.dart
- [ ] Button appears in bottom bar after PlaybackSpeedButton

---

## Task 9: Manual Functional Verification

- [ ] **Step 1: Run the example app**
Run: `cd packages/youtube_player_flutter/example && flutter run`
Expected: App launches with a video player

- [ ] **Step 2: Test quality button visibility**
1. Play a video in the example app
2. Tap on the video to show controls
3. Verify the quality button (gear icon) appears in the bottom bar next to the speed button

- [ ] **Step 3: Test quality selection**
1. Tap the quality button
2. Verify popup shows: Auto, 2160p, 1440p, 1080p, 720p, 480p, 360p, 240p
3. Select a quality level (e.g., 720p)
4. Verify popup closes and quality is applied to the video

- [ ] **Step 4: Verify checked state**
1. Tap the quality button again
2. Verify the previously selected quality shows a checkmark
