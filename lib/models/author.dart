import 'dart:developer';

import '../helpers/helpers.dart';

class Author {
  final String name;
  final String? birth;
  final String? death;

  Author(
    this.name, {
    this.birth,
    this.death,
  });

  bool _areIndividualNamesEqual(String a, String b) {
    if (a.disambiguate() == b.disambiguate()) {
      return true;
    }

    final aNames = a.replaceAll(',', '').split(' ').where((str) => str.isNotEmpty).toList()..sort();
    final bNames = b.replaceAll(',', '').split(' ').where((str) => str.isNotEmpty).toList()..sort();

    if (aNames.length != bNames.length) {
      return false;
    }

    bool nameIsEqual = true;

    for (var i = 0; i < aNames.length; i++) {
      final aName = aNames[i].disambiguate();
      final bName = bNames[i].disambiguate();

      if (aName.length == 1 || bName.length == 1) {
        final sameInitials = aName.startsWith(bName.substring(0, 1));

        nameIsEqual = nameIsEqual && sameInitials;
      }
    }

    return nameIsEqual;
  }

  bool isEqual(Author other) {
    try {
      final myAuthors = name.split(';')..sort();
      final otherAUthors = other.name.split(';')..sort();

      if (myAuthors.length != otherAUthors.length) {
        return false;
      }

      bool areAuthorsEqual = true;

      for (var i = 0; i < myAuthors.length; i++) {
        areAuthorsEqual = areAuthorsEqual &&
            _areIndividualNamesEqual(
              myAuthors[i],
              otherAUthors[i],
            );

        if (!areAuthorsEqual) return false;
      }

      return areAuthorsEqual;
    } catch (e) {
      log('Error on Author.isEqual $e', stackTrace: (e as Error).stackTrace);
      return false;
    }
  }

  @override
  String toString() {
    return name;
  }
}
