import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:notifly_flutter/notifly_flutter.dart';
import 'package:notifly_flutter_example/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';

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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final status = await Permission.notification.status;
  if (status.isDenied) {
    await Permission.notification.request();
  }

  await NotiflyPlugin.initialize(
    projectId: dotenv.env['NOTIFLY_PROJECT_ID']!,
    username: dotenv.env['NOTIFLY_USERNAME']!,
    password: dotenv.env['NOTIFLY_PASSWORD']!,
  );

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class DetailPage extends StatelessWidget {
  const DetailPage({
    required this.id,
    super.key,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Route id: $id')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Route id: $id'),
            ElevatedButton(
              onPressed: () {
                router.go('/');
              },
              child: const Text('Go to home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _userIdTextInputController =
      TextEditingController();
  final TextEditingController _userPropertiesKeyInputController =
      TextEditingController();
  final TextEditingController _userPropertiesValueInputController =
      TextEditingController();
  final TextEditingController _eventNameInputController =
      TextEditingController();
  final TextEditingController _eventParamsKeyInputController =
      TextEditingController();
  final TextEditingController _eventParamsValueInputController =
      TextEditingController();
  final TextEditingController _routeIdInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Unfocus the text fields when tapped outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('NotiflyFlutter Example')),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _userIdTextInputController,
                    decoration: const InputDecoration(
                      labelText: 'User Id',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final userIdInput = _userIdTextInputController.text;
                      await NotiflyPlugin.setUserId(userIdInput);
                      _showMessage('User Id successfully set to $userIdInput');
                    } catch (error) {
                      _showError(error);
                    }
                  },
                  child: const Text('Set User Id'),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: TextField(
                          controller: _userPropertiesKeyInputController,
                          decoration: const InputDecoration(
                            labelText: 'Key',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: TextField(
                          controller: _userPropertiesValueInputController,
                          decoration: const InputDecoration(
                            labelText: 'Value',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final key = _userPropertiesKeyInputController.text;
                      final value = _userPropertiesValueInputController.text;
                      await NotiflyPlugin.setUserProperties({key: value});
                      _showMessage(
                        "User properties successfully set to {'$key': '$value'}",
                      );
                    } catch (error) {
                      _showError(error);
                    }
                  },
                  child: const Text('Set User Properties'),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _eventNameInputController,
                    decoration: const InputDecoration(
                      labelText: 'Event Name',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: TextField(
                          controller: _eventParamsKeyInputController,
                          decoration: const InputDecoration(
                            labelText: 'Key',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: TextField(
                          controller: _eventParamsValueInputController,
                          decoration: const InputDecoration(
                            labelText: 'Value',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final eventName = _eventNameInputController.text;
                      final key = _eventParamsKeyInputController.text;
                      final value = _eventParamsValueInputController.text;

                      if (key.isEmpty || value.isEmpty) {
                        await NotiflyPlugin.trackEvent(eventName: eventName);
                      } else {
                        await NotiflyPlugin.trackEvent(
                          eventName: eventName,
                          eventParams: {key: value},
                          segmentationEventParamKeys: <String>[key],
                        );
                      }

                      _showMessage('Event $eventName successfully tracked with '
                          'params {$key: $value}');
                    } catch (error) {
                      _showError(error);
                    }
                  },
                  child: const Text('Track Event'),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _routeIdInputController,
                    decoration: const InputDecoration(
                      labelText: 'Route Id',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final routePathId = _routeIdInputController.text;
                    if (routePathId.contains('/')) {
                      _showError('Route Id cannot contain "/"');
                      return;
                    }
                    await GoRouter.of(context).push('/$routePathId');
                  },
                  child: const Text('Go!'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: Text(message),
      ),
    );
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text('$error'),
      ),
    );
  }

  @override
  void dispose() {
    _userIdTextInputController.dispose();
    _userPropertiesKeyInputController.dispose();
    _userPropertiesValueInputController.dispose();
    _eventNameInputController.dispose();
    _eventParamsKeyInputController.dispose();
    _eventParamsValueInputController.dispose();

    super.dispose();
  }
}
