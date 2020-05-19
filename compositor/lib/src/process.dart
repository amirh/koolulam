import 'dart:convert';
import 'dart:io' as io;

Process ps = DartIoProcess();

abstract class Process {
  Future<io.ProcessResult> run(
      String executable,
      List<String> arguments,
      {
        String workingDirectory,
        Map<String, String> environment,
        bool includeParentEnvironment = true,
        bool runInShell = false,
        Encoding stdoutEncoding = io.systemEncoding,
        Encoding stderrEncoding = io.systemEncoding,
      }
    );
}

class DartIoProcess extends Process {
  @override
  Future<io.ProcessResult> run(
      String executable,
      List<String> arguments,
      {
        String workingDirectory,
        Map<String, String> environment,
        bool includeParentEnvironment = true,
        bool runInShell = false,
        Encoding stdoutEncoding = io.systemEncoding,
        Encoding stderrEncoding = io.systemEncoding,
      }
    ) {
    return io.Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      stdoutEncoding: stdoutEncoding,
      stderrEncoding: stderrEncoding,
    );
  }

}