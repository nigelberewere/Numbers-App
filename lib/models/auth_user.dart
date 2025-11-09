class AuthUser {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  AuthUser({required this.uid, this.displayName, this.email, this.photoUrl});

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
      };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        uid: json['uid'] as String,
        displayName: json['displayName'] as String?,
        email: json['email'] as String?,
        photoUrl: json['photoUrl'] as String?,
      );
}
