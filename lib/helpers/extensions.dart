extension StringHelpers on String {
  String disambiguate() {
    final meaningless = RegExp(r"\s|['’:.?!,]");

    return toUpperCase().replaceAll(
      meaningless,
      '',
    );
  }

  String removePunctuation() {
    final punctuation = RegExp(r"['’:.?!,]");

    return replaceAll(
      punctuation,
      '',
    );
  }
}

extension ListHelpers<T> on List<T>? {
  T? at(int index) {
    final self = this;

    if (self != null && index >= 0 && index < self.length) {
      return self[index];
    }

    return null;
  }
}

extension MapHelpers<T, D> on Map<T, D>? {
  D? at(T key) {
    final self = this;

    if (self?.containsKey(key) == true) {
      return self![key];
    }

    return null;
  }
}
