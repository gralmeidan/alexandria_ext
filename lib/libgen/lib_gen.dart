import 'package:dio/dio.dart';
import 'package:html/dom.dart';

import '../lib_browser_extensions.dart';
import '../models/author.dart';
import '../models/book.dart';

class LibGenExtension implements SearchExtension {
  final dio = Dio()..options.baseUrl = 'https://www.libgen.is/';

  @override
  Future<List<BookSearchGroup>> search(String query) async {
    final response = await dio.get(
      'search.php',
      queryParameters: {
        'req': query,
      },
    );

    final Document html = Document.html(response.data);

    final rows = html.querySelectorAll('table.c tr').skip(1).toList();

    final List<BookSearchResult> books = [];

    for (var row in rows) {
      final columns = row.querySelectorAll('td');

      books.add(
        BookSearchResult(
          author: Author(columns[1].text),
          title: columns[2].children[0].nodes[0].text?.trim() ?? '',
          disambiguity: columns[2].querySelector('i')?.text ?? '',
          publisher: columns[3].text,
          year: columns[4].text,
          pages: columns[5].text,
          language: columns[6].text,
          filetype: columns[8].text,
          extension: 'LibGen',
        ),
      );
    }

    return BookSearchGroup.groupResults(books);
  }
}
