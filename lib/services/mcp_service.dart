import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:mcp_dart_example/core/constants/app_constants.dart';
import 'package:mcp_dart_example/domain/entities/mcp_error_entity.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Service for communicating with MCP server
class MCPService {
  /// MCPService constructor
  factory MCPService() {
    _instance ??= MCPService._internal();
    return _instance!;
  }

  MCPService._internal();
  static MCPService? _instance;
  WebSocketChannel? _channel;
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  // Connection state
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  // Stream controllers
  final StreamController<MCPConnectionState> _connectionStateController =
      StreamController<MCPConnectionState>.broadcast();
  final StreamController<MCPErrorEntity> _errorController =
      StreamController<MCPErrorEntity>.broadcast();
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of connection state
  Stream<MCPConnectionState> get connectionState =>
      _connectionStateController.stream;

  /// Stream of errors
  Stream<MCPErrorEntity> get errors => _errorController.stream;

  /// Stream of messages
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  /// Whether the service is connected to the MCP server
  bool get isConnected => _isConnected;

  /// Connect to MCP server
  Future<void> connect({String? serverUrl}) async {
    final url = serverUrl ?? AppConstants.mcpServerUrl;

    try {
      _logger.i('Connecting to MCP server: $url');
      _connectionStateController.add(MCPConnectionState.connecting);

      _channel = WebSocketChannel.connect(Uri.parse(url));

      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      // Wait for connection confirmation or timeout

      await Future<void>.delayed(const Duration(seconds: 2));

      if (_channel != null) {
        _isConnected = true;
        _reconnectAttempts = 0;
        _connectionStateController.add(MCPConnectionState.connected);
        _startHeartbeat();
        _logger.i('Connected to MCP server successfully');
      }
    } on Exception catch (e) {
      _logger.e('Failed to connect to MCP server: $e');
      _handleConnectionError(e);
    }
  }

  /// Disconnect from MCP server
  Future<void> disconnect() async {
    _logger.i('Disconnecting from MCP server');

    _isConnected = false;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();

    await _channel?.sink.close();
    _channel = null;

    _connectionStateController.add(MCPConnectionState.disconnected);
  }

  /// Send message to MCP server
  Future<Map<String, dynamic>?> sendMessage(
      Map<String, dynamic> message) async {
    if (!_isConnected || _channel == null) {
      throw Exception('Not connected to MCP server');
    }

    try {
      final messageId = _uuid.v4();
      final messageWithId = {
        'id': messageId,
        'timestamp': DateTime.now().toIso8601String(),
        ...message,
      };

      _logger.d('Sending message: $messageWithId');
      _channel!.sink.add(jsonEncode(messageWithId));

      // For now, return null. In a real implementation, you'd wait for response
      return null;
    } catch (e) {
      _logger.e('Failed to send message: $e');
      _addError(MCPErrorEntity(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        errorType: 'MessageSendError',
        message: 'Failed to send message: $e',
        severity: ErrorSeverity.error,
      ));
      rethrow;
    }
  }

  /// Search packages on pub.dev
  Future<List<Map<String, dynamic>>> searchPackages(String query) async {
    try {
      final message = {
        'tool': MCPTool.pubDevSearch.toolName,
        'action': 'search',
        'query': query,
      };

      await sendMessage(message);

      // Mock response for demo purposes
      await Future<void>.delayed(const Duration(seconds: 1));

      return [
        {
          'name': 'http',
          'description':
              'A composable, multi-platform, Future-based API for HTTP requests.',
          'version': '1.2.2',
          'popularity': 98,
        },
        {
          'name': 'dio',
          'description':
              'A powerful HTTP client for Dart/Flutter with interceptors, request/response transformation.',
          'version': '5.4.0',
          'popularity': 95,
        },
      ];
    } catch (e) {
      _logger.e('Failed to search packages: $e');
      rethrow;
    }
  }

