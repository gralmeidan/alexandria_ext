import 'models/book.dart';

export 'libgen/lib_gen.dart';

abstract class SearchExtension {
  Future<List<BookSearchGroup>> search(String query);
}
