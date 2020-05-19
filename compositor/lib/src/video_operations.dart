import 'dart:io';

import 'process.dart' show ps;

import 'package:path/path.dart' show join;

class VideoOperations {
  static final String python3 = 'python3';
  static final String ffmpeg = 'ffmpeg';
  static final String findClapScript = '../findclap/findclap.py';

  Future<void> extractAudio(String inputPath, Duration duration, String outputPath) async {
    var args = [
      '-ss', '00:00:00.0',
      '-t', formatFfmpegDuration(duration),
      '-i', inputPath,
      '-vn',
      outputPath
    ];
    final ProcessResult result = await ps.run(ffmpeg, args);
    if (result.exitCode != 0) {
      throw Exception(
          '$ffmpeg $args failed (exit code: ${result.exitCode}.\n\n'
              'stderr: ${result.stderr}\n\n'
              'stdout: ${result.stdout}\n\n'
      );
    }
  }

  Future<double> findClapInWave(String inputWave) async {
    var args = [
      findClapScript,
      inputWave,
    ];
    final ProcessResult result = await ps.run(python3, args);
    if (result.exitCode != 0) {
      throw Exception(
          '$ffmpeg $args failed (exit code: ${result.exitCode}.\n\n'
              'stderr: ${result.stderr}\n\n'
              'stdout: ${result.stdout}\n\n'
      );
    }
    return double.parse(result.stdout);
  }

  Future<double> findClapInVideo(String inputPath) async {
    Directory outDir = await Directory.systemTemp.createTemp();
    String waveFile = join(outDir.path, '30seconds.wav');
    await extractAudio(inputPath, Duration(seconds: 40), waveFile);
    double clapPosition = await findClapInWave(waveFile);
    outDir.delete(recursive: true);
    return clapPosition;
  }

  static String formatFfmpegDuration(Duration duration) {
    var seconds = duration.inSeconds;
    var micros = duration.inMicroseconds;
    var secondsModulo = micros % 1e6;
    var secondPart = secondsModulo == 0 ? 0 : 1e6 / secondsModulo.floor();
    return '$seconds.$secondPart';
  }
}