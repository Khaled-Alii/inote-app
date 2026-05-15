import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:inote/edit_note_page.dart';
import 'package:shake/shake.dart';
import 'add_new_note_page.dart';
import 'functions.dart';
import 'main.dart';
import 'note.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final notes = <Note>[].obs;
  ShakeDetector? detector;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    loadNotes();

    detector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) async {
        final List<Note> oldNotes = List.from(notes);

        notes.clear();

        bool undone = false;
        Get.snackbar(
          'Deleted',
          'All notes deleted',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          colorText: Colors.white,
          backgroundColor: Colors.grey[900],
          mainButton: TextButton(
            onPressed: () {
              if (undone) return;
              undone = true;
              notes.assignAll(oldNotes);
              Get.closeCurrentSnackbar();
            },
            child: const Text('UNDO', style: TextStyle(color: Colors.yellow)),
          ),
        );

        await _audioPlayer.setAsset('assets/sounds/sound.mp3');
        await _audioPlayer.play();

        await Future.delayed(const Duration(seconds: 3));

        if (!undone) {
          await database.noteDao.deleteAllNotes();
        }
      },
    );
  }

  // إغلاق الموارد لمنع Memory Leak
  @override
  void dispose() {
    detector?.stopListening();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> loadNotes() async {
    notes.value = await database.noteDao.selectAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: const Text('INote', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        elevation: 8,
        onPressed: () async {
          if (Get.isSnackbarOpen) {
            Get.closeAllSnackbars();
          }
          final result = await Get.to(
            AddNewNotePage(),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 500),
          );
          if (result == null || result is! Map) {
            Get.snackbar(
              'Info',
              'Canceled creating',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: 1.seconds,
            );
            return;
          }

          // Bug #10 fix: AddNewNotePage still returns Map<Note,bool> —
          // extract note and location flag from it safely.
          Note note = result.keys.first as Note;
          final bool shouldGetLocation = result.values.first as bool;

          if (shouldGetLocation) {
            final location = await getCurrentLocation();
            if (location != null) {
              note = note.copyWith(
                locationLat: location.latitude,
                locationLong: location.longitude,
              );
            } else {
              Get.snackbar(
                'Warning',
                'Could not get location, saving without it.',
                backgroundColor: Colors.orange,
              );
            }
          }

          // Bug #3 fix: save to DB first to get the real auto-generated noteId,
          // then add to the observable list with the correct id.
          final newId = await database.noteDao.saveNote(note);
          if (newId != null) {
            note = note.copyWith(noteId: newId);
          }
          notes.add(note);

          Get.snackbar(
            'Success',
            'Note saved',
            backgroundColor: Colors.green,
            snackPosition: SnackPosition.TOP,
            colorText: Colors.white,
          );
        },
        child: const Icon(Icons.add, color: Colors.teal),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (notes.isEmpty) {
                  return Center(
                    child: Text('No Notes Yet', textAlign: TextAlign.center),
                  );
                }
                // Bug #5 fix: parse date string for chronological sort, not lexicographic.
                final displayNotes = List<Note>.from(notes).sortedBy((note) {
                  try {
                    final p = note.time.split('/');
                    return DateTime(
                      int.parse(p[2]),
                      int.parse(p[1]),
                      int.parse(p[0]),
                    );
                  } catch (_) {
                    return DateTime(2000);
                  }
                }).reversed.toList();

                return ListView.builder(
                  itemCount: displayNotes.length,
                  cacheExtent: 300,
                  physics: ScrollPhysics(
                    parent: RangeMaintainingScrollPhysics(),
                  ),
                  itemBuilder: (context, index) {
                    final currentNote =
                        displayNotes[index]; // استخدام الـ Object بدلا من الإندكس المعرض للخطأ

                    return Card(
                      color: Colors.white,
                      shadowColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(4),
                      child: Padding(
                        padding: const EdgeInsets.all(8 * 2),
                        child: ListTile(
                          //title
                          title: Text(
                            currentNote.title == null ||
                                    currentNote.title!.isEmpty
                                ? 'No Title'
                                : '${currentNote.title}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.teal[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          //description
                          subtitle: Text(
                            currentNote.description,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                          //time
                          trailing: Text(
                            currentNote.time,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          //icon
                          leading: currentNote.locationLat != null
                              ? const Icon(Icons.location_on)
                              : const Icon(
                                  Icons.sticky_note_2_outlined,
                                  color: Colors
                                      .teal, // لو الملاحظة عادية تظهر باللون ده
                                ),
                          onLongPress: () async {
                            await deleteNote(currentNote, notes);
                          },
                          onTap: () async {
                            Map<String, dynamic>? result = {};
                            try {
                              if (Get.isSnackbarOpen) {
                                Get.closeAllSnackbars();
                              }
                              result =
                                  await Get.to(
                                        () => EditNotePage(),
                                        arguments: currentNote.copyWith(),
                                        transition: Transition.rightToLeft,
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                      )
                                      as Map<String, dynamic>?;
                              if (result == null) {
                                Get.snackbar(
                                  'Info',
                                  'Canceled creating',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  duration: 1.seconds,
                                );
                                return;
                              }
                              // Bug #4 fix: deleted from EditNotePage
                              if (result['delete_note'] == true) {
                                await deleteNote(currentNote, notes);
                                return;
                              }

                              if (result.containsKey('note') &&
                                  result.containsKey('update_location')) {
                                Note n = result['note'] as Note;
                                bool failedToSaveLocation = false;

                                // Bug #2 fix: fetch location and set on n before building updatedNote
                                if (result['update_location'] == true) {
                                  final location = await getCurrentLocation();
                                  if (location == null) {
                                    Get.snackbar(
                                      'Error',
                                      'Could not get your current location',
                                    );
                                    failedToSaveLocation = true;
                                  } else {
                                    n = n.copyWith(
                                      locationLat: location.latitude,
                                      locationLong: location.longitude,
                                    );
                                  }
                                }

                                // Bug #1 & #3 fix: find original by noteId, build
                                // a clean updatedNote, save to DB first, then
                                // replace in the list to trigger Obx rebuild.
                                final idx = notes.indexWhere(
                                  (e) => e.noteId == currentNote.noteId,
                                );
                                if (idx != -1) {
                                  final updatedNote = notes[idx].copyWith(
                                    title: n.title,
                                    description: n.description,
                                    time: n.time,
                                    locationLat: n.locationLat,
                                    locationLong: n.locationLong,
                                  );
                                  // DB first — so if it throws, UI stays consistent
                                  await database.noteDao.saveNote(updatedNote);
                                  notes[idx] = updatedNote; // triggers Obx
                                }

                                if (failedToSaveLocation) {
                                  Get.snackbar(
                                    'Warning',
                                    'Note updated without location',
                                    duration: 700.milliseconds,
                                  );
                                } else {
                                  Get.snackbar(
                                    'Success',
                                    'Note updated successfully',
                                    duration: 700.milliseconds,
                                  );
                                }
                              }
                            } catch (e) {
                              Get.snackbar(
                                'Info',
                                'Canceled Editing',
                                duration: 700.milliseconds,
                              );
                              return;
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // Bug #11 fix: use notes.length directly — no redundant notesCount needed
            Align(
              alignment: Alignment.bottomCenter,
              child: Obx(() => Text('Total notes is ${notes.length}')),
            ),
          ],
        ),
      ),
    );
  }
}
