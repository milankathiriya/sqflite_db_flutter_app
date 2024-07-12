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
        String query =
            "CREATE TABLE IF NOT EXISTS category(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, image BLOB);";
        await db.execute(query);
        print("TABLE IS CREATED....");
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

  // TODO: insert I/E data
  // TODO: select all I/E data
  // TODO: update I/E data
  // TODO: delete I/E data
}

// DBHelper.dbHelper.x = 100;
// DBHelper.dbHelper.disp();
