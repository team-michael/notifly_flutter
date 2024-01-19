import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:notifly_flutter/notifly_flutter.dart';
import 'package:notifly_flutter_example/firebase_options.dart';
import 'package:notifly_flutter_example/src/DetailPage.dart';
import 'package:notifly_flutter_example/src/HomePage.dart';
import 'package:uni_links/uni_links.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/:id',
      builder: (context, state) {
        final pathId = state.pathParameters['id']!;
        return DetailPage(id: pathId);
      },
    )
  ],
);

void main() async {
  await dotenv.load();

  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await initializeApp();
    DeeplinkHandler();
  }

  await NotiflyPlugin.initialize(
    projectId: dotenv.env['NOTIFLY_PROJECT_ID']!,
    username: dotenv.env['NOTIFLY_USERNAME']!,
    password: dotenv.env['NOTIFLY_PASSWORD']!,
  );
  print('🔥 [Flutter] NotiflyPlugin initialized');
  await NotiflyPlugin.requestPermission();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}

class DeeplinkHandler {
  DeeplinkHandler() {
    final initialLink = getInitialLink()
        .then((link) => handleLink(link != null ? Uri.parse(link) : Uri()));
    linkStream.listen((link) {
      handleLink(link != null ? Uri.parse(link) : Uri());
    }, onError: (err) {
      print("🔥 ERROR " + err.toString());
    });
  }

  // Example: pushnotiflyflutter://navigation?routeId=123
  void handleLink(Uri link) {
    print('🔥 opened with URL ${link.toString()}');
    final scheme = link.scheme;
    final host = link.host;
    final queryParameters = link.queryParameters;
    if (scheme == "pushnotiflyflutter" && host == "navigation") {
      final routeId = queryParameters["routeId"];
      if (routeId != null) {
        router.go("/$routeId");
      }
    }
  }
}

Future<void> initializeApp() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Android only
  if (Platform.isAndroid) {
    await NotiflyPlugin.setLogLevel(2);
  }

  /* Firebase messaging request permission */
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print(
      '🔥 [Flutter]: Received a background message: ${message.data.toString()}');
}
