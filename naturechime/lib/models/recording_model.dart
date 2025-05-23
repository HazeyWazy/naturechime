import 'package:cloud_firestore/cloud_firestore.dart';

class Recording {
  final String id; // Document ID from Firestore
  final String userId; // ID of the user who created the recording
  final String title;
  final String audioUrl; // URL of the audio file
  final Timestamp createdAt; // Timestamp of when the recording was created
  final int durationSeconds; // Duration of the recording in seconds

  Recording({
    required this.id,
    required this.userId,
    required this.title,
    required this.audioUrl,
    required this.createdAt,
    required this.durationSeconds,
  });

  // Factory constructor to create a Recording
  factory Recording.fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Recording(
      id: snap.id,
      userId: snapshot['userId'] ?? '',
      title: snapshot['title'] ?? '',
      audioUrl: snapshot['audioUrl'] ?? '',
      createdAt: snapshot['createdAt'] ?? Timestamp.now(),
      durationSeconds: snapshot['durationSeconds'] ?? 0,
    );
  }

  // Method to convert a Recording object
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'title': title,
        'audioUrl': audioUrl,
        'createdAt': createdAt,
        'durationSeconds': durationSeconds,
      };

  Recording copyWith({
    String? id,
    String? userId,
    String? title,
    String? audioUrl,
    Timestamp? createdAt,
    int? durationSeconds,
  }) {
    return Recording(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      audioUrl: audioUrl ?? this.audioUrl,
      createdAt: createdAt ?? this.createdAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}
