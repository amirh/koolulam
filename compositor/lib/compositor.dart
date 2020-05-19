import 'dart:math';

import 'package:compositor/src/video_operations.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' show join;

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

  Future<void> composite(Duration start, Duration duration, String atomsFolder, String outputPath) {
    List<AtomComposition> composition = planComposition(start, duration);

    GridCell mapAtomToGridCell(AtomComposition atom) {
      return GridCell(
          filePath: join(atomsFolder, '${atom.trackIdx}.mov'),
          initialX: atom.initialX,
          y: atom.y,
          pixelsPerSecond: atom.pixelsPerSecond,
      );
    }

    List<GridCell> cells = composition.map(mapAtomToGridCell).toList();
    videoOperations.buildGrid(
        cells: cells, width: width, height: height, outputPath: outputPath,
    duration: duration,);
  }


  List<AtomComposition> planComposition(Duration start, Duration duration) {
    int scrollStartPx = (pixelsPerMilliSecond * start.inMilliseconds).floor();
    int scrollEndPx = scrollStartPx + (pixelsPerMilliSecond * duration.inMilliseconds).floor();

    int firstColumn = (scrollStartPx / columnWidth).floor();
    int lastColumn = ((scrollEndPx + width) / columnWidth).ceil();
    int firstTrack = firstColumn * gridSquareSize;
    int lastTrack = lastColumn * gridSquareSize + gridSquareSize;
    lastTrack = min(lastTrack, trackCount - 1);

    List<AtomComposition> composition = [];
    for (int trackIdx = firstTrack; trackIdx <= lastTrack; trackIdx++) {
      int column = (trackIdx / gridSquareSize).floor();
      int offsetAtT0 = column * columnWidth;
      int offsetAtStart = scrollStartPx + offsetAtT0;
      int row = column == 0 ? trackIdx : trackIdx % gridSquareSize;
      int y = (row * (height/gridSquareSize)).floor();
      composition.add(AtomComposition(
        trackIdx: trackIdx,
        initialX: offsetAtStart,
        y: y,
        pixelsPerSecond: pixelsPerMilliSecond * 1000,
      ));
    }
    return composition;
  }
}

class AtomComposition {
  final int trackIdx;
  final int initialX;
  final int y;
  final double pixelsPerSecond;

  AtomComposition({this.trackIdx, this.initialX, this.y, this.pixelsPerSecond});

  @override
  String toString() {
    return 'AtomComposition{trackIdx: $trackIdx, initialX: $initialX, y: $y, pixelsPerSecond: $pixelsPerSecond}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AtomComposition &&
              runtimeType == other.runtimeType &&
              trackIdx == other.trackIdx &&
              initialX == other.initialX &&
              y == other.y &&
              pixelsPerSecond == other.pixelsPerSecond;

  @override
  int get hashCode =>
      trackIdx.hashCode ^
      initialX.hashCode ^
      y.hashCode ^
      pixelsPerSecond.hashCode;
}