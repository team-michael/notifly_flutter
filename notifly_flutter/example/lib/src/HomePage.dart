import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notifly_flutter/notifly_flutter.dart';

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
      print(value.split(','));
      return value.split(',');
    default:
      throw ArgumentError('Invalid type: $type');
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class KeyValueInput extends StatefulWidget {

  KeyValueInput({required this.keyController, required this.valueController, required this.valueTypes, super.key,
    this.selectedValueType,
  });
  final TextEditingController keyController;
  final TextEditingController valueController;
  final List<String> valueTypes;
  String? selectedValueType;

  @override
  _KeyValueInputState createState() => _KeyValueInputState();

  Map<String, Object> getKeyValue() {
    return {
      keyController.text: _castValue(valueController.text, selectedValueType),
    };
  }
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _userIdTextInputController =
      TextEditingController();
  final TextEditingController _userPropertiesKeyInputController =
      TextEditingController();
  final TextEditingController _userEmailInputController =
      TextEditingController();
  final TextEditingController _userPhoneNumberInputController =
      TextEditingController();
  final TextEditingController _userTimezoneInputController =
      TextEditingController();
  final TextEditingController _userPropertiesValueInputController =
      TextEditingController();
  final TextEditingController _eventNameInputController =
      TextEditingController();
  final valueTypes = ['TEXT', 'INT', 'BOOL', 'ARRAY'];
  final List<KeyValueInput> _eventParamsInputs = [
    KeyValueInput(
      keyController: TextEditingController(),
      valueController: TextEditingController(),
      valueTypes: const [
        'TEXT',
        'INT',
        'BOOL',
        'ARRAY',
      ],
    ),
  ];

  final TextEditingController _routeIdInputController = TextEditingController();

  String? _selectedValueType;
  bool _useSegmentationKey = false;

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
                FutureBuilder<String?>(
                  future: NotiflyPlugin.getNotiflyUserId(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notifly User ID',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          snapshot.hasError ? 'Error: ${snapshot.error}' : '${snapshot.data}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  },
                ),
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
                      await NotiflyPlugin.requestPermission();

                      if (userIdInput.isEmpty) {
                        await NotiflyPlugin.setUserId(null);
                        _showMessage('User Id successfully unset');
                        return;
                      }

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
                  child: TextField(
                    controller: _userEmailInputController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final emailInput = _userEmailInputController.text;
                      if (emailInput.isEmpty) {
                        _showError('Email cannot be empty');
                        return;
                      }
                      await NotiflyPlugin.setEmail(emailInput);
                      _showMessage(
                          'User email successfully set to $emailInput',);
                    } catch (error) {
                      _showError(error);
                    }
                  },
                  child: const Text('Set Email'),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _userPhoneNumberInputController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final phoneNumberInput =
                          _userPhoneNumberInputController.text;
                      if (phoneNumberInput.isEmpty) {
                        _showError('Email cannot be empty');
                        return;
                      }
                      await NotiflyPlugin.setPhoneNumber(phoneNumberInput);
                      _showMessage(
                          'User phone number successfully set to $phoneNumberInput',);
                    } catch (error) {
                      _showError(error);
                    }
                  },
                  child: const Text('Set Phone Number'),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _userTimezoneInputController,
                    decoration: const InputDecoration(
                      labelText: 'Timezone',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final timezone = _userTimezoneInputController.text;
                      if (timezone.isEmpty) {
                        _showError('Timezone cannot be empty');
                        return;
                      }
                      await NotiflyPlugin.setTimezone(timezone);
                      _showMessage(
                          'User timezone successfully set to $timezone',);
                    } catch (error) {
                      _showError(error);
                    }
                  },
                  child: const Text('Set Timezone'),
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
                        value: _selectedValueType ?? valueTypes[0],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedValueType = newValue;
                          });
                        },
                        items: valueTypes.map((String value) {
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
                  padding: const EdgeInsets.all(10), // 패딩 추가
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10), // 마진 추가
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _eventParamsInputs.add(KeyValueInput(
                            keyController: TextEditingController(),
                            valueController: TextEditingController(),
                            valueTypes: valueTypes,
                          ),);
                        });
                      },
                      child: const Text('Add Event Param',
                          style: TextStyle(fontSize: 16),),
                    ),
                  ),
                ),

                //  params input
                ElevatedButton(
                  onPressed: () {
                    setState(_eventParamsInputs.removeLast);
                  },
                  child: const Text('Remove Event Param'),
                ), // add event params input
                ..._eventParamsInputs.map((input) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: input,
                  );
                }),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final eventName = _eventNameInputController.text;
                      final segmentationKey = _useSegmentationKey
                          ? _eventParamsInputs[0].keyController.text
                          : null;

                      final eventParams = _eventParamsInputs.isNotEmpty
                          ? _eventParamsInputs
                              .map((input) => input.getKeyValue())
                              .reduce(
                                (value, element) => value..addAll(element),
                              )
                          : null;

                      await NotiflyPlugin.trackEvent(
                        eventName: eventName,
                        eventParams: eventParams,
                        segmentationEventParamKeys:
                            (_useSegmentationKey && eventParams != null)
                                ? eventParams.keys.toList()
                                : null,
                      );

                      _showMessage('Event $eventName successfully tracked');
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

  @override
  void dispose() {
    _userIdTextInputController.dispose();
    _userPropertiesKeyInputController.dispose();
    _userPropertiesValueInputController.dispose();
    _eventNameInputController.dispose();
    for (final input in _eventParamsInputs) {
      input.keyController.dispose();
      input.valueController.dispose();
    }
    _routeIdInputController.dispose();

    super.dispose();
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text('$error'),
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
}

class _KeyValueInputState extends State<KeyValueInput> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          child: TextField(
            controller: widget.keyController,
            decoration: const InputDecoration(
              labelText: 'Key',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: TextField(
            controller: widget.valueController,
            decoration: const InputDecoration(
              labelText: 'Value',
            ),
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: widget.selectedValueType ?? widget.valueTypes[0],
          onChanged: (String? newValue) {
            setState(() {
              widget.selectedValueType = newValue;
            });
          },
          items: widget.valueTypes.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}
