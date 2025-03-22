import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AddNotesScreen extends StatefulWidget {
  final String courseId;

  const AddNotesScreen({Key? key, required this.courseId}) : super(key: key);

  @override
  _AddNotesScreenState createState() => _AddNotesScreenState();
}

class _AddNotesScreenState extends State<AddNotesScreen> {
  TextEditingController _pdfDescriptionController = TextEditingController();
  TextEditingController _videoUrlController = TextEditingController();
  TextEditingController _videoDescriptionController = TextEditingController();
  String? _pdfPath;

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _pdfPath = result.files.single.path;
      });
    }
  }

  void _saveNote() {
    if (_pdfPath == null && _videoUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one note type!")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Note added successfully!")),
    );

    setState(() {
      _pdfDescriptionController.clear();
      _videoUrlController.clear();
      _videoDescriptionController.clear();
      _pdfPath = null;
    });
  }

  void _showBottomSheet({required String type}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type == 'pdf' ? "Add PDF Note" : "Add Video Note",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (type == 'pdf') ...[
                  ElevatedButton(
                    onPressed: _pickPDF,
                    child: const Text("Select PDF"),
                  ),
                  if (_pdfPath != null) Text("PDF Selected", style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _pdfDescriptionController,
                    decoration: const InputDecoration(
                      hintText: "Enter description (optional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: _videoUrlController,
                    decoration: const InputDecoration(
                      hintText: "Enter video URL",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _videoDescriptionController,
                    decoration: const InputDecoration(
                      hintText: "Enter description (optional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Save"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Notes")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text("Add PDF"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showBottomSheet(type: 'pdf'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.video_library, color: Colors.blue),
                title: const Text("Add Video"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showBottomSheet(type: 'video'),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveNote,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text("Save Note"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}