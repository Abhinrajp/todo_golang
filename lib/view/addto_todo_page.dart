import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_golang/model/todo_model.dart';
import 'package:todo_golang/provider/todo_provider.dart';

class Addtodoscreen extends StatefulWidget {
  final Todomodel? todo;
  const Addtodoscreen({super.key, required this.todo});

  @override
  State<Addtodoscreen> createState() => _AddtodoscreenState();
}

class _AddtodoscreenState extends State<Addtodoscreen> {
  final TextEditingController titleController = TextEditingController();

  final TextEditingController dateController = TextEditingController();

  final TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widget.todo != null) {
        titleController.text = widget.todo!.title;
        dateController.text = widget.todo!.enddate;
        contentController.text = widget.todo!.content;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.pink[700],
        title: const Text(
          'Add Todo',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 500,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: titleController,
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.pink),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey),
                          ),
                          labelText: 'Title',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        controller: dateController,
                        readOnly: true,
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );

                          if (pickedDate != null) {
                            final formattedDate = DateFormat(
                              'yy/MM/dd',
                            ).format(pickedDate);

                            dateController.text = formattedDate;
                          }
                        },
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.pink),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey),
                          ),
                          labelText: 'Date',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: contentController,
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey),
                    ),
                    labelText: 'Content',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    add(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      Colors.pink.shade700,
                    ),
                    minimumSize: WidgetStateProperty.resolveWith<Size>(
                      (states) => const Size(600, 50),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void add(BuildContext context) async {
    if (titleController.text.isEmpty ||
        dateController.text.isEmpty ||
        contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Fill all the details'),
          backgroundColor: Colors.red[400],
        ),
      );
    } else {
      if (widget.todo != null) {
        final response = await context.read<TodoProvider>().editTodo(
          id: widget.todo!.id.toString(),
          title: titleController.text,
          content: contentController.text,
          endDate: dateController.text,
        );
        log(response);
        if (response == 'todo updated successfully') {
          titleController.clear();
          contentController.clear();
          dateController.clear();
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'Todo updated',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  'Unable to edit todo',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }
        }
      } else {
        final response = await context.read<TodoProvider>().addTodo(
          title: titleController.text,
          content: contentController.text,
          endDate: dateController.text,
        );
        log(response);
        if (response == 'todo added successfully') {
          titleController.clear();
          contentController.clear();
          dateController.clear();
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'Todo added',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  'Unable to add todo',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }
        }
      }
    }
  }
}
