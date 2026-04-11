import 'package:flutter_test/flutter_test.dart';
import 'package:pricecompare/presentation/pages/compare_page.dart';

void main() {
  group('PriceRow.unitPrice', () {
    late PriceRow row;

    setUp(() {
      row = PriceRow(id: 'test');
    });

    tearDown(() {
      row.dispose();
    });

    test('returns null when price is empty', () {
      row.qty.text = '100';
      expect(row.unitPrice, isNull);
    });

    test('returns null when qty is empty', () {
      row.price.text = '500';
      expect(row.unitPrice, isNull);
    });

    test('returns null when qty is zero', () {
      row.price.text = '500';
      row.qty.text = '0';
      expect(row.unitPrice, isNull);
    });

    test('returns null when qty is negative', () {
      row.price.text = '500';
      row.qty.text = '-1';
      expect(row.unitPrice, isNull);
    });

    test('calculates unit price without points', () {
      row.price.text = '500';
      row.qty.text = '250';
      expect(row.unitPrice, equals(2.0));
    });

    test('calculates unit price with points deducted', () {
      row.price.text = '500';
      row.qty.text = '250';
      row.points.text = '50';
      expect(row.unitPrice, equals(1.8));
    });

    test('treats empty points as zero', () {
      row.price.text = '300';
      row.qty.text = '100';
      // points empty → defaults to 0
      expect(row.unitPrice, equals(3.0));
    });

    test('handles decimal qty', () {
      row.price.text = '100';
      row.qty.text = '0.5';
      expect(row.unitPrice, equals(200.0));
    });

    test('handles decimal price', () {
      row.price.text = '99.9';
      row.qty.text = '3';
      expect(row.unitPrice, closeTo(33.3, 0.001));
    });
  });
}
