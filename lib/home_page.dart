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
  final searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  bool _isSearching = false;
  ShakeDetector? detector;
  final AudioPlayer _audioPlayer = AudioPlayer();
  RxBool isSearching = false.obs;

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

  @override
  void dispose() {
    detector?.stopListening();
    _audioPlayer.dispose();
    searchController.dispose();
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
        backgroundColor: Colors.teal[800],
        iconTheme: const IconThemeData(color: Colors.white),
        title: _isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (value) => searchQuery.value = value,
              )
            : const Text('INote', style: TextStyle(color: Colors.white)),
        actions: [
          Obx(
            () => isSearching.value
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Clear search',
                    onPressed: () {
                      searchController.clear();
                      searchQuery.value = '';
                      isSearching.value = false;
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    tooltip: 'Search',
                    onPressed: () => isSearching.value = true,
                  ),
          ),
        ],
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
                  return _EmptyState(
                    icon: Icons.note_alt_outlined,
                    title: 'No Notes Yet',
                    subtitle:
                        'Tap the + button below\nto create your first note.',
                  );
                }
                // Sort chronologically (newest first).
                final sorted = List<Note>.from(notes)
                    .sortedBy((note) {
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
                    })
                    .reversed
                    .toList();

                final query = searchQuery.value.trim().toLowerCase();
                final displayNotes = query.isEmpty
                    ? sorted
                    : sorted.where((note) {
                        final titleMatch =
                            note.title?.toLowerCase().contains(query) ?? false;
                        final descMatch = note.description
                            .toLowerCase()
                            .contains(query);
                        return titleMatch || descMatch;
                      }).toList();

                if (displayNotes.isEmpty) {
                  return _EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No Results Found',
                    subtitle:
                        'Nothing matched "${searchQuery.value.trim()}"\nTry different keywords.',
                  );
                }

                return ListView.builder(
                  itemCount: displayNotes.length,
                  cacheExtent: 300,
                  physics: ScrollPhysics(
                    parent: RangeMaintainingScrollPhysics(),
                  ),
                  itemBuilder: (context, index) {
                    final currentNote = displayNotes[index];

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
                                  color: Colors.teal,
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

            Obx(() {
              final query = searchQuery.value.trim();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  query.isEmpty
                      ? 'Total notes: ${notes.length}'
                      : 'Showing results for "$query"',
                  style: TextStyle(color: Colors.teal[700], fontSize: 13),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon inside a layered circle
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer faint circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                // Inner circle
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                // Icon
                Icon(icon, size: 48, color: Colors.teal[700]),
              ],
            ),
            const SizedBox(height: 28),
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.teal[900],
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 10),
            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
