import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:todo_golang/model/todo_model.dart';
import 'package:todo_golang/repo/todo_repo.dart';

@lazySingleton
class TodoProvider extends ChangeNotifier {
  ItodoRepo itodoRepo;
  TodoProvider(this.itodoRepo);
  bool loading = false;
  List<Todomodel> todos = [];
  List<Todomodel> searchlist = [];

  Future<void> fetchTodo() async {
    try {
      todos.clear();
      startLoading();
      final response = await itodoRepo.fetchTodo();
      final data = jsonDecode(response);
      if (data is List<dynamic>) {
        todos = data.map((e) => Todomodel.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (err) {
      debugPrint('Errow while fetching todo');
    } finally {
      stopLoading();
    }
  }

  Future<String> addTodo({
    required String title,
    required String content,
    required String endDate,
  }) async {
    try {
      startLoading();
      final response = await itodoRepo.addingTodo(
        title: title,
        content: content,
        endDate: endDate,
      );
      log('RAW RESPONSE: $response');
      final data = await json.decode(response);
      if (data['message'] == 'todo added successfully') {
        await fetchTodo();
        notifyListeners();
      }
      log(data['message']);
      return data['message'];
    } catch (err) {
      debugPrint('Errow while adding todo $err');
      return 'error';
    } finally {
      stopLoading();
    }
  }

  Future<String> deleteTodo({required Todomodel todo}) async {
    try {
      startLoading();
      final response = await itodoRepo.removeTodo(id: todo.id.toString());
      final data = json.decode(response);
      if (data['message'] == 'todo deleted successfully') {
        todos.remove(todo);
        notifyListeners();
      }
      log(data['message']);
      return data['message'];
    } catch (err) {
      debugPrint('Errow while removeing todo $err');
      return 'error';
    } finally {
      stopLoading();
    }
  }

  Future<String> editTodo({
    required String id,
    required String title,
    required String content,
    required String endDate,
  }) async {
    try {
      startLoading();
      final response = await itodoRepo.editTodo(
        id: id,
        title: title,
        content: content,
        endDate: endDate,
      );
      final data = json.decode(response);
      if (data['message'] == 'todo updated successfully') {
        todos.removeWhere((e) => e.id == int.parse(id));
        todos.add(
          Todomodel(
            id: int.parse(id),
            title: title,
            content: content,
            enddate: endDate,
          ),
        );
        notifyListeners();
      }
      log(data['message']);
      return data['message'];
    } catch (err) {
      debugPrint('Errow while editing todo $err');
      return 'error';
    } finally {
      stopLoading();
    }
  }

  Future<void> searchTodo({required String query}) async {
    try {
      startLoading();
      searchlist.clear();
      if (query.isEmpty) {
        searchlist.addAll(todos);
      } else {
        searchlist.addAll(
          todos.where(
            (todo) =>
                todo.title.toLowerCase().contains(query.toLowerCase()) ||
                todo.content.toLowerCase().contains(query.toLowerCase()) ||
                todo.enddate.toLowerCase().contains(query.toLowerCase()),
          ),
        );
      }
      notifyListeners();
    } catch (err) {
      debugPrint('Error while searching todo $err');
    } finally {
      stopLoading();
    }
  }

  void startLoading() {
    loading = true;
    notifyListeners();
  }

  void stopLoading() {
    loading = false;
    notifyListeners();
  }
}
