import 'package:equatable/equatable.dart';

/// Entity representing MCP server errors
class MCPErrorEntity extends Equatable {
  /// MCPErrorEntity constructor
  const MCPErrorEntity({
    required this.id,
    required this.timestamp,
    required this.errorType,
    required this.message,
    required this.severity,
    this.stackTrace,
    this.filePath,
    this.lineNumber,
    this.columnNumber,
    this.suggestion,
    this.isResolved = false,
  });

  /// MCPErrorEntity id
  final String id;

  /// MCPErrorEntity timestamp
  final DateTime timestamp;

  /// MCPErrorEntity error type
  final String errorType;

  /// MCPErrorEntity message
  final String message;

  /// MCPErrorEntity severity
  final ErrorSeverity severity;

  /// MCPErrorEntity stack trace
  final String? stackTrace;

  /// MCPErrorEntity file path
  final String? filePath;

  /// MCPErrorEntity line number
  final int? lineNumber;

  /// MCPErrorEntity column number
  final int? columnNumber;

  /// MCPErrorEntity suggestion
  final String? suggestion;

  /// MCPErrorEntity is resolved
  final bool isResolved;

  @override
  List<Object?> get props => [
        id,
        timestamp,
        errorType,
        message,
        severity,
        stackTrace,
        filePath,
        lineNumber,
        columnNumber,
        suggestion,
        isResolved,
      ];

  /// MCPErrorEntity copy with
  MCPErrorEntity copyWith({
    String? id,
    DateTime? timestamp,
    String? errorType,
    String? message,
    ErrorSeverity? severity,
    String? stackTrace,
    String? filePath,
    int? lineNumber,
    int? columnNumber,
    String? suggestion,
    bool? isResolved,
  }) {
    return MCPErrorEntity(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      errorType: errorType ?? this.errorType,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      stackTrace: stackTrace ?? this.stackTrace,
      filePath: filePath ?? this.filePath,
      lineNumber: lineNumber ?? this.lineNumber,
      columnNumber: columnNumber ?? this.columnNumber,
      suggestion: suggestion ?? this.suggestion,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}

/// Error severity levels
enum ErrorSeverity {
  /// ErrorSeverity info
  info('Info'),

  /// ErrorSeverity warning
  warning('Warning'),

  /// ErrorSeverity error
  error('Error'),

  /// ErrorSeverity critical
  critical('Critical');

  const ErrorSeverity(this.displayName);

  /// ErrorSeverity display name
  final String displayName;
}
