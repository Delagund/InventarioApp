import 'package:sqflite/sqflite.dart';

abstract class TableSchema {
  Future<void> create(Database db);
}
