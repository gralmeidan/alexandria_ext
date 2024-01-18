import 'package:flutter/material.dart';

import '../models/details.dart';

class LibGenMirror extends BookMirror {
  LibGenMirror({
    required String label,
    required Uri uri,
  }) : super(
          label: label,
          uri: uri,
        );

  @override
  Future<void> download(BuildContext context) {
    // TODO: implement download
    throw UnimplementedError();
  }

  @override
  bool get hasAutodownload => uri.toString().contains('http');
}
