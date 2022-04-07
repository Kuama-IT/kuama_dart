import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

void after(void Function() fn) async {
  await Future.delayed(const Duration(milliseconds: 1));
  fn();
}

class TheoryData<I, O> {
  final I input;
  final O output;

  TheoryData(this.input, this.output);
}

@isTest
void testTheory<I, O>(String description, List<TheoryData<I, O>> data, O Function(I input) body) {
  test(description, () {
    for (var i = 0; i < data.length; i++) {
      final entry = data[i];

      try {
        final actual = body(entry.input);
        expect(actual, entry.output);
      } on TestFailure catch (error) {
        throw TestFailure('TestTheory failed at $i:\nInput: <${entry.input}>\n${error.message}');
      }
    }
  });
}
