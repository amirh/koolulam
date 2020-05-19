import 'dart:io';

import 'package:compositor/src/video_operations.dart';

import 'package:test/test.dart';
import "package:path/path.dart" show join;

void main() {
  VideoOperations videoOperations = VideoOperations();
  String testDataDirName = join(Directory.current.path, 'test', 'data');
  String outputDir;
  setUpAll(() {
    outputDir = Directory.systemTemp.createTempSync().path;
  });

  tearDownAll(() {
    Directory(outputDir).deleteSync(recursive: true);
  });

  test('Extract wav', () async {
    String out = join(outputDir, 'sample-2-seconds.wav');

    await videoOperations.extractAudio(
      join(testDataDirName, 'sample.mp4'),
      Duration(seconds: 2),
      out,
    );

    String expected = join(testDataDirName, 'sample-2-seconds.wav');

    expect(await filesEqual(out, expected), isTrue);
  });

  test('Find clap in video', () async {
    double clapTime = await videoOperations.findClapInVideo(join(testDataDirName, 'sample.mp4'));
    expect(clapTime, 3.3262358276643993);
  });
}

Future<bool> filesEqual(String file1, String file2) async {
  ProcessResult processResult = await Process.run('cmp', ['-s', file1, file2]);
  return processResult.exitCode == 0;
}
