import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/validators.dart';

void main() {
  group('phone normalization (TZ → E.164)', () {
    test('accepts +255', () => expect(Validators.normalizePhone('+255742000000'), '+255742000000'));
    test('accepts 0-prefix', () => expect(Validators.normalizePhone('0742000000'), '+255742000000'));
    test('accepts 255 no-plus', () => expect(Validators.normalizePhone('255742000000'), '+255742000000'));
    test('rejects short', () => expect(Validators.normalizePhone('123'), null));
    test('rejects letters', () => expect(Validators.normalizePhone('+255abc'), null));
  });
  group('age calculation', () {
    final now = DateTime(2026, 6, 15);
    test('18th birthday today counts as adult', () {
      expect(Validators.isAdult(DateTime(2008, 6, 15), now), true);
    });
    test('18th birthday tomorrow still underage', () {
      expect(Validators.isAdult(DateTime(2008, 6, 16), now), false);
    });
    test('17 is underage', () => expect(Validators.isAdult(DateTime(2009, 1, 1), now), false));
    test('30 is adult', () => expect(Validators.isAdult(DateTime(1996, 3, 1), now), true));
  });
  group('password rule (backend min 12)', () {
    test('12 chars ok', () => expect(Validators.passwordError('a' * 12), null));
    test('11 chars rejected', () => expect(Validators.passwordError('a' * 11), 'min_12'));
  });
}
