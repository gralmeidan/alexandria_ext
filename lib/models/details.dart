import 'package:flutter/material.dart';

import 'models.dart';

class BookDetails extends BookSearchResult {
  List<BookMirror> mirrors;
  String? description;

  BookDetails({
    required super.extension,
    super.cover,
    super.title,
    super.author,
    super.pages,
    super.language,
    super.filetype,
    super.year,
    super.publisher,
    super.filesize,
    super.edition,
    super.ids,
    this.mirrors = const [],
    this.description,
  });

  BookDetails.fromSuper(
    BookSearchResult result, {
    this.mirrors = const [],
    this.description,
  }) : super(
          cover: result.cover,
          title: result.title,
          author: result.author,
          pages: result.pages,
          language: result.language,
          filetype: result.filetype,
          extension: result.extension,
          year: result.year,
          publisher: result.publisher,
          filesize: result.filesize,
          edition: result.edition,
          ids: result.ids,
          href: result.href,
        );
}

abstract class BookMirror {
  final String label;
  final Uri uri;

  const BookMirror({
    required this.label,
    required this.uri,
  });

  dynamic getDownloadInfo();

  Future<void> download(BuildContext context, {required String path});

  bool get hasAutodownload => getDownloadInfo() != null;
}
