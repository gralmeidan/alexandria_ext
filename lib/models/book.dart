import '../helpers/extensions.dart';
import 'author.dart';

class BookSearchResult {
  final String title;
  final Author author;
  final String extension;
  final String pages;
  final String language;
  final String filetype;
  final String disambiguity;
  final String year;
  final String publisher;
  final List<String>? ids;

  BookSearchResult({
    required this.title,
    required this.author,
    required this.pages,
    required this.language,
    required this.filetype,
    required this.disambiguity,
    required this.extension,
    required this.year,
    required this.publisher,
    this.ids,
  });

  bool compareIds(List<String> ids) {
    if (this.ids == null) {
      return false;
    }

    for (var id in ids) {
      if (this.ids!.contains(id)) {
        return true;
      }
    }

    return false;
  }
}

class BookSearchGroup {
  final String title;
  final Author author;
  final List<BookSearchResult> results;
  final List<String> _ids = [];

  BookSearchGroup({
    required this.title,
    required this.author,
    required this.results,
  });

  void add(BookSearchResult result) {
    _ids.addAll(result.ids ?? []);
    results.add(result);
  }

  bool maybeAppend(BookSearchResult result) {
    if (result.compareIds(_ids)) {
      add(result);
      return true;
    }

    if (title.disambiguate() == result.title.disambiguate() && author.isEqual(result.author)) {
      add(result);
      return true;
    }

    return false;
  }

  static List<BookSearchGroup> groupResults(
    List<BookSearchResult> results,
  ) {
    final List<BookSearchGroup> groups = [];

    for (var result in results) {
      bool found = false;

      for (var group in groups) {
        if (group.maybeAppend(result)) {
          found = true;
          break;
        }
      }

      if (found) {
        continue;
      }

      groups.add(
        BookSearchGroup(
          title: result.title,
          author: result.author,
          results: [result],
        ),
      );
    }

    return groups;
  }
}
