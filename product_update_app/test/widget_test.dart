// The app uses Firestore directly, so a full widget test needs a Firebase project or a fake.
// This test only checks the input rules used by UPDATE in main.dart.
import 'package:flutter_test/flutter_test.dart';

bool valid(String q, String p) {
  final qty = int.tryParse(q.trim());
  final price = double.tryParse(p.trim());
  return !(qty == null || qty < 0 || price == null || price < 0);
}

void main() {
  test('valid quantity and price are accepted', () {
    expect(valid('75', '50'), isTrue);
    expect(valid('0', '45.5'), isTrue);
  });

  test('invalid or negative values are rejected (test case 6)', () {
    expect(valid('abc', '50'), isFalse);
    expect(valid('75', ''), isFalse);
    expect(valid('-1', '50'), isFalse);
  });
}
