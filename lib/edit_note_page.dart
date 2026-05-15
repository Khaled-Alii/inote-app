import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inote/functions.dart';
import 'main.dart';
import 'note.dart';
import 'package:url_launcher/url_launcher.dart';

class EditNotePage extends StatefulWidget {
  const EditNotePage({super.key});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final titleController = TextEditingController();

  final descController = TextEditingController();
  bool enabledCurrentLocation = false;
  late final Note note;

  @override
  void initState() {
    super.initState();
    note = Get.arguments;
    titleController.text = note.title ?? '';
    descController.text = note.description;
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: Text('Editing note', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[800],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'Title here',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // حقل الوصف
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            controller: descController,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Edit description...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // زر تحديث الموقع
                      Column(
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.teal[800],
                              side: BorderSide(color: Colors.teal),
                            ),
                            onPressed: () {
                              // Bug #6 fix: must call setState so the widget
                              // rebuilds and can reflect the new state in UI.
                              setState(() => enabledCurrentLocation = true);
                            },
                            label: Text('Update with current location'),
                            icon: Icon(Icons.update_outlined),
                          ),
                          SizedBox(height: 20),
                          Visibility(
                            visible: note.locationLong == null ? false : true,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final url = Uri.parse(
                                  'geo:${note.locationLat},${note.locationLong}?q=${note.locationLat},${note.locationLong}',
                                );

                                final success = await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );

                                if (!success) {
                                  Get.snackbar(
                                    'Error',
                                    'Could not launch $url',
                                  );
                                }
                              },
                              label: Text('Get in map'),
                              icon: Icon(Icons.location_searching_sharp),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.teal[800],
                                side: BorderSide(color: Colors.teal),
                                backgroundColor: Colors.teal[50],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[900],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        //close all snackbar
                        if (Get.isSnackbarOpen) {
                          Get.closeAllSnackbars();
                        }
                        //check validation of description
                        if (descController.text.isEmpty) {
                          Get.snackbar(
                            'Wrong',
                            'Enter a description',
                            backgroundColor: Colors.grey[900],
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        //save fields to note
                        copyFieldsToNote();
                        Map<String, dynamic> result = {
                          'note': note,
                          'update_location': enabledCurrentLocation,
                        };
                        Get.back(result: result);
                      },
                      label: Text('Save'),
                      icon: Icon(Icons.save),
                    ),
                  ),
                  SizedBox(width: 5),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                    ),
                    onPressed: () {
                      // Signals HomePage to delete this note via its own
                      // deleteNote() function (which handles undo + DB delete).
                      Get.back(result: {'delete_note': true});
                    },
                    label: Text('Delete'),
                    icon: Icon(Icons.delete_forever),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void copyFieldsToNote() {
    //assign new title to note
    note.title = titleController.text.isNotEmpty ? titleController.text : null;
    //assign new description
    note.description = descController.text;
    //assign new date
    note.time = getCurrentDate();
  }
}
