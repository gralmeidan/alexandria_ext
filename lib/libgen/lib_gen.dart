import 'package:dio/dio.dart';
import 'package:html/dom.dart';

import '../lib_browser_extensions.dart';
import '../models/details.dart';
import 'lib_gen_mirrors.dart';

class LibGenExtension implements SearchExtension {
  static final baseUri = Uri.parse('https://www.libgen.is');
  static final dio = Dio()..options.baseUrl = baseUri.toString();

  @override
  final name = 'libgen.is';

  BookSearchResult _scrapeDataFromDetailedTable(
    Element table,
  ) {
    final tds = table.querySelectorAll('td');

    final book = BookSearchResult(extension: this);

    book.cover = tds[1].querySelector('img')?.attributes['src'];

    if (book.cover != null) {
      book.cover = '${dio.options.baseUrl}${book.cover}';
    }

    for (var i = 2; i < tds.length; i++) {
      final previous = tds[i - 1].text;

      final listText = tds[i].text.split(',').map((e) => e.trim()).toList();

      final switchHash = {
        'Title': () {
          book.title = tds[i].text;
          book.href =
              baseUri.resolve(tds[i].querySelector('a')?.attributes['href'] ?? '').toString();
        },
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

    return book;
  }

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

    for (var table in tables) {
      books.add(_scrapeDataFromDetailedTable(table));
    }

    return BookSearchGroup.groupResults(books);
  }

  @override
  Future<BookDetails> details(BookSearchResult result) async {
    final response = await dio.get(
      result.href!,
    );

    final Document html = Document.html(response.data);
    final table = html.querySelector('table[rules="cols"]');

    if (table == null) {
      throw Exception('No table found');
    }

    final mirrors = <BookMirror>[];
    final anchors = html.querySelectorAll('table table[rules="cols"]').last.querySelectorAll('a');

    for (var anchor in anchors) {
      final href = anchor.attributes['href'] ?? '';

      mirrors.add(
        LibGenMirror(
          label: anchor.text,
          uri: baseUri.resolve(href),
        ),
      );
    }

    return BookDetails.fromSuper(
      _scrapeDataFromDetailedTable(table),
      description: table.querySelectorAll('tbody > tr > :only-child')[1].text,
      mirrors: mirrors,
    );
  }
}
