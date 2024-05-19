extension StringExtension on String {
  String capitalize() {
    List<String> names = split(' ');
    String joined = '';
    for (String name in names) {
      joined += '${name[0].toUpperCase()}${name.substring(1).toLowerCase()} ';
    }
    return joined.trim();
  }
}
