import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

// Background Handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📩 Background message received: ${message.messageId}");
  print("📩 Title: ${message.notification?.title}");
  print("📩 Body: ${message.notification?.body}");
}

// Local Notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings settings =
      InitializationSettings(android: androidSettings, iOS: null);
  await flutterLocalNotificationsPlugin.initialize(settings);
  print('✅ Local notifications initialized');
}

// Notification Init
Future<void> notificationInit() async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    print('📱 Requesting notification permission...');
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('📱 Setting foreground notification options...');
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM Token
    String? token = await messaging.getToken();
    print("🔑 FCM TOKEN: $token");
    print("════════════════════════════════════════");
    print("Copy this token to send notifications:");
    print("$token");
    print("════════════════════════════════════════");

    // Listen for token refreshes
    messaging.onTokenRefresh.listen((String token) {
      print("🔄 Token refreshed: $token");
    });

    // Foreground message listener
    print('📱 Setting up foreground message listener...');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔥 FOREGROUND MESSAGE RECEIVED!");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("Message ID: ${message.messageId}");
      print("Data: ${message.data}");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        print("🔥 Showing local notification...");
        await flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel_id',
              'Default Channel',
              channelDescription:
                  'This channel is used for important notifications.',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
        print("✅ Local notification shown");
      } else {
        print("⚠️ No notification object found");
      }
    });

    // Background message handler
    print('📱 Setting background message handler...');
    FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("📬 NOTIFICATION TAPPED (App was in background)");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
      print("Data: ${message.data}");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    });

    // Check initial message (when app was terminated)
    RemoteMessage? initialMessage =
        await messaging.getInitialMessage();
    if (initialMessage != null) {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("📬 INITIAL MESSAGE (App was terminated)");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("Title: ${initialMessage.notification?.title}");
      print("Body: ${initialMessage.notification?.body}");
      print("Data: ${initialMessage.data}");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    }

    print('✅ Firebase messaging initialized successfully');
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
  }
}

// Main
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    print('🚀 Initializing Firebase...');
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized');
    } catch (e) {
      print('❌ Firebase init error: $e');
    }

    // Initialize local notifications first
    await initLocalNotifications();

    // Then initialize notification setup
    await notificationInit();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Notifications',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NotificationHomeScreen(),
    );
  }
}

class NotificationHomeScreen extends StatefulWidget {
  const NotificationHomeScreen({Key? key}) : super(key: key);

  @override
  State<NotificationHomeScreen> createState() =>
      _NotificationHomeScreenState();
}

class _NotificationHomeScreenState extends State<NotificationHomeScreen> {
  String? fcmToken;
  List<String> receivedMessages = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Get initial token
    String? token = await messaging.getToken();
    setState(() {
      fcmToken = token;
    });

    // Listen to messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        receivedMessages.add(
          "${message.notification?.title}: ${message.notification?.body}",
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Notifications"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FCM Token Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "🔑 FCM Token",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    fcmToken != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: SelectableText(
                                  fcmToken!,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Token copied to clipboard"),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy),
                                label: const Text("Copy Token"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                              ),
                            ],
                          )
                        : const CircularProgressIndicator(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Instructions Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "📝 How to Send Test Notification",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "1. Copy the FCM Token above\n"
                      "2. Go to Firebase Console\n"
                      "3. Cloud Messaging → Send your first message\n"
                      "4. Enter Title and Body\n"
                      "5. Under 'Send to' select 'Individual device'\n"
                      "6. Paste the FCM Token\n"
                      "7. Click 'Send'\n\n"
                      "The notification will appear in this app!",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Messages Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "💬 Received Messages",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (receivedMessages.isEmpty)
                      const Text(
                        "No messages received yet...",
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: receivedMessages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.green.shade300,
                                ),
                              ),
                              child: Text(
                                receivedMessages[index],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}