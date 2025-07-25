import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:mcp_dart_example/core/constants/app_constants.dart';
import 'package:mcp_dart_example/data/models/chart_data_model.dart';
import 'package:mcp_dart_example/domain/entities/app_settings_entity.dart';
import 'package:mcp_dart_example/domain/entities/chart_data_entity.dart';
import 'package:mcp_dart_example/domain/entities/mcp_error_entity.dart';
import 'package:mcp_dart_example/services/database_service.dart';
import 'package:mcp_dart_example/services/mcp_service.dart';

/// Application state provider using Riverpod
class AppStateNotifier extends StateNotifier<AppState> {
  /// AppStateNotifier constructor
  AppStateNotifier() : super(const AppState()) {
    _init();
  }

  final DatabaseService _databaseService = DatabaseService();
  final MCPService _mcpService = MCPService();
  final Logger _logger = Logger();

  /// Initialize the application state
  Future<void> _init() async {
    try {
      state = state.copyWith(isLoading: true);

      // Load settings from database
      await _loadSettings();

      // Load chart data
      await _loadChartData();

      // Connect to MCP server
      await _connectToMCP();

      state = state.copyWith(isLoading: false);
    } on Exception catch (e) {
      _logger.e('Failed to initialize app state: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize application: $e',
      );
    }
  }

  /// Load settings from database
  Future<void> _loadSettings() async {
    try {
      final themeString =
          await _databaseService.getSetting(AppConstants.themeKey);
      final theme = themeString != null
          ? AppTheme.values.firstWhere(
              (t) => t.name == themeString,
              orElse: () => AppTheme.system,
            )
          : AppTheme.system;

      state = state.copyWith(
        settings: state.settings.copyWith(themeMode: theme),
      );
    } on Exception catch (e) {
      _logger.e('Failed to load settings: $e');
    }
  }

  /// Load chart data from database
  Future<void> _loadChartData() async {
    try {
      final models = await _databaseService.getChartData(
        limit: AppConstants.maxChartDataPoints,
      );

      final entities = models.map((model) => model.toEntity()).toList();

      state = state.copyWith(chartData: entities);
    } on Exception catch (e) {
      _logger.e('Failed to load chart data: $e');
    }
  }

  /// Connect to MCP server
  Future<void> _connectToMCP() async {
    try {
      await _mcpService.connect();

      // Listen to MCP connection state
      _mcpService.connectionState.listen((connectionState) {
        state = state.copyWith(mcpConnectionState: connectionState);
      });

      // Listen to MCP errors
      _mcpService.errors.listen(addError);
    } on Exception catch (e) {
      _logger.e('Failed to connect to MCP: $e');
    }
  }

  /// Add new chart data point
  Future<void> addChartDataPoint(ChartDataEntity data) async {
    try {
      // Add to database
      final model = ChartDataModel.fromEntity(data);
      await _databaseService.insertChartData(model);

      // Update state
      final updatedData = [...state.chartData, data];

      // Keep only the latest data points
      if (updatedData.length > state.settings.maxDataPoints) {
        updatedData.removeRange(
            0, updatedData.length - state.settings.maxDataPoints);
      }

      state = state.copyWith(chartData: updatedData);

      // Clean up old data in database
      await _databaseService.deleteOldChartData(state.settings.maxDataPoints);
    } on Exception catch (e) {
      _logger.e('Failed to add chart data: $e');
      state = state.copyWith(error: 'Failed to add chart data: $e');
    }
  }

  /// Add error to the error list
  Future<void> addError(MCPErrorEntity error) async {
    try {
      // Add to database
      await _databaseService.insertMCPError(error);

      // Update state
      final updatedErrors = [...state.errors, error];
      state = state.copyWith(errors: updatedErrors);
    } on Exception catch (e) {
      _logger.e('Failed to add error: $e');
    }
  }

  /// Update settings
  Future<void> updateSettings(AppSettingsEntity newSettings) async {
    try {
      // Save to database
      await _databaseService.saveSetting(
        AppConstants.themeKey,
        newSettings.themeMode.name,
      );

      // Update state
      state = state.copyWith(settings: newSettings);
    } on Exception catch (e) {
      _logger.e('Failed to update settings: $e');
      state = state.copyWith(error: 'Failed to update settings: $e');
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: '');
  }

