import 'package:equatable/equatable.dart';

/// Entity representing chart data point
class ChartDataEntity extends Equatable {
  /// ChartDataEntity constructor
  const ChartDataEntity({
    required this.id,
    required this.timestamp,
    required this.value,
    required this.label,
    this.category,
    this.metadata,
  });

  /// ChartDataEntity id
  final String id;

  /// ChartDataEntity timestamp
  final DateTime timestamp;

  /// ChartDataEntity value
  final double value;

  /// ChartDataEntity label
  final String label;

  /// ChartDataEntity category
  final String? category;

  /// ChartDataEntity metadata
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [id, timestamp, value, label, category, metadata];

  /// ChartDataEntity copy with
  ChartDataEntity copyWith({
    String? id,
    DateTime? timestamp,
    double? value,
    String? label,
    String? category,
    Map<String, dynamic>? metadata,
  }) {
    return ChartDataEntity(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      value: value ?? this.value,
      label: label ?? this.label,
      category: category ?? this.category,
      metadata: metadata ?? this.metadata,
    );
  }
}
