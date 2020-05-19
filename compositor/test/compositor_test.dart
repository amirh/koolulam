import 'package:compositor/compositor.dart';
import 'package:test/test.dart';

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
}
