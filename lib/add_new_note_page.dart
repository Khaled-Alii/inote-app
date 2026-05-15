import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inote/functions.dart';
import 'note.dart';

class AddNewNotePage extends StatefulWidget {
  const AddNewNotePage({super.key});

  @override
  State<AddNewNotePage> createState() => _AddNewNotePageState();
}

class _AddNewNotePageState extends State<AddNewNotePage> {
  final titleController = TextEditingController();

  final descController = TextEditingController();

  RxBool enabledLocation = false.obs;

  @override
  void dispose() {
    // TODO: implement dispose
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // جعل الـ AppBar بلون Teal غامق يتناسب مع التصميم
      backgroundColor: Colors.teal[50], // خلفية فاتحة جداً مريحة للعين
      appBar: AppBar(
        title: Text('Create note', style: TextStyle(color: Colors.white)),
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
                      // تنسيق حقل العنوان
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'Enter title (optional)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.title, color: Colors.teal),
                        ),
                      ),
                      SizedBox(height: 16),
                      // حقل الوصف الكبير
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            controller: descController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText: 'Enter description...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Obx(() => ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: enabledLocation.value ? Colors.grey : Colors.teal[700],
                              foregroundColor: Colors.white,
                            ),
                            onPressed: !enabledLocation.value ? () => enabledLocation.value = true : null,
                            label: Text('Enable Location'),
                            icon: Icon(Icons.location_on),
                          )),
                          Obx(() => ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !enabledLocation.value ? Colors.grey : Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: enabledLocation.value ? () => enabledLocation.value = false : null,
                            label: Text('Disable'),
                            icon: Icon(Icons.location_off),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width:  double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[900],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (descController.text.isEmpty) {
                      Get.snackbar(
                        'Oops!',
                        'Please Enter Description',
                        backgroundColor: Colors.grey[900],
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    // ... (بقية الـ logic الخاص بك)
                    final note = Note(
                      description: descController.text,
                      time: getCurrentDate(),
                      title: titleController.text.isEmpty ? null : titleController.text,
                      locationLat: null, locationLong: null,
                    );
                    Get.back(result: {note: enabledLocation.value});
                  },
                  label: Text('Save Note', style: TextStyle(fontSize: 16)),
                  icon: Icon(Icons.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}