import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(const MCPDartExampleApp());
}

/// The main application widget.
class MCPDartExampleApp extends StatelessWidget {
  /// The main application widget.
  const MCPDartExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dart MCP Server Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

/// The main application widget.
class HomePage extends StatefulWidget {
  /// The main application widget.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _buttonPressCount = 0;
  List<ChartData> _chartData = [];
  bool _showLayoutError = false;
  final List<String> _runtimeErrors = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chartData = [
      ChartData(DateTime.now().subtract(const Duration(minutes: 5)), 0),
      ChartData(DateTime.now().subtract(const Duration(minutes: 4)), 0),
      ChartData(DateTime.now().subtract(const Duration(minutes: 3)), 0),
      ChartData(DateTime.now().subtract(const Duration(minutes: 2)), 0),
      ChartData(DateTime.now().subtract(const Duration(minutes: 1)), 0),
      ChartData(DateTime.now(), 0),
    ];
  }

  void _incrementCounter() {
    setState(() {
      _buttonPressCount++;
      // Add new data point to chart
      _chartData.add(ChartData(DateTime.now(), _buttonPressCount));
      // Keep only last 10 data points
      if (_chartData.length > 10) {
        _chartData.removeAt(0);
      }
    });
  }

  void _simulateLayoutError() {
    setState(() {
      _showLayoutError = !_showLayoutError;
      if (_showLayoutError) {
        _runtimeErrors.add('RenderFlex overflow detected at ${DateTime.now()}');
      } else {
        _runtimeErrors.clear();
      }
    });
  }

  /// Simulates MCP package search and adds the found package to pubspec.yaml.
  Future<void> _simulatePackageSearch() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate MCP package search delay
    await Future<void>.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📦 MCP found and added: syncfusion_flutter_charts'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _triggerHotReload() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔥 Hot reload triggered via MCP'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Dart MCP Server Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dart MCP Server Example',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This app demonstrates features that can be enhanced with the Dart MCP Server:',
                    ),
                    const SizedBox(height: 8),
                    const Text('• Runtime error detection and fixing'),
                    const Text('• Package search and dependency management'),
                    const Text('• Widget tree inspection'),
                    const Text('• Hot reload integration'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Counter section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Button Press Counter',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'You have pressed the button this many times:',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_buttonPressCount',
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Chart section - demonstrates package added via MCP
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Button Presses Over Time',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chart added using syncfusion_flutter_charts package (found via pub.dev search)',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: SfCartesianChart(
                        primaryXAxis: DateTimeAxis(
                          dateFormat: DateFormat.Hm(),
                          intervalType: DateTimeIntervalType.minutes,
                        ),
                        primaryYAxis:
                            const NumericAxis(minimum: 0, interval: 1),
                        title: const ChartTitle(text: 'Button Press Timeline'),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <CartesianSeries<ChartData, DateTime>>[
                          LineSeries<ChartData, DateTime>(
                            dataSource: _chartData,
                            xValueMapper: (ChartData data, _) => data.time,
                            yValueMapper: (ChartData data, _) => data.count,
                            name: 'Button Presses',
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                            ),
                            markerSettings: const MarkerSettings(
                              isVisible: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Interactive MCP Demo section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interactive MCP Demo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Try these MCP server capabilities:',
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _simulateLayoutError,
                          icon: Icon(
                              _showLayoutError ? Icons.check : Icons.warning),
                          label: Text(_showLayoutError
                              ? 'Fix Layout'
                              : 'Simulate Error'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _showLayoutError
                                ? Colors.red.shade100
                                : Colors.orange.shade100,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _simulatePackageSearch,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.search),
                          label: Text(
                              _isLoading ? 'Searching...' : 'Find Package'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade100,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _triggerHotReload,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Hot Reload'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade100,
                          ),
                        ),
                      ],
                    ),
                    if (_runtimeErrors.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.error,
                                    color: Colors.red.shade600, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Runtime Errors Detected:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ..._runtimeErrors.map((error) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '• $error',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                    if (_showLayoutError) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade50,
                          border: Border.all(color: Colors.yellow.shade600),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                color: Colors.yellow.shade200,
                                child: const Center(
                                  child: Text(
                                    'OVERFLOW ERROR SIMULATION',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 100,
                              height: 50,
                              color: Colors.red.shade300,
                              child: const Center(
                                child: Text(
                                  'OVERFLOW',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // MCP Tools section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MCP Server Tools',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildToolItem(
                      'pub_dev_search',
                      'Search pub.dev for packages',
                      'Find the best packages for your use case',
                    ),
                    _buildToolItem(
                      'pubspec_manager',
                      'Manage dependencies',
                      'Add/remove packages from pubspec.yaml',
                    ),
                    _buildToolItem(
                      'error_inspector',
                      'Runtime error detection',
                      'Get current runtime errors from running app',
                    ),
                    _buildToolItem(
                      'widget_inspector',
                      'Widget tree inspection',
                      'Access Flutter widget tree for debugging',
                    ),
                    _buildToolItem(
                      'hot_reload',
                      'Hot reload integration',
                      'Trigger hot reload programmatically',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildToolItem(String toolName, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              toolName,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chart data class for representing button press data over time.
class ChartData {
  /// Creates a new ChartData instance.
  ChartData(this.time, this.count);

  /// Time of the button press.
  final DateTime time;

  /// Count of the button press.
  final int count;
}
