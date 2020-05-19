import 'dart:io';

import 'package:compositor/compositor.dart' as compositor;
import 'package:compositor/src/video_operations.dart';

main(List<String> arguments) async {
  VideoOperations videoOperations = VideoOperations();
  try {
    await videoOperations.extractAudio(
        '/Volumes/external/koolulam/data/2.mov', Duration(seconds: 2),
        '/tmp/2.wav');
    print('done');
  } catch(e) {
    print(e);
    exit(1);
  }
}
