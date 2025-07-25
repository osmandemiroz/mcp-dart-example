import 'dart:async';

import 'package:mcp_dart_example/core/constants/app_constants.dart';
import 'package:mcp_dart_example/data/models/chart_data_model.dart';
import 'package:mcp_dart_example/domain/entities/mcp_error_entity.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Database service for local data persistence
class DatabaseService {
  /// DatabaseService constructor
  factory DatabaseService() {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }
  DatabaseService._internal();
  static DatabaseService? _instance;
  static Database? _database;

  /// Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chart_data (
        id TEXT PRIMARY KEY,
        timestamp INTEGER NOT NULL,
        value REAL NOT NULL,
        label TEXT NOT NULL,
        category TEXT,
        metadata TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE mcp_errors (
        id TEXT PRIMARY KEY,
        timestamp INTEGER NOT NULL,
        error_type TEXT NOT NULL,
        message TEXT NOT NULL,
        severity TEXT NOT NULL,
        stack_trace TEXT,
        file_path TEXT,
        line_number INTEGER,
        column_number INTEGER,
        suggestion TEXT,
        is_resolved INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute(
        'CREATE INDEX idx_chart_data_timestamp ON chart_data(timestamp)');
    await db.execute(
        'CREATE INDEX idx_mcp_errors_timestamp ON mcp_errors(timestamp)');
    await db.execute(
        'CREATE INDEX idx_mcp_errors_severity ON mcp_errors(severity)');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database schema changes
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  /// Chart Data Operations

  /// Insert chart data
  Future<void> insertChartData(ChartDataModel data) async {
    final db = await database;
    await db.insert(
      'chart_data',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all chart data
  Future<List<ChartDataModel>> getChartData({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    var whereClause = '';
    var whereArgs = <dynamic>[];

    if (startDate != null && endDate != null) {
      whereClause = 'WHERE timestamp BETWEEN ? AND ?';
      whereArgs = [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ];
    }

    final query = '''
      SELECT * FROM chart_data 
      $whereClause 
      ORDER BY timestamp DESC 
      ${limit != null ? 'LIMIT $limit' : ''}
    ''';

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, whereArgs);

    return List.generate(maps.length, (i) {
      return ChartDataModel.fromMap(maps[i]);
    });
  }

  /// Delete old chart data
  Future<void> deleteOldChartData(int maxCount) async {
    final db = await database;

    // Get count of records
    final countResult =
        await db.rawQuery('SELECT COUNT(*) as count FROM chart_data');
    final count = countResult.first['count']! as int;

    if (count > maxCount) {
      // Delete oldest records
      await db.rawDelete('''
        DELETE FROM chart_data 
        WHERE id IN (
          SELECT id FROM chart_data 
          ORDER BY timestamp ASC 
          LIMIT ?
        )
      ''', [count - maxCount]);
    }
  }

  /// MCP Error Operations

  /// Insert MCP error
  Future<void> insertMCPError(MCPErrorEntity error) async {
    final db = await database;
    await db.insert(
      'mcp_errors',
      {
        'id': error.id,
        'timestamp': error.timestamp.millisecondsSinceEpoch,
        'error_type': error.errorType,
        'message': error.message,
        'severity': error.severity.name,
        'stack_trace': error.stackTrace,
        'file_path': error.filePath,
        'line_number': error.lineNumber,
        'column_number': error.columnNumber,
        'suggestion': error.suggestion,
        'is_resolved': error.isResolved ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get MCP errors
  Future<List<MCPErrorEntity>> getMCPErrors({
    int? limit,
    ErrorSeverity? severity,
    bool? isResolved,
  }) async {
    final db = await database;

    var whereClause = '';
    final whereArgs = <dynamic>[];

    final conditions = <String>[];

    if (severity != null) {
      conditions.add('severity = ?');
      whereArgs.add(severity.name);
    }

    if (isResolved != null) {
      conditions.add('is_resolved = ?');
      whereArgs.add(isResolved ? 1 : 0);
    }

    if (conditions.isNotEmpty) {
      whereClause = 'WHERE ${conditions.join(' AND ')}';
    }

    final query = '''
      SELECT * FROM mcp_errors 
      $whereClause 
      ORDER BY timestamp DESC 
      ${limit != null ? 'LIMIT $limit' : ''}
    ''';

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, whereArgs);

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return MCPErrorEntity(
        id: map['id'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        errorType: map['error_type'] as String,
        message: map['message'] as String,
        severity: ErrorSeverity.values.firstWhere(
          (e) => e.name == map['severity'],
          orElse: () => ErrorSeverity.error,
        ),
        stackTrace: map['stack_trace'] as String?,
        filePath: map['file_path'] as String?,
        lineNumber: map['line_number'] as int?,
        columnNumber: map['column_number'] as int?,
        suggestion: map['suggestion'] as String?,
        isResolved: (map['is_resolved'] as int) == 1,
      );
    });
  }

  /// Update error resolution status
  Future<void> updateErrorResolution(String errorId,
      {required bool isResolved}) async {
    final db = await database;
    await db.update(
      'mcp_errors',
      {'is_resolved': isResolved ? 1 : 0},
      where: 'id = ?',
      whereArgs: [errorId],
    );
  }

  /// Settings Operations

  /// Save setting
  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get setting
  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }

  /// Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('chart_data');
    await db.delete('mcp_errors');
    await db.delete('app_settings');
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
