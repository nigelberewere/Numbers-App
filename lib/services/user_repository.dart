import '../models/user_profile.dart';

abstract class UserRepository {
  Future<UserProfile> getUserProfile();
  Future<void> updateUserProfile(UserProfile profile);
  Stream<UserProfile> userProfileStream();
}
