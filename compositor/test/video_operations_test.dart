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

  test('formatFfmpegDuration', () {
    expect(VideoOperations.formatFfmpegDuration(Duration(seconds: 1)), "1.0");
    expect(VideoOperations.formatFfmpegDuration(Duration(milliseconds: 500)), "0.5");
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
    Future<double> findClap(String file) {
      return videoOperations.findClapInVideo(join(testDataDirName, file));
    }
    expect(await findClap('sample.mp4'), 3.3262358276643993);
    expect(await findClap('fixyou.aac'), 32.938);
  });

  test('buildGridScript', () async {
    List<GridCell> cells = <GridCell> [
      GridCell(filePath: '1.mov', initialX: 0, y: 0, pixelsPerSecond: 100, startTime: Duration(seconds: 0)),
      GridCell(filePath: '2.mov', initialX: 0, y: 50, pixelsPerSecond: 100, startTime: Duration(seconds: 0)),
      GridCell(filePath: '3.mov', initialX: 50, y: 0, pixelsPerSecond: 100, startTime: Duration(seconds: 0)),
      GridCell(filePath: '4.mov', initialX: 50, y: 50, pixelsPerSecond: 100, startTime: Duration(seconds: 0)),
      GridCell(filePath: '5.mov', initialX: 100, y: 0, pixelsPerSecond: 100, startTime: Duration(seconds: 0)),
      GridCell(filePath: '6.mov', initialX: 100, y: 50, pixelsPerSecond: 100, startTime: Duration(seconds: 0)),
      GridCell(filePath: '7.mov', initialX: 150, y: 0, pixelsPerSecond: 100, startTime: Duration(milliseconds: 500)),
    ];

    String filter = videoOperations.buildGridFilter(cells, 100, 100);
    String expected = '"\n'
        'nullsrc=size=100x100 [base];\n'
        '[base][0:v] overlay=shortest=1:x=0+t*-100.0:y=0[tmp0];\n'
        '[tmp0][1:v] overlay=shortest=1:x=0+t*-100.0:y=50[tmp1];\n'
        '[tmp1][2:v] overlay=shortest=1:x=50+t*-100.0:y=0[tmp2];\n'
        '[tmp2][3:v] overlay=shortest=1:x=50+t*-100.0:y=50[tmp3];\n'
        '[tmp3][4:v] overlay=shortest=1:x=100+t*-100.0:y=0[tmp4];\n'
        '[tmp4][5:v] overlay=shortest=1:x=100+t*-100.0:y=50\n'
        '"\n';

    expect(filter, expected);
  });
}

Future<bool> filesEqual(String file1, String file2) async {
  ProcessResult processResult = await Process.run('cmp', ['-s', file1, file2]);
  return processResult.exitCode == 0;
}
