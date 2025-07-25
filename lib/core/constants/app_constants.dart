/// Application-wide constants
class AppConstants {
  // App Info
  /// Application name
  static const String appName = 'MCP Dart Pro';

  /// Application version
  static const String appVersion = '2.0.0';

  /// Application description
  static const String appDescription = 'Advanced Dart MCP Server Integration';

  // Database
  /// Database name
  static const String databaseName = 'mcp_dart_pro.db';

  /// Database version
  static const int databaseVersion = 1;

  // Storage Keys
  /// Theme mode storage key
  static const String themeKey = 'theme_mode';

  /// Settings storage key
  static const String settingsKey = 'app_settings';

  /// Chart data storage key
  static const String chartDataKey = 'chart_data';

  /// Error log storage key
  static const String errorLogKey = 'error_logs';

  // MCP Server
  /// MCP server URL
  static const String mcpServerUrl = 'ws://localhost:8080/mcp';

  /// Connection timeout duration
  static const Duration connectionTimeout = Duration(seconds: 30);

  /// Reconnect delay duration
  static const Duration reconnectDelay = Duration(seconds: 5);

  /// Maximum reconnect attempts
  static const int maxReconnectAttempts = 3;

  // Chart Configuration
  /// Maximum chart data points
  static const int maxChartDataPoints = 50;

  /// Chart update interval
  static const Duration chartUpdateInterval = Duration(seconds: 1);

  /// Default chart animation duration
  static const int defaultChartAnimationDuration = 300;

  // UI Constants
  /// Default padding
  static const double defaultPadding = 16;

  /// Small padding
  static const double smallPadding = 8;

  /// Large padding
  static const double largePadding = 24;

  /// Border radius
  static const double borderRadius = 12;

  /// Card elevation
  static const double cardElevation = 4;

  // Animation Durations
  /// Short animation duration
  static const Duration shortAnimation = Duration(milliseconds: 200);

  /// Medium animation duration
  static const Duration mediumAnimation = Duration(milliseconds: 300);

  /// Long animation duration
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Export/Import
  /// Supported export formats
  static const List<String> supportedExportFormats = ['csv', 'json', 'xlsx'];

  /// Default export file name
  static const String defaultExportFileName = 'mcp_data_export';

  // Error Messages
  /// Connection error message
  static const String connectionErrorMessage =
      'Failed to connect to MCP server';

  /// Data load error message
  static const String dataLoadErrorMessage = 'Failed to load data';

  /// Export error message
  static const String importErrorMessage = 'Failed to import data';
}

/// MCP Tool identifiers
enum MCPTool {
  /// MCP tool name
  pubDevSearch('pub_dev_search'),

  /// MCP tool name
  pubspecManager('pubspec_manager'),

  /// MCP tool name
  errorInspector('error_inspector'),

  /// MCP tool name
  widgetInspector('widget_inspector'),

  /// MCP tool name
  hotReload('hot_reload'),

  /// MCP tool name
  testRunner('test_runner'),

  /// MCP tool name
  codeAnalyzer('code_analyzer');

  const MCPTool(this.toolName);

  /// MCP tool name
  final String toolName;
}

/// Chart types available in the application
enum ChartType {
  /// Chart type name
  line('Line Chart'),

  /// Chart type name
  bar('Bar Chart'),

  /// Chart type name
  pie('Pie Chart'),

  /// Chart type name
  area('Area Chart'),

  /// Chart type name
  scatter('Scatter Plot');

  const ChartType(this.displayName);

  /// Chart type name
  final String displayName;
}

/// Application themes
enum AppTheme {
  /// Application theme name
  light('Light'),

  /// Application theme name
  dark('Dark'),

  /// Application theme name
  system('System');

  const AppTheme(this.displayName);

  /// Application theme name
  final String displayName;
}
