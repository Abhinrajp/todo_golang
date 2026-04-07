import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_golang/model/todo_model.dart';
import 'package:todo_golang/provider/todo_provider.dart';

class Detailscreen extends StatelessWidget {
  final int todoid;
  const Detailscreen({super.key, required this.todoid});

  @override
  Widget build(BuildContext context) {
    final Todomodel todo = context.read<TodoProvider>().todos.firstWhere(
      (element) => element.id == todoid,
      orElse: () => Todomodel(title: '', content: '', enddate: '', id: -1),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.pink[700],
        title: const Text(
          'Todo Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 30, 8, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                todo.enddate,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
                maxLines: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  decoration: BoxDecoration(
                    color: Colors.pink[400],
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  height: 400,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Todo ${todo.title}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 30,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        todo.content,
                        maxLines: 10,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w300,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