  /// Toggle loading state
  void setLoading({required bool isLoading}) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// Search packages via MCP
  Future<List<Map<String, dynamic>>> searchPackages(String query) async {
    try {
      setLoading(isLoading: true);
      final results = await _mcpService.searchPackages(query);
      setLoading(isLoading: false);
      return results;
    } on Exception catch (e) {
      setLoading(isLoading: false);
      _logger.e('Failed to search packages: $e');
      state = state.copyWith(error: 'Failed to search packages: $e');
      rethrow;
    }
  }

  /// Get runtime errors via MCP
  Future<void> refreshRuntimeErrors() async {
    try {
      setLoading(isLoading: true);
      final errors = await _mcpService.getRuntimeErrors();

      // Add new errors to state
      for (final error in errors) {
        await addError(error);
      }

      setLoading(isLoading: false);
    } on Exception catch (e) {
      setLoading(isLoading: false);
      _logger.e('Failed to refresh runtime errors: $e');
      state = state.copyWith(error: 'Failed to refresh runtime errors: $e');
    }
  }

  /// Trigger hot reload via MCP
  Future<void> triggerHotReload() async {
    try {
      await _mcpService.triggerHotReload();
    } on Exception catch (e) {
      _logger.e('Failed to trigger hot reload: $e');
      state = state.copyWith(error: 'Failed to trigger hot reload: $e');
    }
  }

  /// Resolve error
  Future<void> resolveError(String errorId) async {
    try {
      await _databaseService.updateErrorResolution(errorId, isResolved: true);

      final updatedErrors = state.errors.map((error) {
        if (error.id == errorId) {
          return error.copyWith(isResolved: true);
        }
        return error;
      }).toList();

      state = state.copyWith(errors: updatedErrors);
    } on Exception catch (e) {
      _logger.e('Failed to resolve error: $e');
      state = state.copyWith(error: 'Failed to resolve error: $e');
    }
  }

  @override
  void dispose() {
    _mcpService.dispose();
    super.dispose();
  }
}

/// Application state
class AppState {
  /// AppState constructor
  const AppState({
    this.isLoading = false,
    this.error,
    this.settings = AppSettingsEntity.defaultSettings,
    this.chartData = const [],
    this.errors = const [],
    this.mcpConnectionState = MCPConnectionState.disconnected,
  });

  /// AppState isLoading
  final bool isLoading;

  /// AppState error
  final String? error;

  /// AppState settings
  final AppSettingsEntity settings;

  /// AppState chartData
  final List<ChartDataEntity> chartData;

  /// AppState errors
  final List<MCPErrorEntity> errors;

  /// AppState mcpConnectionState
  final MCPConnectionState mcpConnectionState;

  /// AppState copyWith
  AppState copyWith({
    bool? isLoading,
    String? error,
    AppSettingsEntity? settings,
    List<ChartDataEntity>? chartData,
    List<MCPErrorEntity>? errors,
    MCPConnectionState? mcpConnectionState,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      settings: settings ?? this.settings,
      chartData: chartData ?? this.chartData,
      errors: errors ?? this.errors,
      mcpConnectionState: mcpConnectionState ?? this.mcpConnectionState,
    );
  }
}

/// Provider for app state
final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

/// Derived providers for specific parts of state
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isLoading;
});

/// AppState error
final errorProvider = Provider<String?>((ref) {
  return ref.watch(appStateProvider).error;
});

/// AppState settings
final settingsProvider = Provider<AppSettingsEntity>((ref) {
  return ref.watch(appStateProvider).settings;
});

/// AppState chartData
final chartDataProvider = Provider<List<ChartDataEntity>>((ref) {
  return ref.watch(appStateProvider).chartData;
});

/// AppState errors
final errorsProvider = Provider<List<MCPErrorEntity>>((ref) {
  return ref.watch(appStateProvider).errors;
});

/// AppState mcpConnectionState
final mcpConnectionStateProvider = Provider<MCPConnectionState>((ref) {
  return ref.watch(appStateProvider).mcpConnectionState;
});

/// AppState themeMode
final themeProvider = Provider<ThemeMode>((ref) {
  final theme = ref.watch(settingsProvider).themeMode;
  switch (theme) {
    case AppTheme.light:
      return ThemeMode.light;
    case AppTheme.dark:
      return ThemeMode.dark;
    case AppTheme.system:
      return ThemeMode.system;
  }
});
