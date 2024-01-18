import 'package:flutter/material.dart';
import 'package:notifly_flutter/notifly_flutter.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
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

  final List<String> _valueTypes = ['TEXT', 'INT', 'BOOL', 'ARRAY'];
  String? _selectedValueType;
  bool _useSegmentationKey = false;

  Object _castValue(String value, String? type) {
    switch (type) {
      case null:
        return value; // Default to TEXT
      case 'TEXT':
        return value;
      case 'INT':
        return int.parse(value);
      case 'BOOL':
        return value.toLowerCase() == 'true';
      case 'ARRAY':
        return value.split(',');
      default:
        throw ArgumentError('Invalid type: $type');
    }
  }

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
                      if (userIdInput.isEmpty) {
                        await NotiflyPlugin.setUserId(null);
                        _showMessage('User Id successfully unset');
                        return;
                      }
                      await NotiflyPlugin.requestPermission();
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
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _selectedValueType ?? _valueTypes[0],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedValueType = newValue;
                          });
                        },
                        items: _valueTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final key = _userPropertiesKeyInputController.text;
                      final value = _userPropertiesValueInputController.text;
                      final castedValue = _castValue(value, _selectedValueType);
                      await NotiflyPlugin.setUserProperties({key: castedValue});
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
                  padding: const EdgeInsets.all(8),
                  child: CheckboxListTile(
                    title: const Text(
                      'Use Key Segmentation',
                      style: TextStyle(fontSize: 16),
                    ),
                    value: _useSegmentationKey,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _useSegmentationKey = newValue ?? false;
                      });
                    },
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
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _selectedValueType ?? _valueTypes[0],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedValueType = newValue;
                          });
                        },
                        items: _valueTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
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
                        final castedValue =
                            _castValue(value, _selectedValueType);
                        await NotiflyPlugin.trackEvent(
                          eventName: eventName,
                          eventParams: {key: castedValue},
                          segmentationEventParamKeys:
                              _useSegmentationKey ? [key] : null,
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
    _routeIdInputController.dispose();

    super.dispose();
  }
}
