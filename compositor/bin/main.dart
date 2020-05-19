import 'dart:io';

import 'package:compositor/compositor.dart' as compositor;
import 'package:compositor/compositor.dart';
import 'package:compositor/src/video_operations.dart';

main(List<String> arguments) async {
  final Compositor compositor = Compositor(
      clipDuration: Duration(minutes: 1),
      gridSquareSize: 4,
      width: 1920,
      height: 1080,
      trackCount: 32,
  );
  try {
    await compositor.clipAndScaleVisiblePart('/Volumes/external/koolulam/data/2.mov', 0, 1, '/tmp/2-out.mov');
    print('done');
  } catch(e) {
    print(e);
    exit(1);
  }
}
