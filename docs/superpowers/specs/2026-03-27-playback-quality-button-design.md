# Playback Quality Button Design

**Date:** 2026-03-27
**Package:** youtube_player_flutter
**Author:** Design Session

## Summary

Add a quality change button to the youtube_player_flutter package, allowing users to manually select video playback quality (240p, 360p, 480p, 720p, 1080p, etc.) through the player's bottom controls bar.

## Requirements

- Quality button in bottom controls bar (same position as PlaybackSpeedButton)
- Always visible by default (no opt-in flag)
- User-friendly quality labels (360p, 480p, 720p, etc.)
- Follow existing PlaybackSpeedButton pattern for consistency

## Architecture

### Files to Create

1. **`packages/youtube_player_flutter/lib/src/enums/playback_quality.dart`** - Quality level constants and display name mapping
2. **`packages/youtube_player_flutter/lib/src/widgets/playback_quality_button.dart`** - Quality button widget

### Files to Modify

1. **`packages/youtube_player_flutter/lib/src/utils/youtube_player_controller.dart`** - Add `setPlaybackQuality()` method
2. **`packages/youtube_player_flutter/lib/src/widgets/widgets.dart`** - Export new widget
3. **`packages/youtube_player_flutter/lib/src/player/raw_youtube_player.dart`** - Add `setPlaybackQuality` JS function
4. **`packages/youtube_player_flutter/lib/src/player/youtube_player.dart`** - Add button to bottom bar
5. **`packages/youtube_player_flutter/lib/youtube_player_flutter.dart`** - Export `PlaybackQuality` enum from main library

### Existing Infrastructure (No Changes Needed)

- `playbackQuality` field in `YoutubePlayerValue` - already exists
- `PlaybackQualityChange` event handler in `raw_youtube_player.dart` - already exists (line 172-179)

## Design Details

### 1. PlaybackQuality Enum

```dart
/// Defines the playback quality levels for YouTube videos.
class PlaybackQuality {
  PlaybackQuality._();

  static const String auto = 'auto';
  static const String small = 'small';     // ~240p
  static const String medium = 'medium';   // ~360p
  static const String large = 'large';     // ~480p
  static const String hd720 = 'hd720';     // 720p
  static const String hd1080 = 'hd1080';   // 1080p
  static const String hd1440 = 'hd1440';   // 1440p
  static const String hd2160 = 'hd2160';   // 2160p (4K)

  /// Returns a user-friendly display name for a quality level.
  static String getDisplayName(String quality) {
    switch (quality) {
      case 'small': return '240p';
      case 'medium': return '360p';
      case 'large': return '480p';
      case 'hd720': return '720p';
      case 'hd1080': return '1080p';
      case 'hd1440': return '1440p';
      case 'hd2160': return '2160p';
      case 'highres': return '4K+';
      case 'auto': default: return 'Auto';
    }
  }

  static const List<String> values = [
    small, medium, large, hd720, hd1080, hd1440, hd2160,
  ];
}
```

### 2. Controller Method

Add to `YoutubePlayerController`:

```dart
/// Sets the suggested playback quality for the current video.
void setPlaybackQuality(String quality) => _callMethod('setPlaybackQuality("$quality")');
```

### 3. JavaScript Function

Add to embedded HTML in `raw_youtube_player.dart` (after `setPlaybackRate` function):

```javascript
function setPlaybackQuality(quality) {
  player.setPlaybackQuality(quality);
  return '';
}
```

### 4. PlaybackQualityButton Widget

```dart
import 'package:flutter/material.dart';
import '../enums/playback_quality.dart';
import '../utils/youtube_player_controller.dart';

class PlaybackQualityButton extends StatefulWidget {
  const PlaybackQualityButton({
    super.key,
    this.controller,
    this.icon,
  });

  final YoutubePlayerController? controller;
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
        child: widget.icon ?? const Icon(
          Icons.settings,
          color: Colors.white,
          size: 20.0,
        ),
      ),
    );
  }

  PopupMenuEntry<String> _popUpItem(String text, String quality) {
    return CheckedPopupMenuItem(
      checked: _controller.value.playbackQuality == quality,
      value: quality,
      child: Text(text),
    );
  }
}
```

### 5. Widget Export

Add to `widgets.dart`:

```dart
export 'playback_quality_button.dart';
```

### 6. Main Library Export

Add to `youtube_player_flutter.dart`:

```dart
export 'src/enums/playback_quality.dart';
```

### 7. Bottom Bar Integration

Add to bottom bar in `youtube_player.dart` (after `PlaybackSpeedButton` around line 404):

```dart
const PlaybackQualityButton(),
```

## Design Decisions

1. **Quality ordering**: Highest to lowest in popup menu (2160p → 240p) - matches YouTube's native UX
2. **Default icon**: `Icons.settings` - standard icon for quality/settings controls. While `PlaybackSpeedButton` uses a custom asset (`speedometer.webp`), `Icons.settings` is a reasonable deviation since quality settings typically use a gear icon across platforms, and adding a new asset would require pubspec.yaml changes.
3. **No `getAvailableQualityLevels`**: YouTube player handles availability automatically; requested quality falls back to best available
4. **String constants**: YouTube API uses string quality identifiers (e.g., `'hd720'`), not integers
5. **Always visible**: No opt-in flag; button appears by default in bottom bar
6. **Null-safe quality check**: The `CheckedPopupMenuItem` comparison `_controller.value.playbackQuality == quality` handles null safely - if `playbackQuality` is null, no item will be checked until a quality event fires from YouTube.
7. **Pre-ready calls**: If `setPlaybackQuality` is called before `isReady`, the existing `_callMethod` pattern logs "The controller is not ready for method calls" and does nothing. This is consistent with other methods like `play()` and `pause()`.

## Testing Considerations

- Verify quality change reflects in `playbackQuality` value
- Test on videos with limited quality options
- Verify `CheckedPopupMenuItem` shows current selection correctly
- Test on both iOS and Android platforms

## Dependencies

- No new dependencies required
- Uses existing YouTube IFrame Player API (`setPlaybackQuality` method)
