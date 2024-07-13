import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqlite_app/models/category.dart';
import 'package:sqlite_app/utils/helpers/db_helper.dart';

class CategoryComponent extends StatefulWidget {
  const CategoryComponent({super.key});

  @override
  State<CategoryComponent> createState() => _CategoryComponentState();
}

class _CategoryComponentState extends State<CategoryComponent> {
  final GlobalKey<FormState> insertCategoryFormKey = GlobalKey<FormState>();

  final TextEditingController categoryNameController = TextEditingController();

  ImagePicker imagePicker = ImagePicker();

  File? imageFile;

  late Future<List<Category>> getCategories;

  @override
  void initState() {
    super.initState();
    getCategories = DBHelper.dbHelper.fetchAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                label: const Text("Add Category"),
                icon: const Icon(Icons.add),
                onPressed: () async {
                  validateAndInsertCategory();
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 2,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Search by name...",
                ),
                onChanged: (val) async {
                  setState(() {
                    getCategories = DBHelper.dbHelper.searchCategory(data: val);
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 14,
              child: FutureBuilder(
                future: getCategories,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("ERROR: ${snapshot.error}"),
                    );
                  } else if (snapshot.hasData) {
                    List<Category>? data = snapshot.data;

                    return (data == null || data.isEmpty)
                        ? Center(
                            child: Text("No data available..."),
                          )
                        : ListView.separated(
                            itemCount: data.length,
                            separatorBuilder: (context, i) {
                              return SizedBox(height: 20);
                            },
                            itemBuilder: (context, i) {
                              return ListTile(
                                leading: (data[i].image == null)
                                    ? CircleAvatar(
                                        radius: 30,
                                      )
                                    : CircleAvatar(
                                        radius: 30,
                                        backgroundImage: (data[i].image == null)
                                            ? null
                                            : MemoryImage(
                                                data[i].image as Uint8List),
                                      ),
                                title: Text("${data[i].name}"),
                                trailing: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () async {
                                        Category c1 = Category(
                                            name: "Cloths", id: data[i].id);

                                        int? id = await DBHelper.dbHelper
                                            .updateCategory(category: c1);

                                        if (id == 1) {
                                          setState(() {
                                            getCategories = DBHelper.dbHelper
                                                .fetchAllCategories();
                                          });

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Category is updated successfully..."),
                                              backgroundColor: Colors.green,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Category updation failed..."),
                                              backgroundColor: Colors.redAccent,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () async {
                                        int? id = await DBHelper.dbHelper
                                            .deleteCategory(id: data[i].id!);

                                        if (id == 1) {
                                          setState(() {
                                            getCategories = DBHelper.dbHelper
                                                .fetchAllCategories();
                                          });

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Category is deleted successfully..."),
                                              backgroundColor: Colors.green,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Category deletion failed..."),
                                              backgroundColor: Colors.redAccent,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void validateAndInsertCategory() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Center(
              child: Text("Add Category"),
            ),
            content: Form(
              key: insertCategoryFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Choose Image"),
                  GestureDetector(
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage:
                          (imageFile == null) ? null : FileImage(imageFile!),
                    ),
                    onTap: () async {
                      XFile? xFile = await imagePicker.pickImage(
                          source: ImageSource.camera);

                      if (xFile != null) {
                        setState(() {
                          imageFile = File(xFile.path);
                        });
                      }
                    },
                  ),
                  TextFormField(
                    controller: categoryNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter category name here...",
                      labelText: "Category Name",
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              OutlinedButton(
                child: const Text("Add"),
                onPressed: () async {
                  Category category = Category(
                    name: categoryNameController.text,
                    image: imageFile?.readAsBytesSync(),
                  );

                  int id = await DBHelper.dbHelper
                      .insertCategory(category: category);

                  if (id > 0) {
                    setState(() {
                      getCategories = DBHelper.dbHelper.fetchAllCategories();
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Category is added successfully..."),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Category insertion failed..."),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }

                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
