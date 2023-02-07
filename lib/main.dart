import 'package:flutter/material.dart';
import 'package:todo_list/data/database.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final database = MyDatabase();
  TextEditingController titleC = new TextEditingController();
  TextEditingController detailC = new TextEditingController();

  // add to database
  Future insert(String title, String detail) async {
    await database
        .into(database.todos)
        .insert(TodosCompanion.insert(title: title, email: detail));
  }

  // get all data
  Future<List<Todo>> getAll() {
    return database.select(database.todos).get();
  }

  //update data
  Future update(Todo todo, String newTitle, String newDetail) async {
    await database
        .update(database.todos)
        .replace(Todo(id: todo.id, title: newTitle, email: newDetail));
  }

  // delete todo
  Future delete(Todo todo) async {
    await database.delete(database.todos).delete(todo);
  }

  void todoDialog(Todo? todo) {
    if (todo != null) {
      titleC.text = todo.title;
      detailC.text = todo.email;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  todo != null
                      ? Text("Update catatan")
                      : Text("Tambah Catatan"),
                  SizedBox(height: 24),
                  TextFormField(
                    controller: titleC,
                    decoration: InputDecoration(
                      hintText: "Todo",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: detailC,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Detail",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Batal"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (todo != null) {
                              update(todo, titleC.text, detailC.text);
                            } else {
                              insert(titleC.text, detailC.text);
                            }
                          });
                          Navigator.of(context).pop();
                          titleC.clear();
                          detailC.clear();
                        },
                        child: Text("Simpan"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("Todo List"),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Todo>>(
            future: getAll(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: ListTile(
                            onTap: () => todoDialog(snapshot.data?[index]),
                            title: Text(snapshot.data![index].title),
                            subtitle: Text(snapshot.data![index].email),
                            trailing: ElevatedButton(
                              child: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  delete(snapshot.data![index]);
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text("Belum ada data"),
                  );
                }
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          detailC.clear();
          titleC.clear();
          todoDialog(null);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
