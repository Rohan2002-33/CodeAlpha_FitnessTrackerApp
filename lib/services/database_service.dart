import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/activity_entry.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static const _dbName = 'fittrack.db';
  static const _table = 'activities';

  Database? _db;

  Future<Database> get _database async => _db ??= await _open();

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      join(dir, _dbName),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            duration_min INTEGER NOT NULL,
            calories INTEGER NOT NULL,
            steps INTEGER NOT NULL DEFAULT 0,
            date INTEGER NOT NULL,
            note TEXT NOT NULL DEFAULT ''
          )
        ''');
        await db.execute('CREATE INDEX idx_${_table}_date ON $_table(date)');
      },
    );
  }

  Future<List<ActivityEntry>> getAll() async {
    final db = await _database;
    final rows = await db.query(_table, orderBy: 'date DESC, id DESC');
    return rows.map(ActivityEntry.fromMap).toList();
  }

  Future<int> insert(ActivityEntry entry) async {
    final db = await _database;
    return db.insert(
      _table,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(ActivityEntry entry) async {
    final db = await _database;
    return db.update(
      _table,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _database;
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await _database;
    await db.delete(_table);
  }
}
