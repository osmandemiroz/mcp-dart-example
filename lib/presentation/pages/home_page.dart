import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mcp_dart_example/core/constants/app_constants.dart';
import 'package:mcp_dart_example/domain/entities/chart_data_entity.dart';
import 'package:mcp_dart_example/domain/entities/mcp_error_entity.dart';
import 'package:mcp_dart_example/presentation/providers/app_state_provider.dart';
import 'package:mcp_dart_example/presentation/widgets/enhanced_chart_widget.dart';
import 'package:mcp_dart_example/presentation/widgets/error_display_widget.dart';
import 'package:mcp_dart_example/services/mcp_service.dart';
import 'package:uuid/uuid.dart';

/// Enhanced home page with modern architecture and features
class HomePage extends ConsumerStatefulWidget {
  /// HomePage constructor
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _buttonPressCount = 0;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final error = ref.watch(errorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Charts'),
            Tab(icon: Icon(Icons.error_outline), text: 'Errors'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
        actions: [
          _buildConnectionIndicator(appState.mcpConnectionState),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildDashboardTab(),
              _buildChartsTab(),
              _buildErrorsTab(),
              _buildSettingsTab(),
            ],
          ),
          if (isLoading)
            const ColoredBox(
              color: Colors.black26,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _incrementCounter,
        icon: const Icon(Icons.add),
        label: const Text('Add Data'),
        tooltip: 'Add new data point',
      ),
      bottomNavigationBar: error != null
          ? Container(
              color: Theme.of(context).colorScheme.errorContainer,
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        ref.read(appStateProvider.notifier).clearError(),
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildConnectionIndicator(MCPConnectionState state) {
    Color color;
    IconData icon;
    String tooltip;

    switch (state) {
      case MCPConnectionState.connected:
        color = Colors.green;
        icon = Icons.cloud_done;
        tooltip = 'Connected to MCP Server';
      case MCPConnectionState.connecting:
        color = Colors.orange;
        icon = Icons.cloud_sync;
        tooltip = 'Connecting to MCP Server';
      case MCPConnectionState.disconnected:
        color = Colors.grey;
        icon = Icons.cloud_off;
        tooltip = 'Disconnected from MCP Server';
      case MCPConnectionState.error:
        color = Colors.red;
        icon = Icons.cloud_off;
        tooltip = 'MCP Server Connection Error';
      case MCPConnectionState.failed:
        color = Colors.red;
        icon = Icons.error;
        tooltip = 'MCP Server Connection Failed';
    }

    return Padding(
      padding: const EdgeInsets.only(right: AppConstants.smallPadding),
      child: Tooltip(
        message: tooltip,
        child: Icon(icon, color: color),
      ),
    );
  }

  Widget _buildDashboardTab() {
    final chartData = ref.watch(chartDataProvider);
    final errors = ref.watch(errorsProvider);
    final settings = ref.watch(settingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to ${AppConstants.appName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    AppConstants.appDescription,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  Wrap(
                    spacing: AppConstants.smallPadding,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.data_usage, size: 16),
                        label: Text('${chartData.length} Data Points'),
                      ),
                      Chip(
                        avatar: Icon(
                          Icons.error_outline,
                          size: 16,
                          color: errors.where((e) => !e.isResolved).isEmpty
                              ? Colors.green
                              : Colors.red,
                        ),
                        label: Text(
                          '${errors.where((e) => !e.isResolved).length} Active Errors',
                        ),
                      ),
                      Chip(
                        avatar: const Icon(Icons.settings, size: 16),
                        label: Text('Theme: ${settings.themeMode.displayName}'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Quick stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Button Presses',
                  _buttonPressCount.toString(),
                  Icons.touch_app,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: _buildStatCard(
                  'Data Points',
                  chartData.length.toString(),
                  Icons.show_chart,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Mini chart preview
          EnhancedChartWidget(
            data: chartData.take(10).toList(),
            chartType: ChartType.line,
            title: 'Recent Activity',
            height: 200,
            showDataLabels: false,
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // MCP Tools section
          _buildMCPToolsSection(),
        ],
      ),
    );
  }

  Widget _buildChartsTab() {
    final chartData = ref.watch(chartDataProvider);
    final settings = ref.watch(settingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Chart type selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chart Configuration',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Wrap(
                    spacing: AppConstants.smallPadding,
                    children: ChartType.values.map((type) {
                      return ChoiceChip(
                        label: Text(type.displayName),
                        selected: settings.chartType == type,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(appStateProvider.notifier).updateSettings(
                                  settings.copyWith(chartType: type),
                                );
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Main chart
          EnhancedChartWidget(
            data: chartData,
            chartType: settings.chartType,
            title: 'Data Visualization - ${settings.chartType.displayName}',
            onDataPointTap: (data) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Data Point: ${data.label} = ${data.value}',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorsTab() {
    final errors = ref.watch(errorsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Error controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Error Management',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => ref
                        .read(appStateProvider.notifier)
                        .refreshRuntimeErrors(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Errors'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Error display
          ErrorDisplayWidget(
            errors: errors,
            onErrorTap: _showErrorDetails,
            onResolveError: (errorId) {
              ref.read(appStateProvider.notifier).resolveError(errorId);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    final settings = ref.watch(settingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Theme settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Column(
                    children: AppTheme.values.map((theme) {
                      return RadioListTile<AppTheme>(
                        title: Text(theme.displayName),
                        value: theme,
                        groupValue: settings.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(appStateProvider.notifier).updateSettings(
                                  settings.copyWith(themeMode: value),
                                );
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Data settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Management',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  SwitchListTile(
                    title: const Text('Auto Refresh'),
                    subtitle: const Text('Automatically refresh data'),
                    value: settings.autoRefresh,
                    onChanged: (value) {
                      ref.read(appStateProvider.notifier).updateSettings(
                            settings.copyWith(autoRefresh: value),
                          );
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Show error notifications'),
                    value: settings.enableNotifications,
                    onChanged: (value) {
                      ref.read(appStateProvider.notifier).updateSettings(
                            settings.copyWith(enableNotifications: value),
                          );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMCPToolsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MCP Server Tools',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Wrap(
              spacing: AppConstants.smallPadding,
              runSpacing: AppConstants.smallPadding,
              children: [
                _buildMCPToolButton(
                  'Search Packages',
                  Icons.search,
                  Colors.blue,
                  _searchPackages,
                ),
                _buildMCPToolButton(
                  'Hot Reload',
                  Icons.refresh,
                  Colors.green,
                  () => ref.read(appStateProvider.notifier).triggerHotReload(),
                ),
                _buildMCPToolButton(
                  'Inspect Widgets',
                  Icons.widgets,
                  Colors.purple,
                  _inspectWidgets,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMCPToolButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
      ),
    );
  }

  void _incrementCounter() {
    setState(() {
      _buttonPressCount++;
    });

    // Add new data point
    final dataPoint = ChartDataEntity(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      value: _buttonPressCount.toDouble(),
      label: 'Press $_buttonPressCount',
    );

    ref.read(appStateProvider.notifier).addChartDataPoint(dataPoint);
  }

  void _refreshData() {
    ref.read(appStateProvider.notifier).refreshRuntimeErrors();
  }

  Future<void> _searchPackages() async {
    try {
      final results = await ref
          .read(appStateProvider.notifier)
          .searchPackages('http client');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found ${results.length} packages'),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _inspectWidgets() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Widget inspection started'),
      ),
    );
  }

  void _showErrorDetails(MCPErrorEntity error) {
    showDialog<Widget>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(error.errorType),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Message: ${error.message}'),
              if (error.filePath != null) ...[
                const SizedBox(height: 8),
                Text('File: ${error.filePath}'),
              ],
              if (error.lineNumber != null) ...[
                const SizedBox(height: 4),
                Text('Line: ${error.lineNumber}'),
              ],
              if (error.stackTrace != null) ...[
                const SizedBox(height: 8),
                const Text('Stack Trace:'),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    error.stackTrace!,
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!error.isResolved)
            ElevatedButton(
              onPressed: () {
                ref.read(appStateProvider.notifier).resolveError(error.id);
                Navigator.of(context).pop();
              },
              child: const Text('Mark as Resolved'),
            ),
        ],
      ),
    );
  }
}
