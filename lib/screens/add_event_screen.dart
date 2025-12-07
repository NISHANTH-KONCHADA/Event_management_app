import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _venueController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // File? _selectedImage;

  // Pick image from gallery
  // Future<void> _pickImage() async {
  //   final picker = ImagePicker();
  //   final picked = await picker.pickImage(source: ImageSource.gallery);

  //   if (picked != null) {
  //     setState(() {
  //       _selectedImage = File(picked.path);
  //     });
  //   }
  // }

  // Select Date & Time
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  // Save Event with Image Upload
  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String eventId = const Uuid().v4();
   // String imageUrl = "";

    // Upload image if selected
    // if (_selectedImage != null) {
    //   try {
    //     final storageRef = FirebaseStorage.instance
    //         .ref()
    //         .child("event_images")
    //         .child("$eventId.jpg");

    //     await storageRef.putFile(_selectedImage!);
    //     imageUrl = await storageRef.getDownloadURL();
    //   } catch (e) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("Image upload failed: $e")),
    //     );
    //   }
    // }

    // Create event
   final newEvent = Event(
  id: eventId,
  name: _nameController.text,
  venue: _venueController.text,
  dateTime: _selectedDate,
);


    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .set(newEvent.toJson());

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add event: $e")),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Event'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ---------- IMAGE PICKER ----------
              // GestureDetector(
              //   onTap: _pickImage,
              //   child: Container(
              //     height: 180,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(14),
              //       color: Colors.grey[300],
              //       image: _selectedImage != null
              //           ? DecorationImage(
              //               image: FileImage(_selectedImage!),
              //               fit: BoxFit.cover,
              //             )
              //           : null,
              //     ),
              //     child: _selectedImage == null
              //         ? const Center(
              //             child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
              //           )
              //         : null,
              //   ),
              // ),

              // const SizedBox(height: 20),

              // ---------- NAME ----------
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  prefixIcon: Icon(Icons.event),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter event name' : null,
              ),

              const SizedBox(height: 16),

              // ---------- VENUE ----------
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(
                  labelText: 'Venue',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter venue' : null,
              ),

              const SizedBox(height: 20),

              // ---------- DATE & TIME ----------
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Event Date & Time'),
                subtitle: Text(DateFormat.yMMMd().add_jm().format(_selectedDate)),
                trailing: TextButton(
                  onPressed: () => _selectDateTime(context),
                  child: const Text('SELECT'),
                ),
              ),

              const SizedBox(height: 30),

              // ---------- SAVE BUTTON ----------
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Save Event'),
                        onPressed: _saveEvent,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
