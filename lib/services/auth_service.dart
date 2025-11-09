import '../models/auth_user.dart';

abstract class AuthService {
  AuthUser? get currentUser;

  Future<AuthUser?> signInWithEmail(String email, String password);
  Future<AuthUser?> signUpWithEmail(String email, String password);
  Future<AuthUser?> signInWithGoogle();
  Future<void> signOut();
}
/// Implementation note for integrators
///
/// This file defines the `AuthService` interface used by the app. The previous
/// in-memory demo implementation has been removed to avoid shipping mock data
/// to backend engineers. Instead, provide a concrete implementation and wire
/// it into the top-level `authService` variable below.
///
/// Example: in your `main()` you can assign a Firebase implementation:
///
///   import 'services/auth_service.dart';
///   import 'services/firebase_auth_service.dart';
///
///   void main() async {
///     WidgetsFlutterBinding.ensureInitialized();
///     await Firebase.initializeApp();
///     authService = FirebaseAuthService();
///     runApp(const MyApp());
///   }

/// A minimal stub that intentionally throws UnimplementedError for all
/// operations. Backend engineers should implement the concrete `AuthService`
/// (for example `FirebaseAuthService`) and set `authService` to that instance
/// in application startup.
class AuthServiceStub implements AuthService {
  AuthServiceStub();

  @override
  AuthUser? get currentUser => null;

  @override
  Future<AuthUser?> signInWithEmail(String email, String password) {
    throw UnimplementedError('signInWithEmail is not implemented. Replace the authService with a real implementation.');
  }

  @override
  Future<AuthUser?> signUpWithEmail(String email, String password) {
    throw UnimplementedError('signUpWithEmail is not implemented. Replace the authService with a real implementation.');
  }

  @override
  Future<AuthUser?> signInWithGoogle() {
    throw UnimplementedError('signInWithGoogle is not implemented. Replace the authService with a real implementation.');
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError('signOut is not implemented. Replace the authService with a real implementation.');
  }
}

/// Top-level auth service instance used by the UI.
///
/// IMPORTANT: set this to your concrete implementation (e.g. `FirebaseAuthService()`)
/// during app startup. Leaving the default will throw UnimplementedError at runtime.
AuthService authService = AuthServiceStub();
