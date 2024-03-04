import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  List<Map<String, dynamic>> itemList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('在庫管理システム'),
      ),
      body: Column(
        children: [
          const Text(
            "在庫一覧",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Slidable(
                      key: GlobalKey(),
                      startActionPane: ActionPane(
                          motion: const StretchMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                              label: '削除',
                              backgroundColor: Colors.red,
                              onPressed: (context) {
                                removeData(itemList[index]["item"]);
                              },
                            )
                          ]),
                      child: ListTile(
                          leading: Text(
                            '${itemList[index]["item"]}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          title: Text(
                            '残り:${itemList[index]["quantity"].toString().padLeft(2, '0')}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          tileColor: ColorCheck(index)
                              ? const Color.fromARGB(255, 222, 120, 113)
                              : Colors.white24,
                          trailing: Wrap(
                            children: [
                              IconButton(
                                onPressed: () {
                                  updateQuantity(index, 1);
                                },
                                icon: const Icon(
                                  Icons.add,
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    updateQuantity(index, -1);
                                  },
                                  icon: const Icon(
                                    Icons.remove,
                                  ))
                            ],
                          ))),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('商品を追加'),
          content: SizedBox(
            height: 150,
            child: Column(
              children: [
                TextField(
                  controller: _itemController,
                  decoration: const InputDecoration(labelText: '商品名 8字以内'),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(8),
                  ],
                ),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '個数'),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(2),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _itemController.clear();
                _quantityController.clear();
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                saveData();
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
    _itemController.clear();
    _quantityController.clear();
  }

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String item = _itemController.text;
    int quantity = int.parse(_quantityController.text);

    // キーと値を保存
    prefs.setString(item, quantity.toString());

    // 保存後に入力欄をクリア
    _itemController.clear();
    _quantityController.clear();

    // リストを更新
    loadData();
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 全てのキーを取得
    List<String> keys = prefs.getKeys().toList();

    List<Map<String, dynamic>> updatedList = [];

    for (String key in keys) {
      String item = key;
      int quantity = int.tryParse(prefs.getString(key) ?? '0') ?? 0;
      updatedList.add({"item": item, "quantity": quantity});
    }

    setState(() {
      // リストを更新
      itemList = updatedList;
    });
  }

  Future<void> resetData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      saveData();
      loadData();
    });
  }

  Future<void> removeData(String item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(item);
    setState(() {
      saveData();
      loadData();
    });
  }

  void updateQuantity(int index, int delta) {
    setState(() {
      // 現在の数量
      int currentQuantity = itemList[index]["quantity"];

      // 新しい数量
      int newQuantity = currentQuantity + delta;

      // 数量が0未満にならないように調整
      newQuantity = newQuantity < 0 ? 0 : newQuantity;

      // 更新した数量を保存
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString(itemList[index]["item"], newQuantity.toString());
      });

      // リストを更新
      loadData();
    });
  }

  // ignore: non_constant_identifier_names
  bool ColorCheck(int index) {
    int currentQuantity = itemList[index]["quantity"];
    if (currentQuantity == 0) {
      return true;
    } else {
      return false;
    }
  }
}
