# SmartLabour Marketplace - Authentication & Dashboard

## 🚀 Features Implemented

### ✅ Firebase Authentication
- **Email/Password Authentication** with Firebase Auth
- **User Registration** - Sign up with details (name, email, profession, phone)
- **User Login** - Secure login with email & password
- **Password Reset** - Forgot password functionality
- **User Session Management** - Persistent authentication state
- **Sign Out** - Logout with automatic session clearing

### ✅ Firestore Database
- **User Profile Storage** - Stores user data in Firestore
- **Real-time Data Sync** - Automatic synchronization with Firestore
- **User Statistics** - Track active jobs, completed tasks, earnings
- **User Ratings** - Store and display user ratings
- **Server Timestamps** - Track creation and update times

### ✅ Beautiful UI Redesign
- **Color Scheme**: Purple (#7C3AED) & Sky Blue (#0EA5E9)
- **Modern Dashboard** with:
  - Gradient welcome banner with user profile
  - User initials avatar with rating badge
  - Statistics cards (Active Jobs, Completed Tasks, Earnings)
  - Available jobs listing with apply buttons
  - Active tasks with progress bars
  - Recommended services carousel
  - Smooth transitions and animations
  - Professional card-based layouts

## 📋 Setup Instructions

### 1. **Get Firebase Credentials**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing
3. Enable **Authentication** > **Email/Password**
4. Enable **Firestore Database** in test mode (or configure security rules)
5. Download credentials for your platform

### 2. **Update Firebase Configuration**

#### For Android:
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory
3. Ensure your `android/build.gradle.kts` includes Firebase plugin

#### For iOS:
1. Download `GoogleService-Info.plist` from Firebase Console
2. Add to Xcode project
3. Update `ios/Podfile` if needed

#### For Web:
Update `lib/firebase_options.dart` with your web credentials:
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_AUTH_DOMAIN',
  storageBucket: 'YOUR_STORAGE_BUCKET',
);
```

I have added the web configuration you supplied to `lib/firebase_options.dart` using:

```dart
apiKey: 'AIzaSyADR91LNDXiwGifaUAi0LCi1F_utcAWkBc'
authDomain: 'smartlabour-marketplace.firebaseapp.com'
projectId: 'smartlabour-marketplace'
storageBucket: 'smartlabour-marketplace.firebasestorage.app'
messagingSenderId: '520907284454'
appId: '1:520907284454:web:fb16b9d55d393e9b2e8027'
```

This enables web clients to connect immediately. For Android and iOS, you'll still need to either:

- Add `google-services.json` to `android/app/` and `GoogleService-Info.plist` to the iOS project, or
- Provide the Android/iOS `appId` values so I can complete `lib/firebase_options.dart` with exact platform values, or
- Run `flutterfire configure` (requires the Firebase CLI) to generate a complete `firebase_options.dart` automatically.

### 3. **Install Dependencies**

```bash
flutter pub get
```

### 4. **Firestore Security Rules** (Optional but Recommended)

Add these rules to secure your Firestore data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}

Alternatively, a `firestore.rules` file has been added to the project root. Apply it in the Firebase Console or deploy via the Firebase CLI.
```

## 🏗️ Project Structure

```
lib/
├── main.dart                 # Firebase initialization
├── firebase_options.dart     # Firebase configuration
├── models/
│   └── user_model.dart      # User data model
├── services/
│   └── auth_service.dart    # Firebase Auth & Firestore service
├── screens/
│   ├── signin_screen.dart   # Login screen with Firebase auth
│   ├── signup_screen.dart   # Registration screen
│   ├── dashboard.dart       # Main dashboard (purple & sky blue)
│   └── welcome_screen.dart  # Welcome screen
├── widgets/
│   └── custom_scaffold.dart # Reusable scaffold
└── theme/
    └── theme.dart           # App theme configuration
```

## 📱 Authentication Flow

```
App Start
  ↓
Firebase Initialized
  ↓
Check User Session
  ↓
Is User Logged In?
  ├─ YES → Load User Data → Dashboard
  └─ NO → SignIn Screen
           ↓
        Sign In / Sign Up
           ↓
        Create User in Firebase Auth
           ↓
        Create User Doc in Firestore
           ↓
        Dashboard
```

## 🔐 AuthService Methods

### Sign Up
```dart
final result = await AuthService().signUp(
  email: 'user@example.com',
  password: 'password123',
  firstName: 'John',
  lastName: 'Doe',
  phoneNumber: '+1-800-123-4567',
  profession: 'Plumber',
);
```

### Sign In
```dart
final result = await AuthService().signIn(
  email: 'user@example.com',
  password: 'password123',
);
```

### Sign Out
```dart
await AuthService().signOut();
```

### Update Profile
```dart
await AuthService().updateUserProfile(
  firstName: 'John',
  profession: 'Plumber',
);
```

### Update Statistics
```dart
await AuthService().updateUserStats(
  activeJobs: 5,
  completedJobs: 28,
  monthlyEarnings: 850,
  rating: 4.8,
);
```

## 🎨 Dashboard Color Scheme

- **Primary Purple**: `#7C3AED`
- **Accent Sky Blue**: `#0EA5E9`
- **Light Purple**: `#F3E8FF`
- **Light Sky Blue**: `#E0F2FE`

## ⚠️ Important Notes

1. **Firebase Options**: The `firebase_options.dart` file contains dummy credentials. Replace them with your actual Firebase project credentials.

2. **Security**: Never commit sensitive Firebase keys to version control. Use environment variables.

3. **Firestore Rules**: Make sure to update security rules in production for data protection.

4. **Testing**: You can test with demo accounts:
   - Email: `test@example.com`
   - Password: `Password123`

## 🐛 Troubleshooting

### Firebase Not Initializing
- Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is properly placed
- Check Firebase Console project settings match your app configuration

### Authentication Errors
- Verify email/password are correct
- Check Firebase Console → Authentication → Users for registered accounts
- Ensure Email/Password provider is enabled

### Firestore Access Issues
- Check Firestore rules allow read/write for authenticated users
- Verify Firestore Database is created in Firebase Console

## 📖 Additional Resources

- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)

## 🎯 Next Steps

1. Test authentication flow (signup → signin → dashboard)
2. Update Firebase credentials for your project
3. Implement remaining screens (Jobs, Messages, Profile)
4. Add notifications using Firebase Cloud Messaging
5. Deploy to Firebase Hosting (web) or App Stores (mobile)

---

**Version**: 1.0.0  
**Last Updated**: December 7, 2025  
**Status**: ✅ Complete with Firebase Authentication & Beautiful UI
