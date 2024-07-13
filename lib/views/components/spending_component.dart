import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqlite_app/models/category.dart';
import 'package:sqlite_app/models/ie.dart';
import 'package:sqlite_app/utils/helpers/db_helper.dart';

class SpendingComponent extends StatefulWidget {
  const SpendingComponent({super.key});

  @override
  State<SpendingComponent> createState() => _SpendingComponentState();
}

class _SpendingComponentState extends State<SpendingComponent> {
  final GlobalKey<FormState> insertIEFormKey = GlobalKey<FormState>();
  final TextEditingController ieDescController = TextEditingController();
  final TextEditingController ieAmountController = TextEditingController();

  late Future<List<IE>> getIE;

  String? radio_ie;
  int? dropdown_selected_category;

  @override
  void initState() {
    super.initState();
    getIE = DBHelper.dbHelper.fetchAllIE();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton.icon(
                  label: const Text("Add I/E"),
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    validateAndInsertIE();
                  },
                ),
                FutureBuilder(
                    future: DBHelper.dbHelper.fetchAllCategories(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text("ERROR: ${snapshot.error}"),
                        );
                      } else if (snapshot.hasData) {
                        List<Category>? data = snapshot.data;

                        return (data == null || data.isEmpty)
                            ? const Center(
                                child: Text("No any categories..."),
                              )
                            : DropdownButton<int>(
                                value: dropdown_selected_category,
                                hint: const Text("Choose Category"),
                                items: data
                                    .map((e) => DropdownMenuItem(
                                          child: Text(e.name),
                                          value: e.id,
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    dropdown_selected_category = val;
                                  });
                                },
                              );
                      }

                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }),
                OutlinedButton(
                  child: const Text("Add"),
                  onPressed: () async {
                    IE income_expense = IE(
                      desc: ieDescController.text,
                      amount: double.parse(ieAmountController.text),
                      category: dropdown_selected_category!,
                      type: radio_ie!,
                    );

                    int id =
                        await DBHelper.dbHelper.insertIE(ie: income_expense);

                    if (id > 0) {
                      setState(() {
                        getIE = DBHelper.dbHelper.fetchAllIE();
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Income/Expense is added successfully..."),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Income/Expense insertion failed..."),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 2,
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Search by name...",
                ),
                onChanged: (val) async {
                  setState(() {
                    // getIE = DBHelper.dbHelper.searchCategory(data: val);
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 14,
              child: FutureBuilder(
                future: getIE,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("ERROR: ${snapshot.error}"),
                    );
                  } else if (snapshot.hasData) {
                    List<IE>? data = snapshot.data;

                    return (data == null || data.isEmpty)
                        ? const Center(
                            child: Text("No data available..."),
                          )
                        : ListView.separated(
                            itemCount: data.length,
                            separatorBuilder: (context, i) {
                              return const SizedBox(height: 20);
                            },
                            itemBuilder: (context, i) {
                              return ListTile(
                                leading: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: FutureBuilder(
                                    future: DBHelper.dbHelper
                                        .fetchSingleCategory(
                                            id: data[i].category),
                                    builder: (context, ss) {
                                      if (ss.hasError) {
                                        return Center(
                                          child: Text("ERROR: ${ss.error}"),
                                        );
                                      } else if (ss.hasData) {
                                        List<Category>? data_one = ss.data;

                                        return (data_one == null ||
                                                data_one.isEmpty)
                                            ? const Center(
                                                child: Text(
                                                    "No Category found..."),
                                              )
                                            : ListView.builder(
                                                itemCount: data_one.length,
                                                itemBuilder: (context, i) {
                                                  return Text(
                                                      "${data_one[i].name}");
                                                },
                                              );
                                      }

                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  ),
                                ),
                                title: Text("${data[i].desc}"),
                                subtitle: Text(
                                  "Rs. ${data[i].amount}\n${data[i].type}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: (data[i].type == "INCOME")
                                          ? Colors.green
                                          : Colors.red),
                                ),
                                isThreeLine: true,
                                trailing: const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // IconButton(
                                    //   icon: Icon(
                                    //     Icons.edit,
                                    //     color: Colors.blue,
                                    //   ),
                                    //   onPressed: () async {
                                    //
                                    //    // TODO: Replace category with IE
                                    //     // Category c1 = Category(
                                    //     //     name: "Cloths", id: data[i].id);
                                    //     //
                                    //     // int? id = await DBHelper.dbHelper
                                    //     //     .updateCategory(category: c1);
                                    //
                                    //     if (id == 1) {
                                    //       setState(() {
                                    //         getIE = DBHelper.dbHelper
                                    //             .fetchAllIE();
                                    //       });
                                    //
                                    //       ScaffoldMessenger.of(context)
                                    //           .showSnackBar(
                                    //         const SnackBar(
                                    //           content: Text(
                                    //               "IE is updated successfully..."),
                                    //           backgroundColor: Colors.green,
                                    //           behavior:
                                    //               SnackBarBehavior.floating,
                                    //         ),
                                    //       );
                                    //     } else {
                                    //       ScaffoldMessenger.of(context)
                                    //           .showSnackBar(
                                    //         const SnackBar(
                                    //           content: Text(
                                    //               "IE updation failed..."),
                                    //           backgroundColor: Colors.redAccent,
                                    //           behavior:
                                    //               SnackBarBehavior.floating,
                                    //         ),
                                    //       );
                                    //     }
                                    //   },
                                    // ),
                                    // IconButton(
                                    //   icon: Icon(
                                    //     Icons.delete,
                                    //     color: Colors.redAccent,
                                    //   ),
                                    //   onPressed: () async {
                                    //     int? id = await DBHelper.dbHelper
                                    //         .deleteCategory(id: data[i].id!);
                                    //
                                    //     if (id == 1) {
                                    //       setState(() {
                                    //         getCategories = DBHelper.dbHelper
                                    //             .fetchAllCategories();
                                    //       });
                                    //
                                    //       ScaffoldMessenger.of(context)
                                    //           .showSnackBar(
                                    //         const SnackBar(
                                    //           content: Text(
                                    //               "Category is deleted successfully..."),
                                    //           backgroundColor: Colors.green,
                                    //           behavior:
                                    //               SnackBarBehavior.floating,
                                    //         ),
                                    //       );
                                    //     } else {
                                    //       ScaffoldMessenger.of(context)
                                    //           .showSnackBar(
                                    //         const SnackBar(
                                    //           content: Text(
                                    //               "Category deletion failed..."),
                                    //           backgroundColor: Colors.redAccent,
                                    //           behavior:
                                    //               SnackBarBehavior.floating,
                                    //         ),
                                    //       );
                                    //     }
                                    //   },
                                    // ),
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

  void validateAndInsertIE() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Center(
              child: Text("Add Income/Expense"),
            ),
            content: Form(
              key: insertIEFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: ieDescController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter desc here...",
                      labelText: "Description",
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: ieAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter amount here...",
                      labelText: "Amount",
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Radio(
                      value: "EXPENSE",
                      groupValue: radio_ie,
                      onChanged: (val) {
                        setState(() {
                          radio_ie = val;
                        });
                      },
                    ),
                    const Text("Expense"),
                    Radio(
                      value: "INCOME",
                      groupValue: radio_ie,
                      onChanged: (val) {
                        setState(() {
                          radio_ie = val;
                        });
                      },
                    ),
                    const Text("Income"),
                  ]),
                  const SizedBox(height: 10),
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
            ],
          );
        });
  }
}
