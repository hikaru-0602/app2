import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
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
        actions: [
          IconButton(
              onPressed: () {
                resetData();
              },
              icon: const Icon(Icons.abc))
        ],
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
                    child: ListTile(
                        leading: Text(
                          '${itemList[index]["item"]}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        //title: Text('商品名: ${itemList[index]["item"]}'),
                        title: Text(
                          '${itemList[index]["quantity"]}個',
                          textAlign: TextAlign.right,
                        ),
                        trailing: Column(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.expand_less,
                                size: 16,
                              ),
                              iconSize: 20,
                            ),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.expand_more,
                                  size: 16,
                                ))
                          ],
                        )));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('商品を追加'),
          content: Column(
            children: [
              TextField(
                controller: _itemController,
                decoration: InputDecoration(labelText: '商品名'),
              ),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '個数'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _itemController.clear();
                _quantityController.clear();
              },
              child: Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                saveData();
                Navigator.pop(context);
              },
              child: Text('保存'),
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
}
