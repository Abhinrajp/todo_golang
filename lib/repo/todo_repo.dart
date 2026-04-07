import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;

abstract class ItodoRepo {
  Future<String> addingTodo({
    required String title,
    required String content,
    required String endDate,
  });
  Future<String> removeTodo({required String id});
  Future<String> fetchTodo();
  Future<String> editTodo({
    required String id,
    required String title,
    required String content,
    required String endDate,
  });
}

@LazySingleton(as: ItodoRepo)
class TodoRepo implements ItodoRepo {
  String get apiUrl => 'http://10.0.2.2:8080/todos';
  @override
  Future<String> addingTodo({
    required String title,
    required String content,
    required String endDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'title': title,
          'content': content,
          'enddate': endDate,
        }),
      );
      return response.body;
    } catch (err) {
      throw 'error ehile adding todo';
    }
  }

  @override
  Future<String> removeTodo({required String id}) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      return response.body;
    } catch (err) {
      throw 'error ehile adding todo';
    }
  }

  @override
  Future<String> fetchTodo() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      return response.body;
    } catch (err) {
      throw 'error ehile adding todo';
    }
  }

  @override
  Future<String> editTodo({
    required String id,
    required String title,
    required String content,
    required String endDate,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'), // URL ends with /todos/1
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'title': title,
          'content': content,
          'enddate': endDate,
        }),
      );
      return response.body;
    } catch (err) {
      throw 'error ehile adding todo';
    }
  }
}
