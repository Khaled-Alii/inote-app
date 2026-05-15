import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';
import 'home_page.dart';
import 'notes_database.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase();
  runApp(const MyApp());
}

late NotesDatabase database;

Future<void> initDatabase() async {
  await copyDatabase();
  //connect to databases
  final dir = await getApplicationDocumentsDirectory();
  final dbPath = join(dir.path, 'notes.db');

  database = await $FloorNotesDatabase.databaseBuilder(dbPath).build();
}

Future<void> copyDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final path = join(dir.path, 'notes.db');
  print(dir);

  if (File(path).existsSync()) return; //to avoid many times of copy

  //copy from assets to documents in app
  ByteData data = await rootBundle.load('assets/databases/notes.db'); //path
  List<int> bytes = data.buffer.asUint8List(
    data.offsetInBytes,
    data.lengthInBytes,
  );
  await File(path).writeAsBytes(bytes);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(home: HomePage(), debugShowCheckedModeBanner: false);
  }
}
