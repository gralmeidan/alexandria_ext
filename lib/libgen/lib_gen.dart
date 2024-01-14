import 'package:dio/dio.dart';
import 'package:html/dom.dart';

import '../lib_browser_extensions.dart';

class LibGenExtension implements SearchExtension {
  @override
  final name = 'libgen.is';

  final dio = Dio()..options.baseUrl = 'https://www.libgen.is';

  @override
  Future<List<BookSearchGroup>> search(String query) async {
    final response = await dio.get(
      '/search.php',
      queryParameters: {
        'req': query,
        'view': 'detailed',
      },
    );

    final Document html = Document.html(response.data);

    final tables = html.querySelectorAll('body > table[rules="cols"]').toList();

    final List<BookSearchResult> books = [];

    for (var row in tables) {
      final tds = row.querySelectorAll('td');

      final book = BookSearchResult.empty();

      book.cover = tds[1].querySelector('img')?.attributes['src'];
      book.extension = name;

      if (book.cover != null) {
        book.cover = '${dio.options.baseUrl}${book.cover}';
      }

      for (var i = 2; i < tds.length; i++) {
        final previous = tds[i - 1].text;

        final listText = tds[i].text.split(',').map((e) => e.trim()).toList();

        final switchHash = {
          'Title': () => book.title = tds[i].text,
          'Author': () => book.author = Author(tds[i].text),
          'Pages': () {
            book.pages = RegExp(r'\d+').firstMatch(tds[i].text)?.group(0) ?? '';
          },
          'Language': () => book.language = tds[i].text,
          'Extension': () => book.filetype = tds[i].text,
          'Year': () => book.year = tds[i].text,
          'Publisher': () => book.publisher = tds[i].text,
          'ISBN': () => book.appendIds(listText),
          'ID': () => book.appendIds(listText),
          'Edition': () {
            book.edition = tds[i].text;
          },
          'Size': () {
            final listText = tds[i].text.split(' ');

            if (listText.length > 1) {
              book.filesize = '${listText[0]} ${listText[1]}';
            }
          },
        };

        for (var key in switchHash.keys) {
          if (previous.contains(key)) {
            switchHash[key]!();
            break;
          }
        }
      }

      books.add(book);
    }

    return BookSearchGroup.groupResults(books);
  }
}
