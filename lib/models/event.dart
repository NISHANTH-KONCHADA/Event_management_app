import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String id;
  String name;
  String venue;
  DateTime dateTime;

  Event({
    required this.id,
    required this.name,
    required this.venue,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'venue': venue,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      name: data['name'] ?? '',
      venue: data['venue'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
    );
  }
}
