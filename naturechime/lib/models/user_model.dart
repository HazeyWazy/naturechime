import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? profileImageUrl;
  final Timestamp? createdAt;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.profileImageUrl,
    this.createdAt,
  });

  // Factory constructor to create a UserModel from a Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return UserModel(
      uid: snapshot.id,
      email: data?['email'] as String?,
      displayName: data?['displayName'] as String?,
      profileImageUrl: data?['profileImageUrl'] as String?,
      createdAt: data?['createdAt'] as Timestamp?,
    );
  }

  // Method to convert UserModel instance to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
