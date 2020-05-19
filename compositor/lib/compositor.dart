import 'dart:math';

import 'package:compositor/src/video_operations.dart';
import 'package:meta/meta.dart';

class ClipPart {
  const ClipPart({
    @required this.start,
    @required this.duration,
  });

  final Duration start;
  final Duration duration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ClipPart &&
              runtimeType == other.runtimeType &&
              start == other.start &&
              duration == other.duration;

  @override
  int get hashCode =>
      start.hashCode ^
      duration.hashCode;

  @override
  String toString() {
    return 'ClipPart{start: $start, duration: $duration}';
  }
}
class Compositor {
  const Compositor({
    @required this.clipDuration,
    @required this.gridSquareSize,
    @required this.width,
    @required this.height,
    @required this.trackCount,
    this.videoOperations = const VideoOperations(),
  });

  final Duration clipDuration;
  final int gridSquareSize;
  final int width;
  final int height;
  final int trackCount;
  final VideoOperations videoOperations;

  int get columnCount => (trackCount / gridSquareSize).ceil();

  int get columnWidth => (width / gridSquareSize).floor();

  int get virtualWidth => columnWidth * columnCount;

  int get pixelsToScroll => virtualWidth - width;

  double get pixelsPerMilliSecond => pixelsToScroll / clipDuration.inMilliseconds;

  ClipPart visibleTrackPart(int trackIndex) {
    if (trackIndex >= trackCount) {
      throw ArgumentError('Illegal track index $trackIndex. It must be smaller than $trackCount');
    }

    var column = (trackIndex / gridSquareSize).floor();
    var columnPixel = column * columnWidth;

    var visibleMilliSecond = max((columnPixel - width) / pixelsPerMilliSecond, 0).floor();
    var goneMilliSecond = min((columnPixel + columnWidth) / pixelsPerMilliSecond, clipDuration.inMilliseconds).floor();

    return ClipPart(
      start: Duration(milliseconds: visibleMilliSecond),
      duration: Duration(milliseconds: goneMilliSecond - visibleMilliSecond),
    );
  }

  Future<void> clipAndScaleVisiblePart(String inputPath, int trackIndex, double secondsBeforeClap, String outputPath) async {
    ClipPart part = visibleTrackPart(trackIndex);
    double clapSeconds = await videoOperations.findClapInVideo(inputPath);
    int startMicros = (1e6 * (clapSeconds - secondsBeforeClap)).floor();

    await videoOperations.clipAndScale(
      inputPath: inputPath,
      startTime: part.start + Duration(microseconds: startMicros),
      duration: part.duration,
      width: (width / gridSquareSize).floor(),
      height: (height / gridSquareSize).floor(),
      outputPath: outputPath,
    );
  }
}