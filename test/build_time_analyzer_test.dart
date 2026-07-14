import 'package:flutter_test/flutter_test.dart';

import 'package:build_time_analyzer/build_time_analyzer.dart';

void main() {
  test('adds one to input values', () {
    final calculator = Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
  });
}
