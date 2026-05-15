import 'package:floor/floor.dart';

import 'note.dart';

@dao
abstract class NoteDao {
  @Query('select * from notes')
  Future<List<Note>> selectAll();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int?> saveNote(Note note);

  @delete
  Future<void> deleteNote(Note note);

  @Query('select count(*) from notes')
  Future<int?> getNumberOfNotes();

  @Query('delete from notes')
  Future<int?> deleteAllNotes();
}
