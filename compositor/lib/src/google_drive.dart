import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:compositor/src/secrets.dart';
import "package:http/http.dart" as http;
import "package:googleapis_auth/auth_io.dart";

class GoogleDriveFileInfo {
  GoogleDriveFileInfo({this.id, this.name, this.kind, this.mimeType});

  final String id;
  final String name;
  final String kind;
  final String mimeType;

  @override
  String toString() {
    return 'GoogleDriveFileInfo{id: $id, name: $name, kind: $kind, mimeType: $mimeType}';
  }
}

class GoogleDrive {

  static Future<GoogleDrive> connect() async {
    final List<String> scopes = ['https://www.googleapis.com/auth/drive.readonly'];
    AuthClient client = await clientViaServiceAccount(accountCredentials, scopes);
    return GoogleDrive(client);
  }
  GoogleDrive(AuthClient client) : _client = client;

  AuthClient _client;

  void close() {
    _client.close();
  }

  Future<List<GoogleDriveFileInfo>> listFilesInFolder(String folderId) async {
    final Uri uri = Uri.https(
      'www.googleapis.com',
      '/drive/v3/files',
      <String, String> {
        'q': '\'$folderId\' in parents'
      },
    );

    final http.Response response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('listing files failed, status code: ${response.statusCode} response: ${response.body}');
    }

    Map<String, dynamic> fileListResult = jsonDecode(response.body);
    List<Map<String, dynamic>> files = fileListResult['files'].cast<Map<String, dynamic>>();
    return files.map((Map<String, dynamic> file) {
      return GoogleDriveFileInfo(
        id: file['id'],
        kind: file['kind'],
        name: file['name'],
        mimeType: file['mimeType'],
      );
    }).toList();
  }

  Future<void> downloadFile(String fileId, String outputPath) async {

    final Uri uri = Uri.https(
      'www.googleapis.com',
      '/drive/v3/files/$fileId',
      <String, String> {
        'alt': 'media'
      },
    );

    List<String> args = <String> [
      '-H',
      'Authorization: Bearer ${_client.credentials.accessToken.data}',
      '-o',
      outputPath,
      uri.toString()
    ];

    Process process = await Process.start('curl', args);
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);

    int exitCode = await process.exitCode;

    if (exitCode != 0) {
      throw Exception('failed downloading $fileId');
    }
  }
}
