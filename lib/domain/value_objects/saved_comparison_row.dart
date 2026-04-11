import 'package:equatable/equatable.dart';

/// An immutable snapshot of one price row stored in a [SavedComparison].
final class SavedComparisonRow extends Equatable {
  const SavedComparisonRow({
    required this.label,
    required this.price,
    required this.qty,
    required this.points,
  });

  final String label;
  final double price;
  final double qty;
  final double points;

  /// 実質単価 = (金額 - ポイント) ÷ 数量。[qty] が 0 以下の場合は null。
  double? get unitPrice {
    if (qty <= 0) return null;
    return (price - points) / qty;
  }

  @override
  List<Object?> get props => [label, price, qty, points];
}
