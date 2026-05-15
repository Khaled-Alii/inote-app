import 'package:floor/floor.dart';

@Entity(tableName: 'notes')
class Note {
  @PrimaryKey(autoGenerate: true)
  int? noteId;
  String description, time;
  String? title;
  double? locationLat, locationLong;

  Note({
    required this.description,
    required this.time,
    this.noteId,
    this.title,
    this.locationLat,
    this.locationLong,
  });
  Note copyWith({
    int? noteId,
    String? title,
    String? description,
    String? time,
    double? locationLat,
    double? locationLong,
  }) {
    return Note(
      noteId: noteId ?? this.noteId,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      locationLat: locationLat ?? this.locationLat,
      locationLong: locationLong ?? this.locationLong,
    );
  }
}
