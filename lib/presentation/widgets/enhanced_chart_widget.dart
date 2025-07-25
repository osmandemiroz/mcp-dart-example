import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcp_dart_example/core/constants/app_constants.dart'
    hide AppTheme;
import 'package:mcp_dart_example/core/theme/app_theme.dart';
import 'package:mcp_dart_example/domain/entities/chart_data_entity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Enhanced chart widget with multiple chart types and animations
class EnhancedChartWidget extends StatefulWidget {
  /// EnhancedChartWidget constructor
  const EnhancedChartWidget({
    required this.data,
    required this.chartType,
    super.key,
    this.title,
    this.showLegend = true,
    this.showDataLabels = true,
    this.enableAnimation = true,
    this.height = 300,
    this.onDataPointTap,
  });

  /// List of chart data
  final List<ChartDataEntity> data;

  /// Chart type
  final ChartType chartType;

  /// Chart title
  final String? title;

  /// Whether to show legend
  final bool showLegend;

  /// Whether to show data labels
  final bool showDataLabels;

  /// Whether to enable animation
  final bool enableAnimation;

  /// Chart height
  final double height;

  /// Function to be called when a data point is tapped
  final void Function(ChartDataEntity)? onDataPointTap;

  @override
  State<EnhancedChartWidget> createState() => _EnhancedChartWidgetState();
}

class _EnhancedChartWidgetState extends State<EnhancedChartWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(
          milliseconds: AppConstants.defaultChartAnimationDuration),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.enableAnimation) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null) ...[
              Text(
                widget.title!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.smallPadding),
            ],
            SizedBox(
              height: widget.height,
              child: widget.enableAnimation
                  ? AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _animation.value,
                          child: Transform.scale(
                            scale: 0.8 + (0.2 * _animation.value),
                            child: _buildChart(),
                          ),
                        );
                      },
                    )
                  : _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (widget.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'No data available',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    switch (widget.chartType) {
      case ChartType.line:
        return _buildLineChart();
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.pie:
        return _buildPieChart();
      case ChartType.area:
        return _buildAreaChart();
      case ChartType.scatter:
        return _buildScatterChart();
    }
  }

  Widget _buildLineChart() {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat.Hm(),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        minimum: 0,
        majorGridLines: MajorGridLines(width: 0.5),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      legend:
          widget.showLegend ? const Legend(isVisible: true) : const Legend(),
      series: <CartesianSeries<ChartDataEntity, DateTime>>[
        LineSeries<ChartDataEntity, DateTime>(
          dataSource: widget.data,
          xValueMapper: (ChartDataEntity data, _) => data.timestamp,
          yValueMapper: (ChartDataEntity data, _) => data.value,
          name: 'Data Points',
          color: AppTheme.chartColors[0],
          width: 3,
          markerSettings: const MarkerSettings(
            isVisible: true,
            height: 6,
            width: 6,
          ),
          dataLabelSettings: DataLabelSettings(
            isVisible: widget.showDataLabels,
            labelAlignment: ChartDataLabelAlignment.top,
          ),
          animationDuration: widget.enableAnimation ? 1000 : 0,
          onPointTap: widget.onDataPointTap != null
              ? (pointInteractionDetails) {
                  final index = pointInteractionDetails.pointIndex;
                  if (index != null && index < widget.data.length) {
                    widget.onDataPointTap!(widget.data[index]);
                  }
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        minimum: 0,
        majorGridLines: MajorGridLines(width: 0.5),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      legend:
          widget.showLegend ? const Legend(isVisible: true) : const Legend(),
      series: <CartesianSeries<ChartDataEntity, String>>[
        ColumnSeries<ChartDataEntity, String>(
          dataSource: widget.data,
          xValueMapper: (ChartDataEntity data, _) => data.label,
          yValueMapper: (ChartDataEntity data, _) => data.value,
          name: 'Values',
          color: AppTheme.chartColors[1],
          dataLabelSettings: DataLabelSettings(
            isVisible: widget.showDataLabels,
            labelAlignment: ChartDataLabelAlignment.top,
          ),
          animationDuration: widget.enableAnimation ? 1000 : 0,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    return SfCircularChart(
      tooltipBehavior: TooltipBehavior(enable: true),
      legend:
          widget.showLegend ? const Legend(isVisible: true) : const Legend(),
      series: <CircularSeries<ChartDataEntity, String>>[
        PieSeries<ChartDataEntity, String>(
          dataSource: widget.data,
          xValueMapper: (ChartDataEntity data, _) => data.label,
          yValueMapper: (ChartDataEntity data, _) => data.value,
          name: 'Data',
          dataLabelSettings: DataLabelSettings(
            isVisible: widget.showDataLabels,
            labelPosition: ChartDataLabelPosition.outside,
          ),
          animationDuration: widget.enableAnimation ? 1000 : 0,
          pointColorMapper: (ChartDataEntity data, index) =>
              AppTheme.chartColors[index % AppTheme.chartColors.length],
          explode: true,
          explodeIndex: 0,
        ),
      ],
    );
  }

  Widget _buildAreaChart() {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat.Hm(),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        minimum: 0,
        majorGridLines: MajorGridLines(width: 0.5),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      legend:
          widget.showLegend ? const Legend(isVisible: true) : const Legend(),
      series: <CartesianSeries<ChartDataEntity, DateTime>>[
        AreaSeries<ChartDataEntity, DateTime>(
          dataSource: widget.data,
          xValueMapper: (ChartDataEntity data, _) => data.timestamp,
          yValueMapper: (ChartDataEntity data, _) => data.value,
          name: 'Area Data',
          color: AppTheme.chartColors[2].withAlpha(170),
          borderColor: AppTheme.chartColors[2],
          dataLabelSettings: DataLabelSettings(
            isVisible: widget.showDataLabels,
            labelAlignment: ChartDataLabelAlignment.top,
          ),
          animationDuration: widget.enableAnimation ? 1000 : 0,
        ),
      ],
    );
  }

  Widget _buildScatterChart() {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat.Hm(),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        minimum: 0,
        majorGridLines: MajorGridLines(width: 0.5),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      legend:
          widget.showLegend ? const Legend(isVisible: true) : const Legend(),
      series: <CartesianSeries<ChartDataEntity, DateTime>>[
        ScatterSeries<ChartDataEntity, DateTime>(
          dataSource: widget.data,
          xValueMapper: (ChartDataEntity data, _) => data.timestamp,
          yValueMapper: (ChartDataEntity data, _) => data.value,
          name: 'Scatter Points',
          color: AppTheme.chartColors[3],
          dataLabelSettings: DataLabelSettings(
            isVisible: widget.showDataLabels,
            labelAlignment: ChartDataLabelAlignment.top,
          ),
          animationDuration: widget.enableAnimation ? 1000 : 0,
        ),
      ],
    );
  }
}
