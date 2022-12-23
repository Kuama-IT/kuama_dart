abstract class Identifiable<T extends Object> {
  T get id;
}

extension IdentifiableIterable<E extends Identifiable<T>, T extends Object> on Iterable<E> {
  Iterable<T> get ids => map((e) => e.id);

  bool containsId(T id) => any((e) => e.id == id);
  E firstWhereId(T id) => firstWhere((e) => e.id == id);
  Iterable<E> whereIds(List<String> ids) => where((e) => ids.contains(e.id));
}