  /// Get runtime errors
  Future<List<MCPErrorEntity>> getRuntimeErrors() async {
    try {
      final message = {
        'tool': MCPTool.errorInspector.toolName,
        'action': 'get_errors',
      };

      await sendMessage(message);

      // Mock response for demo purposes
      await Future<void>.delayed(const Duration(milliseconds: 500));

      return [
        MCPErrorEntity(
          id: _uuid.v4(),
          timestamp: DateTime.now(),
          errorType: 'RenderFlex',
          message: 'RenderFlex overflowed by 42 pixels on the right.',
          severity: ErrorSeverity.warning,
          filePath: 'lib/main.dart',
          lineNumber: 123,
          suggestion: 'Consider using Flexible or Expanded widgets.',
        ),
      ];
    } catch (e) {
      _logger.e('Failed to get runtime errors: $e');
      rethrow;
    }
  }

  /// Trigger hot reload
  Future<void> triggerHotReload() async {
    try {
      final message = {
        'tool': MCPTool.hotReload.toolName,
        'action': 'reload',
      };

      await sendMessage(message);
      _logger.i('Hot reload triggered');
    } catch (e) {
      _logger.e('Failed to trigger hot reload: $e');
      rethrow;
    }
  }

  /// Inspect widget tree
  Future<Map<String, dynamic>> inspectWidgetTree() async {
    try {
      final message = {
        'tool': MCPTool.widgetInspector.toolName,
        'action': 'inspect',
      };

      await sendMessage(message);

      // Mock response for demo purposes
      await Future<void>.delayed(const Duration(milliseconds: 800));

      return {
        'root': 'MaterialApp',
        'children': <Map<String, dynamic>>[
          {
            'widget': 'Scaffold',
            'children': <Map<String, dynamic>>[
              {
                'widget': 'AppBar',
                'properties': {'title': 'MCP Dart Pro'}
              },
              {
                'widget': 'SingleChildScrollView',
                'children': <Map<String, dynamic>>[]
              },
            ],
          },
        ],
      };
    } catch (e) {
      _logger.e('Failed to inspect widget tree: $e');
      rethrow;
    }
  }

  /// Handle incoming messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      _logger.d('Received message: $data');
      _messageController.add(data);
    } on Exception catch (e) {
      _logger.e('Failed to parse message: $e');
    }
  }

  /// Handle connection errors
  void _handleError(dynamic error) {
    _logger.e('WebSocket error: $error');
    _handleConnectionError(error);
  }

  /// Handle disconnection
  void _handleDisconnection() {
    _logger.w('WebSocket disconnected');
    _isConnected = false;
    _connectionStateController.add(MCPConnectionState.disconnected);
    _attemptReconnect();
  }

  /// Handle connection errors
  void _handleConnectionError(dynamic error) {
    _isConnected = false;
    _connectionStateController.add(MCPConnectionState.error);

    _addError(MCPErrorEntity(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      errorType: 'ConnectionError',
      message: 'MCP server connection error: $error',
      severity: ErrorSeverity.error,
    ));

    _attemptReconnect();
  }

  /// Attempt to reconnect
  void _attemptReconnect() {
    if (_reconnectAttempts >= AppConstants.maxReconnectAttempts) {
      _logger.e('Max reconnection attempts reached');
      _connectionStateController.add(MCPConnectionState.failed);
      return;
    }

    _reconnectAttempts++;
    _logger.i(
        'Attempting to reconnect ($_reconnectAttempts/${AppConstants.maxReconnectAttempts})');

    _reconnectTimer = Timer(AppConstants.reconnectDelay, connect);
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'type': 'ping'}));
        } on Exception catch (e) {
          _logger.e('Heartbeat failed: $e');
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  /// Add error to stream
  void _addError(MCPErrorEntity error) {
    _errorController.add(error);
  }

  /// Dispose resources
  void dispose() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _connectionStateController.close();
    _errorController.close();
    _messageController.close();
    disconnect();
  }
}

/// MCP connection states
enum MCPConnectionState {
  /// MCP is not connected to the server
  disconnected,

  /// MCP is connecting to the server
  connecting,

  /// MCP is connected to the server
  connected,

  /// MCP connection failed
  error,

  /// MCP connection failed permanently
  failed,
}
