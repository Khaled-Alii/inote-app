import 'package:floor/floor.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'note.dart';
import 'note_dao.dart';

part 'notes_database.g.dart';

@Database(version: 1, entities: [Note])
abstract class NotesDatabase extends FloorDatabase {
  NoteDao get noteDao;
}
