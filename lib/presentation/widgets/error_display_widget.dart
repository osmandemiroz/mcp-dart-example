import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcp_dart_example/core/constants/app_constants.dart'
    hide AppTheme;
import 'package:mcp_dart_example/core/theme/app_theme.dart';
import 'package:mcp_dart_example/domain/entities/mcp_error_entity.dart';

/// Widget for displaying MCP errors with enhanced UI
class ErrorDisplayWidget extends StatelessWidget {
  /// ErrorDisplayWidget constructor
  const ErrorDisplayWidget({
    required this.errors,
    super.key,
    this.onErrorTap,
    this.onResolveError,
    this.showResolvedErrors = false,
  });

  /// List of MCP errors
  final List<MCPErrorEntity> errors;

  /// Function to be called when an error is tapped
  final void Function(MCPErrorEntity)? onErrorTap;

  /// Function to be called when an error is resolved
  final void Function(String)? onResolveError;

  /// Whether to show resolved errors
  final bool showResolvedErrors;

  @override
  Widget build(BuildContext context) {
    final filteredErrors = showResolvedErrors
        ? errors
        : errors.where((error) => !error.isResolved).toList();

    if (filteredErrors.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: AppTheme.statusColors['success'],
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                'No errors detected',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.statusColors['success'],
                    ),
              ),
              Text(
                'Your application is running smoothly!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppTheme.statusColors['error'],
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  'Runtime Errors (${filteredErrors.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (errors.any((e) => e.isResolved))
                  FilterChip(
                    label: Text(
                        showResolvedErrors ? 'Hide Resolved' : 'Show Resolved'),
                    selected: showResolvedErrors,
                    onSelected: (selected) {
                      // This would need to be handled by parent widget
                    },
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredErrors.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final error = filteredErrors[index];
              return _ErrorTile(
                error: error,
                onTap: () => onErrorTap?.call(error),
                onResolve: () => onResolveError?.call(error.id),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({
    required this.error,
    this.onTap,
    this.onResolve,
  });

  final MCPErrorEntity error;
  final VoidCallback? onTap;
  final VoidCallback? onResolve;

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(error.severity);
    final severityIcon = _getSeverityIcon(error.severity);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: severityColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          severityIcon,
          color: severityColor,
          size: 20,
        ),
      ),
      title: Text(
        error.errorType,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: error.isResolved
                  ? Theme.of(context).colorScheme.outline
                  : null,
              decoration: error.isResolved ? TextDecoration.lineThrough : null,
            ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            error.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: error.isResolved
                  ? Theme.of(context).colorScheme.outline
                  : null,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (error.filePath != null) ...[
                Icon(
                  Icons.insert_drive_file,
                  size: 12,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${error.filePath}${error.lineNumber != null ? ':${error.lineNumber}' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: Theme.of(context).colorScheme.outline,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Text(
                DateFormat('HH:mm:ss').format(error.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
          if (error.suggestion != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.statusColors['info']!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 12,
                    color: AppTheme.statusColors['info'],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      error.suggestion!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.statusColors['info'],
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      trailing: error.isResolved
          ? Icon(
              Icons.check_circle,
              color: AppTheme.statusColors['success'],
            )
          : PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'resolve':
                    onResolve?.call();
                  case 'details':
                    onTap?.call();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'resolve',
                  child: Row(
                    children: [
                      Icon(Icons.check),
                      SizedBox(width: 8),
                      Text('Mark as Resolved'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'details',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
              ],
            ),
      onTap: onTap,
    );
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return AppTheme.statusColors['info']!;
      case ErrorSeverity.warning:
        return AppTheme.statusColors['warning']!;
      case ErrorSeverity.error:
        return AppTheme.statusColors['error']!;
      case ErrorSeverity.critical:
        return AppTheme.statusColors['error']!;
    }
  }

  IconData _getSeverityIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info_outline;
      case ErrorSeverity.warning:
        return Icons.warning_amber_outlined;
      case ErrorSeverity.error:
        return Icons.error_outline;
      case ErrorSeverity.critical:
        return Icons.dangerous_outlined;
    }
  }
}
