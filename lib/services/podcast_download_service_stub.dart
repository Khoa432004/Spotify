// Stub file for web platform
// This file is imported when compiling for web

import 'dart:async';

/// Stub for getApplicationDocumentsDirectory (from path_provider)
/// Returns Directory object (same as path_provider)
Future<Directory> getApplicationDocumentsDirectory() async {
  throw UnsupportedError('Not available on web platform');
}

/// Stub for Directory
class Directory {
  final String path;
  Directory(this.path);
  
  Future<bool> exists() async => false;
  Future<Directory> create({bool recursive = false}) async => this;
  Future<void> delete({bool recursive = false}) async {}
  List<dynamic> listSync() => [];
}

/// Stub for File  
class File {
  final String path;
  File(this.path);
  
  Future<bool> exists() async => false;
  Future<File> writeAsBytes(List<int> bytes) async => this;
  Future<int> length() async => 0;
  Future<void> delete() async {}
}

