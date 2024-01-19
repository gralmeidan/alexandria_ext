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

  Future<void> _directDownload({
    required String url,
    required String savedDir,
  }) async {
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      headers: {},
      savedDir: savedDir,
      showNotification: true,
      openFileFromNotification: true,
      saveInPublicStorage: true,
    );

    log('Downloading $uri with task id $taskId');
  }

  Future<String?> _getLibraryLolHref() async {
    final page = await dio.getUri(uri);
    final html = Document.html(page.data);

    final anchor = html.querySelector('#download a');

    return anchor?.attributes['href'];
  }

  Future<String?> _getLibgenHref() async {
    final page = await dio.getUri(uri);
    final html = Document.html(page.data);

    final anchor = html.querySelectorAll(r'table a').firstWhere((element) {
      return element.querySelector('h2') != null;
    });

    return anchor.attributes['href'];
  }

  @override
  Future<void> download(BuildContext context, {required String path}) async {
    final href = await getDownloadInfo()?.call();

    if (href != null) {
      return _directDownload(
        url: href,
        savedDir: path,
      );
    }
  }

  @override
  Future<String?> Function()? getDownloadInfo() {
    if (uri.path.startsWith('/main')) {
      return _getLibraryLolHref;
    } else if (uri.host.contains('libgen') && uri.query.contains('md5=')) {
      return _getLibgenHref;
    }

    return null;
  }
}
