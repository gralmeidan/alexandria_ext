import 'models/details.dart';
import 'models/search.dart';

export 'libgen/lib_gen.dart';
export 'models/models.dart';

abstract class SearchExtension {
  String get name;

  Future<List<BookSearchGroup>> search(String query);
  Future<BookDetails> details(BookSearchResult result);
}
