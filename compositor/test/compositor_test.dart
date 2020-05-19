import 'package:compositor/compositor.dart';
import 'package:compositor/src/video_operations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockVideoOperations extends Mock implements VideoOperations {}

void main() {
  group('visibleTrackPart', () {
    test('no scroll', () {
      var compositor = Compositor(
        clipDuration: Duration(seconds: 1),
        gridSquareSize: 4,
        width: 100,
        height: 100,
        trackCount: 16,
      );

      expect(
        compositor.visibleTrackPart(0),
        ClipPart(
          start: Duration(milliseconds: 0),
          duration: Duration(seconds: 1),
        ),
      );

      expect(
        compositor.visibleTrackPart(15),
        ClipPart(
          start: Duration(milliseconds: 0),
          duration: Duration(seconds: 1),
        ),
      );
    });

    test('scroll 1 column', () {
      var compositor = Compositor(
        clipDuration: Duration(seconds: 1),
        gridSquareSize: 4,
        width: 100,
        height: 100,
        trackCount: 17,
      );

      expect(
        compositor.visibleTrackPart(0),
        ClipPart(
          start: Duration(milliseconds: 0),
          duration: Duration(seconds: 1),
        ),
      );

      expect(
        compositor.visibleTrackPart(16),
        ClipPart(
          start: Duration(milliseconds: 0),
          duration: Duration(seconds: 1),
        ),
      );
    });

    test('scroll 2 screens', () {
      var compositor = Compositor(
        clipDuration: Duration(seconds: 2),
        gridSquareSize: 4,
        width: 100,
        height: 100,
        trackCount: 32,
      );

      expect(
        compositor.visibleTrackPart(0),
        ClipPart(
          start: Duration(milliseconds: 0),
          duration: Duration(milliseconds: 500),
        ),
      );

      expect(
        compositor.visibleTrackPart(16),
        ClipPart(
          start: Duration(milliseconds: 0),
          duration: Duration(seconds: 2),
        ),
      );

      expect(
        compositor.visibleTrackPart(23),
        ClipPart(
          start: Duration(milliseconds: 500),
          duration: Duration(milliseconds: 1500),
        ),
      );
    });
  });

  test('clipAndScaleVisiblePart', () async {
    MockVideoOperations videoOperations = MockVideoOperations();

    final Compositor compositor = Compositor(
      clipDuration: Duration(seconds: 2),
      gridSquareSize: 4,
      width: 100,
      height: 100,
      trackCount: 32,
      videoOperations: videoOperations
    );
    
    when(videoOperations.findClapInVideo('test.mp4')).thenAnswer((_) async => 8.23);

    await compositor.clipAndScaleVisiblePart('test.mp4', 23, 1.0, 'out.mp4');

    verify(videoOperations.clipAndScale(
        inputPath: 'test.mp4',
        startTime: Duration(microseconds: (0.5e6 + 7.23e6).floor()),
        duration: Duration(milliseconds: 1500),
        width: 25,
        height: 25,
        outputPath: 'out.mp4',
    ));
  });
}
