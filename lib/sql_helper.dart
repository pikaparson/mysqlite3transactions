import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'dart:ffi';
//создание таблицы
//class SQLHelper {
 // static Future<void> createTables(sql.Database database) async {
 //  await database.execute("""CREATE TABLE items(
  //      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  //title TEXT,
  //      description TEXT,
  //      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
  //    )
   //   """);
 //final db = sqlite3.open('DataBase/family_budget_rosneft.db');
//}
// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  //создание конкретной таблицы
 // static Future<sql.Database> db() async {
 //   return sql.openDatabase(
     // 'kindacode.db',
     // version: 1,
    //  onCreate: (sql.Database database, int version) async {
     //   await createTables(database);
  //    },
 //   );
 // }

  Future<int> createItem(String name, String profit) async {
    // Создание нового объекта (journal) --- было STATIC
   // final db = await SQLHelper.db();
    var profitInt = int.parse(profit);
    assert(profitInt is int);
    final db = await sqlite3.open('DataBase/family_budget_rosneft.db');
    db.select("INSERT INTO types (name, profit) VALUES ($name, $profitInt)");
    final ResultSet resultSet = db.select("SELECT ID as ID FROM types WHERE name = '$name'");
    late int id;
    for (final Row row in resultSet) {
      id = row['ID'];
    }
    db.dispose();
    return id;
  }

  // чтение всех объектов (journals) --- было STATIC
  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await sqlite3.open('DataBase/family_budget_rosneft.db');
    final d = await db.select("SELECT * FROM types"); // ORDER BY ID
    db.dispose();
    return d;
    //query('types', orderBy: "ID");
  }

  // чтение одного объекта по идентификатору --- было STATIC
  // Приложение не использует этот метод, но он здесь на всякий случай
  Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await sqlite3.open('DataBase/family_budget_rosneft.db');
    final d = await db.select("SELECT ID as ID, name as name, profit as profit FROM types WHERE ID = '$id'");
    db.dispose();
    return d;
    //final db = await SQLHelper.db();
   // return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Обновление объекта по идентификатору --- было STATIC
   Future<void> updateItem(int id, String name, String profit) async {
    //final db = await SQLHelper.db();
     var profitInt = int.parse(profit);
     assert(profitInt is int);
    final db = await sqlite3.open('DataBase/family_budget_rosneft.db');
    await db.select(" UPDATE types SET name = $name, profit = $profitInt WHERE ID = $id");
     db.dispose();
  }

  // Удаление объекта
  Future<void> deleteItem(int id) async {
    final db = sqlite3.open('DataBase/family_budget_rosneft.db');
    try {
      await db.select("DELETE FROM types WHERE ID = id");
      db.dispose();
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
      db.dispose();
    }
  }

