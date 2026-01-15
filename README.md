# NotifyVault_v1 🔔

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-green.svg)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud%20Messaging-orange.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Android](https://img.shields.io/badge/Android-11+-green.svg)](https://www.android.com)

A comprehensive Flutter learning project demonstrating **Firebase Cloud Messaging (FCM)** integration with real-time push notifications, local notification handling, and complete token management.

## 🌟 Features

- ✅ **Firebase Cloud Messaging Setup** - Complete FCM integration
- ✅ **FCM Token Generation** - Automatic token creation and display
- ✅ **Foreground Notifications** - Handle messages when app is open
- ✅ **Background Notifications** - Process messages when app is in background
- ✅ **Terminated State Handling** - Receive notifications when app is closed
- ✅ **Local Notifications** - Display system notifications
- ✅ **Token Management** - Listen to token refresh events
- ✅ **Permission Handling** - Android 13+ permission requests
- ✅ **Comprehensive Logging** - Detailed console output for debugging
- ✅ **Test Instructions** - Step-by-step guide to send test notifications

## 📸 Screenshots

| Notification Screen | FCM Token Display | Received Messages |
|---|---|---|
| ![Home](https://via.placeholder.com/300x600?text=Notification+Screen) | ![Token](https://via.placeholder.com/300x600?text=FCM+Token) | ![Messages](https://via.placeholder.com/300x600?text=Received+Messages) |

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart 3.0 or higher
- Firebase project set up
- Android device/emulator (API 21+)
- Git

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/Djerad/NotifyVault_v1.git
cd NotifyVault_v1
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Run FlutterFire configuration
flutterfire configure
```

This will:
- Create `firebase_options.dart` automatically
- Configure Android & iOS settings
- Set up Google services files

4. **Run the app**
```bash
flutter clean
flutter run
```

## 🔧 Manual Firebase Setup (if needed)

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create Project"
3. Enter project name: `NotifyVault`
4. Click "Create Project"

### Step 2: Register Android App

1. In Firebase Console, click "Add App" → "Android"
2. Enter package name: `com.example.notify_vault_v1`
3. Download `google-services.json`
4. Place it in `android/app/`

### Step 3: Enable Cloud Messaging

1. In Firebase Console, go to **Cloud Messaging**
2. Copy the **Server Key** (you'll need this to send messages)

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.0
  firebase_messaging: ^14.6.0
  flutter_local_notifications: ^16.1.0
  permission_handler: ^11.4.0
```

## 📖 Usage

### Get FCM Token

```dart
FirebaseMessaging messaging = FirebaseMessaging.instance;
String? token = await messaging.getToken();
print("🔑 FCM Token: $token");
```

### Listen to Foreground Messages

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print("🔥 Message received: ${message.notification?.title}");
  // Show local notification
});
```

### Listen to Background Messages

```dart
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📩 Background message: ${message.messageId}");
}
```

### Handle Notification Tap

```dart
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  print("📬 Notification tapped: ${message.notification?.title}");
});
```

## 🧪 Testing Notifications

### Method 1: Firebase Console (Easy)

1. **Copy FCM Token** from the app screen
2. Go to [Firebase Console](https://console.firebase.google.com/)
3. Select your project
4. Go to **Cloud Messaging** → **Send your first message**
5. Enter:
   - **Title:** `Hello Flutter`
   - **Body:** `This is a test notification`
6. Click **Send to a specific device**
7. Paste the FCM Token
8. Click **Send**

✅ Notification should appear in your app!

### Method 2: Using cURL (Advanced)

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "YOUR_FCM_TOKEN",
      "notification": {
        "title": "Test Title",
        "body": "Test Body"
      }
    }
  }' \
  https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send
```

### Method 3: Postman

1. Create POST request to:
   ```
   https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send
   ```

2. Headers:
   ```
   Authorization: Bearer YOUR_SERVER_KEY
   Content-Type: application/json
   ```

3. Body:
   ```json
   {
     "message": {
       "token": "YOUR_FCM_TOKEN",
       "notification": {
         "title": "Hello!",
         "body": "This is a test notification"
       },
       "data": {
         "key": "value"
       }
     }
   }
   ```

## 📁 Project Structure

```
NotifyVault_v1/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── firebase_options.dart     # Firebase configuration (auto-generated)
│   └── screens/
│       └── notification_home_screen.dart
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   ├── google-services.json  # Firebase config
│   │   └── src/main/AndroidManifest.xml
│   └── build.gradle
├── ios/
│   └── GoogleService-Info.plist  # Firebase config (iOS)
├── pubspec.yaml
├── .gitignore
└── README.md
```

