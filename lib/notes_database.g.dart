// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $NotesDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $NotesDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $NotesDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<NotesDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorNotesDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $NotesDatabaseBuilderContract databaseBuilder(String name) =>
      _$NotesDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $NotesDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$NotesDatabaseBuilder(null);
}

class _$NotesDatabaseBuilder implements $NotesDatabaseBuilderContract {
  _$NotesDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $NotesDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $NotesDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<NotesDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$NotesDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$NotesDatabase extends NotesDatabase {
  _$NotesDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  NoteDao? _noteDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `notes` (`noteId` INTEGER PRIMARY KEY AUTOINCREMENT, `description` TEXT NOT NULL, `time` TEXT NOT NULL, `title` TEXT, `locationLat` REAL, `locationLong` REAL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  NoteDao get noteDao {
    return _noteDaoInstance ??= _$NoteDao(database, changeListener);
  }
}

class _$NoteDao extends NoteDao {
  _$NoteDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _noteInsertionAdapter = InsertionAdapter(
            database,
            'notes',
            (Note item) => <String, Object?>{
                  'noteId': item.noteId,
                  'description': item.description,
                  'time': item.time,
                  'title': item.title,
                  'locationLat': item.locationLat,
                  'locationLong': item.locationLong
                }),
        _noteDeletionAdapter = DeletionAdapter(
            database,
            'notes',
            ['noteId'],
            (Note item) => <String, Object?>{
                  'noteId': item.noteId,
                  'description': item.description,
                  'time': item.time,
                  'title': item.title,
                  'locationLat': item.locationLat,
                  'locationLong': item.locationLong
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Note> _noteInsertionAdapter;

  final DeletionAdapter<Note> _noteDeletionAdapter;

  @override
  Future<List<Note>> selectAll() async {
    return _queryAdapter.queryList('select * from notes',
        mapper: (Map<String, Object?> row) => Note(
            description: row['description'] as String,
            time: row['time'] as String,
            noteId: row['noteId'] as int?,
            title: row['title'] as String?,
            locationLat: row['locationLat'] as double?,
            locationLong: row['locationLong'] as double?));
  }

  @override
  Future<int?> getNumberOfNotes() async {
    return _queryAdapter.query('select count(*) from notes',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> deleteAllNotes() async {
    return _queryAdapter.query('delete from notes',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int> saveNote(Note note) {
    return _noteInsertionAdapter.insertAndReturnId(
        note, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteNote(Note note) async {
    await _noteDeletionAdapter.delete(note);
  }
}
