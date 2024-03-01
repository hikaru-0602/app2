import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

//テスト
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class DataService {
  final db = FirebaseFirestore.instance;

  Future<void> addMemo(String memo, int count) {
    return db.collection('title').add({
      'title': memo,
      'count': count,
    });
  }

  Stream<QuerySnapshot> getMemos() {
    return db.collection('title').snapshots();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '家の在庫管理アプリ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DataService _dataService = DataService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _countController = TextEditingController();

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 254, 118, 108),
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _titleController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: '検索',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _dataService.getMemos(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  var memos = snapshot.data!.docs.where((memo) {
                    var title = memo.data() as Map<String, dynamic>;
                    return title['title'].toString().contains(_searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: memos.length,
                    itemBuilder: (context, index) {
                      var title = memos[index].data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          leading: Container(
                            width: 40,
                          ),
                          title: Text(
                            '${title['title']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('個数: ${title['count']}'),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Memo'),
          content: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: '名前'),
              ),
              TextField(
                controller: _countController,
                decoration: InputDecoration(labelText: '個数'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                String title = _titleController.text;
                int count = int.tryParse(_countController.text) ?? 0;

                if (title.isNotEmpty && count > 0) {
                  await _dataService.addMemo(title, count);
                  _titleController.clear();
                  _countController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
