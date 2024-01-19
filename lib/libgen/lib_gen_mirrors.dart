import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:html/dom.dart';

import '../models/details.dart';

class LibGenMirror extends BookMirror {
  final dio = Dio();

  LibGenMirror({
    required String label,
    required Uri uri,
  }) : super(
          label: label,
          uri: uri,
        );

  void _directDownload(String url) async {
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      headers: {},
      savedDir: '/storage/emulated/0/Download',
      showNotification: true,
      openFileFromNotification: true,
      saveInPublicStorage: true,
    );

    log('Downloading $uri with task id $taskId');
  }

  Future<void> _downloadLibraryLol(BuildContext _) async {
    final page = await dio.getUri(uri);
    final html = Document.html(page.data);

    final anchor = html.querySelector('#download a');
    final href = anchor?.attributes['href'] ?? '';

    return _directDownload(href);
  }

  Future<void> _downloadLibgen(BuildContext _) async {
    final page = await dio.getUri(uri);
    final html = Document.html(page.data);

    final anchor = html.querySelectorAll(r'table a').firstWhere((element) {
      return element.querySelector('h2') != null;
    });
    final href = anchor.attributes['href'] ?? '';

    return _directDownload(href);
  }

  @override
  Future<void> Function(BuildContext context)? getDownloadCallback() {
    if (uri.path.startsWith('/main')) {
      return _downloadLibraryLol;
    } else if (uri.host.contains('libgen') && uri.query.contains('md5=')) {
      return _downloadLibgen;
    }

    return null;
  }
}
