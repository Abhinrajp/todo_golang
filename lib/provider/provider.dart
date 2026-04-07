import 'package:provider/provider.dart';
import 'package:todo_golang/provider/todo_provider.dart';
import 'package:todo_golang/service/getit_injection.dart';

final providers = [
  ChangeNotifierProvider<TodoProvider>(
    create: (_) => getit<TodoProvider>(),
    lazy: true,
  ),
];
