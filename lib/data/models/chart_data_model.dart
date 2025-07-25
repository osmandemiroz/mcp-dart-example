import 'package:json_annotation/json_annotation.dart';
import 'package:mcp_dart_example/domain/entities/chart_data_entity.dart';

part 'chart_data_model.g.dart';

/// Data model for chart data with JSON serialization
@JsonSerializable()
class ChartDataModel {
  /// Chart data model constructor
  const ChartDataModel({
    required this.id,
    required this.timestamp,
    required this.value,
    required this.label,
    this.category,
    this.metadata,
  });

  /// Convert from JSON
  factory ChartDataModel.fromJson(Map<String, dynamic> json) =>
      _$ChartDataModelFromJson(json);

  /// Create from entity
  factory ChartDataModel.fromEntity(ChartDataEntity entity) {
    return ChartDataModel(
      id: entity.id,
      timestamp: entity.timestamp,
      value: entity.value,
      label: entity.label,
      category: entity.category,
      metadata: entity.metadata,
    );
  }

  /// Create from database map
  factory ChartDataModel.fromMap(Map<String, dynamic> map) {
    return ChartDataModel(
      id: map['id'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      value: map['value'] as double,
      label: map['label'] as String,
      category: map['category'] as String?,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
    );
  }

  /// Chart data model id
  final String id;

  /// Chart data model timestamp
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime timestamp;

  /// Chart data model value
  final double value;

  /// Chart data model label
  final String label;

  /// Chart data model category
  final String? category;

  /// Chart data model metadata
  final Map<String, dynamic>? metadata;

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$ChartDataModelToJson(this);

  /// Convert to entity
  ChartDataEntity toEntity() {
    return ChartDataEntity(
      id: id,
      timestamp: timestamp,
      value: value,
      label: label,
      category: category,
      metadata: metadata,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'value': value,
      'label': label,
      'category': category,
      'metadata': metadata,
    };
  }

  static DateTime _dateTimeFromJson(String json) => DateTime.parse(json);
  static String _dateTimeToJson(DateTime dateTime) =>
      dateTime.toIso8601String();
}
