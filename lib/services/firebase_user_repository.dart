import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import 'user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  FirebaseUserRepository({required this.userId});

  DocumentReference get _docRef => _firestore.collection('users').doc(userId);

  @override
  Future<UserProfile> getUserProfile() async {
    final doc = await _docRef.get();
    if (doc.exists && doc.data() != null) {
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
    }
    return UserProfile();
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    await _docRef.set(profile.toMap(), SetOptions(merge: true));
  }

  @override
  Stream<UserProfile> userProfileStream() {
    return _docRef.snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return UserProfile();
    });
  }
}
