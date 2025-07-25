// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartDataModel _$ChartDataModelFromJson(Map<String, dynamic> json) =>
    ChartDataModel(
      id: json['id'] as String,
      timestamp: ChartDataModel._dateTimeFromJson(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
      label: json['label'] as String,
      category: json['category'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ChartDataModelToJson(ChartDataModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': ChartDataModel._dateTimeToJson(instance.timestamp),
      'value': instance.value,
      'label': instance.label,
      'category': instance.category,
      'metadata': instance.metadata,
    };
