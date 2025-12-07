import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cse23523/models/event.dart';
import 'edit_event_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  // 2. Delete: Remove events with confirmation
  // v. AlertDialog for confirmation
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${event.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('events')
                      .doc(event.id)
                      .delete();
                  
                  Navigator.of(ctx).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back from details
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${event.name}" deleted')),
                  );
                } catch (e) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete event: $e')),
                  );
                }
              },
              child: const Text('DELETE', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
        actions: [
          // iii. Edit Event button
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Event',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditEventScreen(event: event),
                ),
              );
            },
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            tooltip: 'Delete Event',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      // iv. Display all event details neatly
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // v. Add images or icons using assets or network
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(10.0),
                //   child: Image.network(
                //     // Using a placeholder image service based on event ID
                //     'https://picsum.photos/seed/${event.id}/600/300',
                //     height: 250,
                //     width: double.infinity,
                //     fit: BoxFit.cover,
                //   ),
                // ),
                // const SizedBox(height: 20),
                Text(
                  event.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                ),
                const SizedBox(height: 24),
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Date & Time',
                  text: DateFormat.yMMMMEEEEd().add_jm().format(event.dateTime),
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.location_on,
                  label: 'Venue',
                  text: event.venue,
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.tag,
                  label: 'Event ID',
                  text: event.id,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// A helper widget for displaying event details
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  const _InfoRow({required this.icon, required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.indigo, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}