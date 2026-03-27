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
