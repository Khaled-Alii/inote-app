import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'main.dart';
import 'note.dart';

String getCurrentDate() {
  return '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
}

Future<void> deleteNote(Note note, List<Note> notes) async {
  final index = notes.indexWhere((n) => n.noteId == note.noteId);
  if (index == -1) return;
  notes.removeAt(index);
  bool undone = false;

  Get.snackbar(
    'Deleted',
    'Note deleted successfully',
    duration: const Duration(seconds: 3),
    snackPosition: SnackPosition.BOTTOM,
    colorText: Colors.white,
    backgroundColor: Colors.grey[900], // خلفية غامقة وأنيقة
    mainButton: TextButton(
      onPressed: () {
        if (undone) return;
        undone = true;

        if (index <= notes.length) {
          notes.insert(index, note);
        } else {
          notes.add(note);
        }
        if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
      },
      child: const Text('UNDO', style: TextStyle(color: Colors.yellow)),
    ),
  );

  await Future.delayed(const Duration(seconds: 3));

  if (!undone) {
    await database.noteDao.deleteNote(note);
  }
}


Future<Position?> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    Get.snackbar('Warning', 'Location services are disabled.');
    return null;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      Get.snackbar('Warning', 'Location permissions are denied');
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    Get.snackbar(
      'Warning',
      'Location permissions are permanently denied, we cannot request permissions.',
    );
    return null;
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
