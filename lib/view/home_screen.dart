import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_golang/provider/todo_provider.dart';
import 'package:todo_golang/view/addto_todo_page.dart';
import 'package:todo_golang/view/detail_page.dart';
import 'package:todo_golang/view/search_todo_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Runs after first frame — safe, no BuildContext issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TodoProvider>().fetchTodo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Todo',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.pink[700],
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Searchscreen()),
              );
            },
            icon: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, value, _) {
          // Show loading spinner while fetching
          if (value.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.pink),
            );
          }

          if (value.todos.isEmpty) {
            return const Center(child: Text('No todos yet'));
          }

          return RefreshIndicator(
            // Pull-to-refresh for live updates
            onRefresh: () => context.read<TodoProvider>().fetchTodo(),
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: value.todos.length,
              itemBuilder: (context, index) {
                final todo = value.todos[index];
                return GestureDetector(
                  onLongPress: () => _showDeleteDialog(context, value, todo),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Detailscreen(todoid: todo.id),
                    ),
                  ),
                  child: Card(
                    color: const Color.fromARGB(253, 246, 101, 149),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
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
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            todo.content,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black26,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                child: Icon(Icons.edit, color: Colors.white),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    value.deleteTodo(id: todo.id.toString()),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () async {
          // Await navigation, then refresh when returning from AddTodo
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Addtodoscreen()),
          );
          // Re-fetch after adding so list is always live
          if (mounted) context.read<TodoProvider>().fetchTodo();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TodoProvider value, todo) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Are you sure?'),
          content: const Text('Do you want to delete the todo?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await value.deleteTodo(id: todo.id.toString());
                // Re-fetch after delete to sync with server
                if (context.mounted) context.read<TodoProvider>().fetchTodo();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}
