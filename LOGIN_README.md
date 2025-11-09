Login / Signup page (local stub)

Files added:
- `lib/pages/login_page.dart` — a UI with email/password signup and login and a "Sign in with Google" button.
 - `lib/services/auth_service.dart` — `AuthService` interface. The previous in-memory demo implementation has been removed to avoid shipping mock data. Implement and wire a concrete service (e.g. `FirebaseAuthService`) and set the top-level `authService` variable during app startup.
- `lib/models/auth_user.dart` — small `AuthUser` model.

How to use:
- Navigate to `LoginPage()` from your app's routing / button to show the new page.
 - The app now expects a concrete implementation to be provided at startup. See `FIREBASE_INTEGRATION.md` for complete integration instructions and the exact method signatures the backend engineer should implement.

Next steps for production:
- Replace `InMemoryAuthService` implementation with one that uses Firebase Auth (or your backend). Keep the `AuthService` interface and swap the implementation.
- Configure Google Sign-In on Android (add SHA-1/256) and iOS (reverse client id) for proper OAuth flow.
