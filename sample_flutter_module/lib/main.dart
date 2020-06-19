import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samplefluttermodule/channel_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

enum Operation {
  Add,
  Multiply,
  Divide,
  Subtract,
}

class _Routes {
  static const String SPLASH = '/';
  static const String CALCULATION = '/calculation';
  static const String NETWORK_CALL = '/network_call';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SPLASH:
        return MaterialPageRoute(
          settings: const RouteSettings(name: SPLASH),
          builder: (_) => Scaffold(
            body: Center(child: Text('SPLASH')),
          ),
        );
      case CALCULATION:
        return MaterialPageRoute(
          settings: const RouteSettings(name: CALCULATION),
          builder: (_) {
            final args = settings.arguments as Map;
            final num1 = args["num1"];
            final num2 = args["num2"];
            return CalculationScreen(num1: num1, num2: num2);
          },
        );
      case NETWORK_CALL:
        return MaterialPageRoute(
          settings: const RouteSettings(name: NETWORK_CALL),
          builder: (_) => NetworkCallScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _myAppNavigatorKey = GlobalKey<NavigatorState>();
  Completer<String> initialRouteCompleter = Completer();

  @override
  void initState() {
    super.initState();
    ChannelHandler.setMethodCallHandler(_onMethodCall);
  }

  Future<void> _onMethodCall(MethodCall call) async {
    print(call);
    try {
      if (call.method == "SetInitialRoute") {
        final data = call.arguments;
        Map args;
        final jData = json.decode(data);
        print(jData);
        final route = jData["InitialRoute"];
        if (jData["Arguments"] != null) {
          final aData = json.decode(jData["Arguments"]);
          print(aData);
          args = aData;
        }
        _myAppNavigatorKey.currentState.pushNamedAndRemoveUntil(
          route,
          (_) => false,
          arguments: args,
        );
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FaCozy POC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      navigatorKey: _myAppNavigatorKey,
      onGenerateRoute: _Routes.generateRoute,
    );
  }
}

class CalculationScreen extends StatefulWidget {
  final int num1;
  final int num2;

  const CalculationScreen({
    Key key,
    @required this.num1,
    @required this.num2,
  }) : super(key: key);

  @override
  _CalculationScreenState createState() => _CalculationScreenState();
}

class _CalculationScreenState extends State<CalculationScreen> {
  Operation _currentOperation = Operation.Add;

  int _num1 = 0;
  int _num2 = 0;

  @override
  void initState() {
    super.initState();
    _num1 = widget.num1;
    _num2 = widget.num2;
  }

  void _sendResultsToHost() {
    final _result = {
      Operation.Add: _num1 + _num2,
      Operation.Multiply: _num1 * _num2,
      Operation.Subtract: _num1 - _num2,
      Operation.Divide: _num1 / _num2,
    }[_currentOperation];

    final resultMap = {'operation': _currentOperation.index, 'result': _result};

    ChannelHandler.invokeMethod("CalculationResult", resultMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Calculator Screen')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'First Number: ',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        Text(
                          _num1.toString(),
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ])),
              Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Second Number: ',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        Text(
                          _num2.toString(),
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ])),
              Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      DropdownButton<Operation>(
                        value: _currentOperation,
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                        items: Operation.values
                            .map<DropdownMenuItem<Operation>>((operation) {
                          return DropdownMenuItem<Operation>(
                            value: operation,
                            child: Text({
                              Operation.Add: 'Add',
                              Operation.Multiply: 'Multiply',
                              Operation.Subtract: 'Subtract',
                              Operation.Divide: 'Divide',
                            }[operation]),
                          );
                        }).toList(),
                        onChanged: (operation) {
                          setState(() => _currentOperation = operation);
                        },
                      )
                    ],
                  )),
              RaisedButton(
                onPressed: _sendResultsToHost,
                textColor: Colors.white,
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.blue),
                  padding: const EdgeInsets.all(10.0),
                  child: const Text(
                    'Send Results back to Android module',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

class NetworkCallScreen extends StatefulWidget {
  @override
  _NetworkCallScreenState createState() => _NetworkCallScreenState();
}

class _NetworkCallScreenState extends State<NetworkCallScreen> {
  bool isFetching = false;

  void _fetchData() async {
    setState(() {
      isFetching = true;
    });
    final data = await Dio().get("https://api.ipify.org/?format=json");
    setState(() {
      isFetching = false;
    });
    final resultMap = {'ip': data.data["ip"]};
    ChannelHandler.invokeMethod("NetworkCallResult", resultMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Network Call Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            if (isFetching) CircularProgressIndicator(),
            RaisedButton(
              onPressed: _fetchData,
              textColor: Colors.white,
              padding: const EdgeInsets.all(0.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.blue),
                padding: const EdgeInsets.all(10.0),
                child: const Text(
                  'Fetch and Send Results back to Android module',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
