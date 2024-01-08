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
