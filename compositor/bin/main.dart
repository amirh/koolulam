import 'dart:io';

import 'package:compositor/compositor.dart' as compositor;
import 'package:compositor/compositor.dart';
import 'package:compositor/src/video_operations.dart';

main(List<String> arguments) async {
  int trackCount = 5000;
  final Compositor compositor = Compositor(
      clipDuration: Duration(minutes: 3, seconds: 35),
      gridSquareSize: 10,
      width: 1920,
      height: 1080,
      trackCount: 2500,
  );

  try {
//    for (int i = 0; i < 250; i++) {
//      print('preparing atom $i');
//      await compositor.clipAndScaleVisiblePart('/Volumes/external/koolulam/data/2.mov', i, 1, '/Volumes/external/tmp/try1/$i.mov');
//    }
    compositor.composite(Duration(seconds: 0), Duration(seconds: 6), '/Volumes/external/tmp/try1/', '/tmp/grid.mov');
  } catch(e) {
    print(e);
    exit(1);
  }
}
