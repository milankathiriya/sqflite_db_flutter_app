import 'dart:developer';

import 'package:sqlite_app/models/ie.dart';

import '../../models/category.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper dbHelper = DBHelper._();

  Database? db;

  // initialize db => create db
  Future<void> initDB() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, "rnw.db");

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        String category_table_query =
            "CREATE TABLE IF NOT EXISTS category(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE, image BLOB);";
        await db.execute(category_table_query);

        String ie_table_query =
            "CREATE TABLE IF NOT EXISTS ie(id INTEGER PRIMARY KEY AUTOINCREMENT, desc TEXT NOT NULL, amount REAL NOT NULL, category INTEGER NOT NULL, type TEXT NOT NULL);";

        log(ie_table_query);

        await db.execute(ie_table_query);
      },
    );
  }

  // insert category data
  Future<int> insertCategory({required Category category}) async {
    if (db == null) {
      await initDB();
    }
    String query = "INSERT INTO category(name, image) VALUES(?, ?);";

    List args = [category.name, category.image];

    return await db!.rawInsert(query, args); // returns the inserted record's id
  }

  // select all category data
  Future<List<Category>> fetchAllCategories() async {
    if (db == null) {
      await initDB();
    }

    String query = "SELECT * FROM category;";

    List<Map<String, dynamic>>? data = await db?.rawQuery(query);

    if (data != null) {
      // convert dart object to custom object
      List<Category> allCategories = data
          .map((Map<String, dynamic> e) => Category.fromMap(data: e))
          .toList();

      return allCategories;
    } else {
      return [];
    }
  }

  // update category data
  Future<int?> updateCategory({required Category category}) async {
    if (db == null) {
      await initDB();
    }

    String query = "UPDATE category SET name=?, image=? WHERE id=?;";
    List args = [category.name, category.image, category.id];

    return await db?.rawUpdate(query,
        args); // returns an int with value 1 (total no. of updated records)
  }

  // delete category data
  Future<int?> deleteCategory({required int id}) async {
    if (db == null) {
      await initDB();
    }

    String query = "DELETE FROM category WHERE id=?;";
    List args = [id];

    return await db?.rawDelete(query,
        args); // returns an int with value 1 (total no. of deleted records)
  }

  // search category
  Future<List<Category>> searchCategory({required String data}) async {
    if (db == null) {
      await initDB();
    }

    String query = "SELECT * FROM category WHERE name LIKE '%$data%';";
    List<Map<String, dynamic>>? records = await db?.rawQuery(query);

    if (records != null) {
      List<Category> searchedCategories =
          records.map((e) => Category.fromMap(data: e)).toList();

      return searchedCategories;
    } else {
      return [];
    }
  }

  // insert I/E data
  Future<int> insertIE({required IE ie}) async {
    if (db == null) {
      await initDB();
    }

    String query =
        "INSERT INTO ie(desc, amount, category, type) VALUES(?, ?, ?, ?);";
    List args = [ie.desc, ie.amount, ie.category, ie.type];

    return db!.rawInsert(query, args); // int => inserted record's PK
  }

  // select all I/E data
  Future<List<IE>> fetchAllIE() async {
    if (db == null) {
      await initDB();
    }

    String query = "SELECT * FROM ie;";

    List<Map<String, dynamic>> records = await db!.rawQuery(query);

    List<IE> allIE = records.map((e) => IE.fromMap(data: e)).toList();

    return allIE;
  }

  // select a single category data
  Future<List<Category>> fetchSingleCategory({required int id}) async {
    if (db == null) {
      await initDB();
    }

    String query = "SELECT * FROM category WHERE id=?;";
    List args = [id];

    List<Map<String, dynamic>> records = await db!.rawQuery(query, args);

    List<Category> founded_records =
        records.map((e) => Category.fromMap(data: e)).toList();

    return founded_records;
  }

  // TODO: update I/E data
  // TODO: delete I/E data
}
