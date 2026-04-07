import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_golang/model/todo_model.dart';
import 'package:todo_golang/provider/todo_provider.dart';
import 'package:todo_golang/view/detail_page.dart';

class Searchscreen extends StatelessWidget {
  const Searchscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.pink[700]),
      body: Column(
        children: [
          CupertinoTextField(
            padding: const EdgeInsets.fromLTRB(30, 20, 0, 10),
            placeholder: 'Search...',
            placeholderStyle: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
            style: const TextStyle(fontSize: 16, color: Colors.black),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            onChanged: (query) {
              context.read<TodoProvider>().searchTodo(query: query);
            },
          ),
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, value, child) {
                List<Todomodel> searchresult = value.searchlist;
                if (searchresult.isEmpty) {
                  return const Center(child: Text('No tod'));
                } else {
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                    itemBuilder: (context, index) {
                      final todo = searchresult[index];
                      // final todoid = todo.id;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Detailscreen(todoid: todo.id),
                            ),
                          );
                        },
                        child: Card(
                          color: const Color.fromARGB(253, 246, 101, 149),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                todo.enddate,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              ),
                              Text(
                                todo.title,
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(
                                width: 90,
                                child: Text(
                                  todo.content,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: searchresult.length,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