## 🔐 Security & Best Practices

### Firebase Options File

**⚠️ IMPORTANT:** Never commit `firebase_options.dart` to GitHub!

Add to `.gitignore`:
```
firebase_options.dart
google-services.json
GoogleService-Info.plist
.env
```

### Permission Configuration

**Android:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

**iOS (ios/Runner/Info.plist):**
```xml
<key>UIUserInterfaceStyle</key>
<string>Light</string>
```

## 🐛 Troubleshooting

### Token Not Showing?

```bash
# Check if Firebase is initialized
flutter clean
flutter pub get
flutter run -v

# Check Firebase console
# - Project ID matches
# - Android app registered
# - google-services.json in correct location
```

### Notifications Not Received?

1. **Check Foreground Handler:**
   ```dart
   FirebaseMessaging.onMessage.listen((message) {
     print("✅ Received: ${message.notification?.title}");
   });
   ```

2. **Check Permissions:**
   - Go to Settings → Apps → NotifyVault
   - Enable "Notifications" permission

3. **Check Device:**
   - Ensure device is connected to internet
   - Check Firebase project is correct
   - Verify FCM token is valid

4. **Check Logs:**
   ```bash
   flutter logs
   ```

### "Failed to initialize Firebase"

```bash
# Regenerate Firebase options
flutterfire configure --reconfigure

# Or manually update firebase_options.dart with correct values
```

### Android 13+ Permission Issues

```dart
// The app handles this automatically
// Make sure permission_handler is installed
// Grant notification permission when prompted
```

## 📊 Console Output Example

```
🚀 Initializing Firebase...
✅ Firebase initialized
✅ Local notifications initialized
📱 Requesting notification permission...
📱 Setting foreground notification options...
🔑 FCM TOKEN: c3N_wZ2kQ...
════════════════════════════════════════
Copy this token to send notifications:
c3N_wZ2kQ...
════════════════════════════════════════
📱 Setting up foreground message listener...
✅ Firebase messaging initialized successfully
```

## 🎓 What You'll Learn

- ✅ Firebase project setup
- ✅ Flutter Firebase integration
- ✅ FCM token generation
- ✅ Notification handling in multiple states
- ✅ Local notifications display
- ✅ Permission handling
- ✅ Error handling and logging
- ✅ Testing notifications
- ✅ Best practices for production

## 🚀 Advanced Features

### Token Refresh Listener
```dart
messaging.onTokenRefresh.listen((newToken) {
  print("🔄 Token refreshed: $newToken");
  // Save new token to backend
});
```

### Custom Notification Channels
```dart
AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  'custom_channel_id',
  'Custom Channel',
  importance: Importance.max,
  priority: Priority.high,
);
```

### Data Messages (Background)
```dart
// Send from backend
{
  "message": {
    "token": "FCM_TOKEN",
    "data": {
      "action": "update_profile",
      "userId": "123"
    }
  }
}
```

## 📝 API Reference

### FirebaseMessaging Methods

| Method | Description |
|--------|-------------|
| `getToken()` | Get FCM token for device |
| `requestPermission()` | Request notification permission |
| `setForegroundNotificationPresentationOptions()` | Configure foreground display |
| `subscribeToTopic()` | Subscribe to a topic |
| `unsubscribeFromTopic()` | Unsubscribe from topic |

### Notification States

| State | When | Handler |
|-------|------|---------|
| **Foreground** | App is open | `onMessage` listener |
| **Background** | App is minimized | Background handler |
| **Terminated** | App is closed | `getInitialMessage()` |

## 🔄 Firebase Console Token

To find your Server Key:
1. Firebase Console → Project Settings
2. Service Accounts tab
3. Generate new private key (or use existing)
4. Use in Authorization header

## 📚 Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Guide](https://firebase.flutter.dev)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Notifications](https://flutter.dev/docs/development/packages-and-plugins/notifications)

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Fork the repository
- Create a feature branch
- Submit a pull request

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

Created for learning Firebase Cloud Messaging integration in Flutter.

---

## 🎯 Next Steps

1. ✅ Clone the repository
2. ✅ Set up Firebase project
3. ✅ Run the app
4. ✅ Get FCM token
5. ✅ Send test notification
6. ✅ See notification appear! 🎉

---

**Happy Learning! 🚀📲**

For questions or issues, please open a GitHub Issue or check the [Troubleshooting](#-troubleshooting) section.