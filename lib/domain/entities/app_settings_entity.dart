import 'package:equatable/equatable.dart';
import 'package:mcp_dart_example/core/constants/app_constants.dart';

/// Entity representing application settings
class AppSettingsEntity extends Equatable {
  /// AppSettingsEntity constructor
  const AppSettingsEntity({
    required this.themeMode,
    required this.chartType,
    required this.maxDataPoints,
    required this.autoRefresh,
    required this.refreshInterval,
    required this.enableNotifications,
    required this.enableErrorLogging,
    required this.mcpServerUrl,
    required this.exportFormat,
  });

  /// AppSettingsEntity theme mode
  final AppTheme themeMode;

  /// AppSettingsEntity chart type
  final ChartType chartType;

  /// AppSettingsEntity max data points
  final int maxDataPoints;

  /// AppSettingsEntity auto refresh
  final bool autoRefresh;

  /// AppSettingsEntity refresh interval
  final Duration refreshInterval;

  /// AppSettingsEntity enable notifications
  final bool enableNotifications;

  /// AppSettingsEntity enable error logging
  final bool enableErrorLogging;

  /// AppSettingsEntity mcp server url
  final String mcpServerUrl;

  /// AppSettingsEntity export format
  final String exportFormat;

  @override
  List<Object?> get props => [
        themeMode,
        chartType,
        maxDataPoints,
        autoRefresh,
        refreshInterval,
        enableNotifications,
        enableErrorLogging,
        mcpServerUrl,
        exportFormat,
      ];

  /// AppSettingsEntity copy with
  AppSettingsEntity copyWith({
    AppTheme? themeMode,
    ChartType? chartType,
    int? maxDataPoints,
    bool? autoRefresh,
    Duration? refreshInterval,
    bool? enableNotifications,
    bool? enableErrorLogging,
    String? mcpServerUrl,
    String? exportFormat,
  }) {
    return AppSettingsEntity(
      themeMode: themeMode ?? this.themeMode,
      chartType: chartType ?? this.chartType,
      maxDataPoints: maxDataPoints ?? this.maxDataPoints,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableErrorLogging: enableErrorLogging ?? this.enableErrorLogging,
      mcpServerUrl: mcpServerUrl ?? this.mcpServerUrl,
      exportFormat: exportFormat ?? this.exportFormat,
    );
  }

  /// Default settings
  static const AppSettingsEntity defaultSettings = AppSettingsEntity(
    themeMode: AppTheme.system,
    chartType: ChartType.line,
    maxDataPoints: AppConstants.maxChartDataPoints,
    autoRefresh: true,
    refreshInterval: AppConstants.chartUpdateInterval,
    enableNotifications: true,
    enableErrorLogging: true,
    mcpServerUrl: AppConstants.mcpServerUrl,
    exportFormat: 'csv',
  );
}
