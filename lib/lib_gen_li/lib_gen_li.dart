import 'package:dio/dio.dart';
import 'package:html/dom.dart';

import '../lib_browser_extensions.dart';

class LibGenLiExtension implements SearchExtension {
  static final baseUri = Uri.parse('https://libgen.li');
  static final dio = Dio()..options.baseUrl = baseUri.toString();

  @override
  final name = 'libgen.li (fiction)';

  static const _columns = ['t', 'a', 's', 'y', 'p', 'i'];
  static const _objects = ['f', 'e', 's', 'a', 'p', 'w'];
  static const _topics = ['f'];

  List<String> _mapListQuery(String name, List<String> list) {
    final List<String> result = [];

    for (final char in list) {
      result.add('$name[]=$char');
    }

    return result;
  }

  String _mapQuery() {
    final List<String> result = [];

    result.addAll(_mapListQuery('columns', _columns));
    result.addAll(_mapListQuery('objects', _objects));
    result.addAll(_mapListQuery('topics', _topics));

    return result.join('&');
  }

  String _selectorOrInnerHtml(Element? element, String selector) {
    if (element == null) {
      return '';
    }

    return element.querySelector(selector)?.innerHtml ?? element.innerHtml;
  }

  String? _getDigitsOn(String? text) {
    if (text == null) return null;

    return RegExp(r'\d+').firstMatch(text)?.group(0);
  }

  @override
  Future<List<BookSearchGroup>> search(String query) async {
    final response = await dio.get(
      '/index.php?${_mapQuery()}',
      queryParameters: {
        'req': query,
        'covers': 'on',
        'res': 25,
      },
    );

    final List<BookSearchResult> results = [];

    final Document html = Document.html(response.data);
    final trs = html.querySelectorAll('#tablelibgen tbody tr').toList();

    for (var tr in trs) {
      final tds = tr.querySelectorAll('td').toList();

      final result = BookSearchResult(
        extension: this,
      );

      final cover = tds[0].querySelector('img')?.attributes['src'];

      if (cover != null) {
        result.cover = baseUri.resolve(cover.replaceFirst('_small', '')).toString();
      }

      result.author = Author(_selectorOrInnerHtml(tds[2], 'a'));
      result.publisher = _selectorOrInnerHtml(tds[3], 'a');
      result.year = _getDigitsOn(_selectorOrInnerHtml(tds[4], 'nobr')) ?? '';
      result.language = _selectorOrInnerHtml(tds[5], 'nobr');
      result.pages = _selectorOrInnerHtml(tds[6], 'nobr');
      result.filesize = _selectorOrInnerHtml(tds[7], 'a');
      result.filetype = _selectorOrInnerHtml(tds[8], 'nobr');

      final titleEl = tds[1].querySelector('td > a') ?? tds[1].querySelector('a');

      result.title = titleEl?.text.trimRight() ?? '';
      result.href = titleEl?.attributes['href'];
      result.appendId(_getDigitsOn(titleEl?.querySelector('.badge-secondary')?.text));

      final titleData = titleEl?.attributes['data-original-title'];

      if (titleData != null) {
        final id = RegExp(r'ID: (\w+)').firstMatch(titleData)?.group(1);

        result.appendId(id);
      }

      results.add(result);
    }

    return BookSearchGroup.groupResults(results);
  }

  @override
  Future<BookDetails> details(BookSearchResult result) {
    throw UnimplementedError();
  }
}
