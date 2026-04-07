import 'dart:convert';

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
      return response;
    } catch (err) {
      debugPrint('Errow while adding todo $err');
      return 'Errow while adding todo $err';
    } finally {
      stopLoading();
    }
  }

  Future<String> deleteTodo({required String id}) async {
    try {
      startLoading();
      final response = await itodoRepo.removeTodo(id: id);
      return response;
    } catch (err) {
      debugPrint('Errow while removeing todo $err');
      return 'Errow while removeing todo $err';
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
      return response;
    } catch (err) {
      debugPrint('Errow while editing todo $err');
      return 'Errow while editing todo $err';
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
            (todo) => todo.enddate.toLowerCase().contains(query.toLowerCase()),
          ),
        );
      }
      notifyListeners();
    } catch (err) {
      debugPrint('Errow while serching todo $err');
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
