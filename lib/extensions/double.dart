extension DoubleExtension on double {
  int roundBa() {
    // Rounds like the normal function but with these exception
    // At .5 round down
    // Everything above 4.0 is 5

    if (this > 4.0 && this < 5.0) {
      return 5;
    }

    if (this % 1 <= 0.5) {
      return floor();
    }

    return ceil();
  }
}
