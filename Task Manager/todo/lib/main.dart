import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/screens/welcome_screen.dart';
import 'package:todo/screens/task_home_screen.dart';
import 'package:todo/screens/settings_screen.dart';
import 'package:todo/screens/about_screen.dart';
import 'package:todo/screens/privacy_screen.dart';
import 'package:todo/screens/notifications_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todo/models/notification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        // Payload will be handled by WelcomeScreen
      }
    },
  );

  final NotificationAppLaunchDetails? notificationLaunchDetails =
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  String? initialPayload = notificationLaunchDetails?.didNotificationLaunchApp == true
      ? notificationLaunchDetails?.notificationResponse?.payload
      : null;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(initialPayload: initialPayload),
    ),
  );
}

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  final String? initialPayload;

  const MyApp({Key? key, this.initialPayload}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDoList',
      themeMode: Provider.of<ThemeNotifier>(context).themeMode,
      home: WelcomeScreen(initialNotificationPayload: initialPayload),
      routes: {
        '/taskHome': (context) => const TaskHomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/privacy': (context) => PrivacyScreen(),
        '/notificationSettings': (context) => NotificationsScreen(),
        '/about': (context) => AboutScreen(),
      },
    );
  }
}