import 'models/book.dart';

export 'libgen/lib_gen.dart';
export 'models/models.dart';

abstract class SearchExtension {
  String get name;

  Future<List<BookSearchGroup>> search(String query);
}
