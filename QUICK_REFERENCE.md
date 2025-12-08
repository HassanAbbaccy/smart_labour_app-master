# Quick Reference Guide

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd d:\smart_labour_app-master
flutter pub get
```

### 2. Configure Firebase
- Get credentials from Firebase Console
- Update `lib/firebase_options.dart`
- Follow `FIREBASE_SETUP.md`

### 3. Run App
```bash
flutter run
```

### 4. Test Authentication
**Sign Up:**
- Email: `test@example.com`
- Password: `Password123`
- First Name: `John`
- Last Name: `Doe`
- Phone: `+1-800-123-4567`
- Profession: `Plumber`

**Sign In:**
- Use the same credentials

## 📂 Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | Firebase init, app entry point |
| `lib/firebase_options.dart` | Firebase credentials |
| `lib/services/auth_service.dart` | All auth operations |
| `lib/screens/signin_screen.dart` | Login screen |
| `lib/screens/dashboard.dart` | Main dashboard UI |
| `lib/models/user_model.dart` | User data structure |
| `pubspec.yaml` | Dependencies |

## 🔑 Key Classes

### AuthService (Singleton)
```dart
// Sign up
await AuthService().signUp(
  email: 'email@example.com',
  password: 'password123',
  firstName: 'John',
  lastName: 'Doe',
  phoneNumber: '+1-800-123-4567',
  profession: 'Plumber',
);

// Sign in
await AuthService().signIn(
  email: 'email@example.com',
  password: 'password123',
);

// Sign out
await AuthService().signOut();

// Get current user
AuthService().currentUser

// Check if logged in
AuthService().isAuthenticated
```

### UserModel
```dart
UserModel(
  email: 'user@example.com',
  password: '',
  firstName: 'John',
  lastName: 'Doe',
  phoneNumber: '+1-800-123-4567',
  profession: 'Plumber',
  rating: 4.8,
  completedJobs: 28,
  monthlyEarnings: 850,
  activeJobs: 5,
)
```

## 🎨 Colors

```dart
primaryPurple = #7C3AED
accentSkyBlue = #0EA5E9
lightPurple = #F3E8FF
lightSkyBlue = #E0F2FE
```

## 📱 App Flow

```
App Starts
  ↓
Firebase Initializes
  ↓
Check Session
  ├─ Logged In → Dashboard
  └─ Not Logged In → SignIn
                      ↓
                   Sign Up or Sign In
                      ↓
                   Dashboard (with user data)
```

## 🔄 Data Flow

```
FirebaseAuth ← Email/Password
     ↓
 Authenticate User
     ↓
Firestore ← Create/Read User Doc
     ↓
AuthService ← Cache User Data
     ↓
Dashboard ← Display User Info
```

## ✅ Checklist Before Running

- [ ] Firebase project created
- [ ] `google-services.json` added (Android)
- [ ] `GoogleService-Info.plist` added (iOS)
- [ ] `firebase_options.dart` updated with credentials
- [ ] Firebase Auth enabled in Console
- [ ] Firestore Database created
- [ ] Dependencies installed (`flutter pub get`)
- [ ] No build errors

## 🐛 Common Issues

### Firebase Not Initializing
```
Fix: Check firebase_options.dart credentials
```

### Auth Failed
```
Fix: Verify email/password at Firebase Console → Auth → Users
```

### Firestore Access Denied
```
Fix: Check Firestore Rules allow authenticated users
```

### Blank Dashboard
```
Fix: Check user data exists in Firestore collection 'users'
```

## 📊 Firestore Collection Structure

```
firestore
└── users (collection)
    └── {uid} (document)
        ├── uid: "user123"
        ├── email: "user@example.com"
        ├── firstName: "John"
        ├── lastName: "Doe"
        ├── phoneNumber: "+1-800-123-4567"
        ├── profession: "Plumber"
        ├── rating: 4.8
        ├── completedJobs: 28
        ├── monthlyEarnings: 850
        ├── activeJobs: 5
        ├── createdAt: timestamp
        └── updatedAt: timestamp
```

## 🎯 Features at a Glance

✅ **Authentication**
- Firebase Auth (Email/Password)
- Sign Up with profile
- Sign In/Out
- Session persistence

✅ **Database**
- Firestore user storage
- Real-time sync
- User statistics

✅ **UI**
- Purple & Sky Blue theme
- Modern dashboard
- User profile card
- Statistics display
- Job listings
- Active tasks
- Service recommendations

✅ **User Experience**
- Loading indicators
- Error messages
- Success feedback
- Smooth navigation
- Responsive design

## 📚 Documentation Files

1. **FIREBASE_SETUP.md** - Complete Firebase setup guide
2. **IMPLEMENTATION_SUMMARY.md** - What was implemented
3. **COLOR_GUIDE.md** - Color scheme documentation
4. **This file** - Quick reference

## 🔗 Useful Links

- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Flutter Docs](https://firebase.flutter.dev/)
- [Flutter Docs](https://flutter.dev/docs)

## 💡 Tips

1. Use AuthService singleton everywhere
2. Always check `isAuthenticated` before accessing `currentUser`
3. Catch `FirebaseAuthException` for specific errors
4. Update Firestore rules before production
5. Store sensitive data on server side only

## 🎓 Learning Resources

- [Firebase Authentication Best Practices](https://firebase.google.com/docs/auth/best-practices)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)
- [Flutter State Management](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)

---

**Last Updated**: December 7, 2025  
**Version**: 1.0  
**Status**: ✅ Ready to Deploy
