import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:notifly_flutter/notifly_flutter.dart';
import 'package:notifly_flutter_example/firebase_options.dart';
import 'package:notifly_flutter_example/src/DetailPage.dart';
import 'package:notifly_flutter_example/src/HomePage.dart';
import 'package:uni_links/uni_links.dart';

void main() async {
  await dotenv.load();

  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await initializeApp();
    DeeplinkHandler();
  }

  runApp(const MyApp());
}

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

Future<void> setupInteractedMessage() async {
  // Get any messages which caused the application to open from
  // a terminated state.
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  // If the message also contains a data property with a x"type" of "chat",
  // navigate to a chat screen
  if (initialMessage != null) {
    print(
        '🔥 [NotiflyFlutterPackage]: Received a message on app startup: ${initialMessage.data.toString()}');
  }

  // Also handle any interaction when the app is in the background via a
  // Stream listener
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print(
        '🔥 [NotiflyFlutterPackage]: Message opened app: ${message.data.toString()}');
  });
}

Future<void> initializeApp() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(
        '🔥 [NotiflyFlutterPackage]: Received a foreground message: ${message.data.toString()}');
  });

  // Android only
  if (!kIsWeb && Platform.isAndroid) {
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
      '🔥 [NotiflyFlutterPackage]: Received a background message: ${message.data.toString()}');
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<InAppMessageEvent>? _inAppEventSubscription;

  Future<void> initNotifly() async {
    WidgetsFlutterBinding.ensureInitialized();

    await NotiflyPlugin.initialize(
      projectId: dotenv.env['NOTIFLY_PROJECT_ID']!,
      username: dotenv.env['NOTIFLY_USERNAME']!,
      password: dotenv.env['NOTIFLY_PASSWORD']!,
    );

    print('🔥 [Flutter] NotiflyPlugin initialized');
    if (kIsWeb) {
      await NotiflyPlugin.requestPermission();
    }

    if (!kIsWeb && Platform.isAndroid) {
      await NotiflyPlugin.addNotificationClickListener((notification) {
        print(
            '🔥 [NotiflyFlutterPackage]: Notification clicked: ${notification.notification.title}');
        print(
            '🔥 [NotiflyFlutterPackage]: Notification clicked: ${notification.notification.body}');
        print(
            '🔥 [NotiflyFlutterPackage]: Notification clicked: ${notification.notification.customData}');
      });
    }

    // Subscribe to in-app message events
    if (!kIsWeb) {
      _subscribeToInAppEvents();
    }
  }

  void _subscribeToInAppEvents() {
    _inAppEventSubscription = NotiflyPlugin.inAppEvents.listen(
      (event) {
        print('🔥 [TEST] In-App Event Received:');
        print('  Event Name: ${event.eventName}');
        print('  Event Params: ${event.eventParams}');
        print('  ---');
      },
      onError: (error) {
        print('🔥 [TEST] In-App Event Error: $error');
      },
    );
    print('🔥 [TEST] In-App Event Listener: Subscribed');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }

  @override
  void dispose() {
    _inAppEventSubscription?.cancel();
    print('🔥 [TEST] In-App Event Listener: Subscription cancelled');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initNotifly();
    if (!kIsWeb) {
      setupInteractedMessage();
    }
  }
}
