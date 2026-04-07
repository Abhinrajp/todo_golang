import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_golang/provider/provider.dart';
import 'package:todo_golang/service/getit_injection.dart';
import 'package:todo_golang/view/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Goland',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
