import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

enum Operation {
  Add,
  Multiply,
  Divide,
  Subtract,
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FaCozy POC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in a Flutter IDE). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: CalculationScreen(),
    );
  }
}

class CalculationScreen extends StatefulWidget {
  @override
  _CalculationScreenState createState() => _CalculationScreenState();
}

class _CalculationScreenState extends State<CalculationScreen> {
  final _methodChannel = const MethodChannel('fa_cozy_method_channel');

  Operation _currentOperation = Operation.Add;

  int _num1 = 0;
  int _num2 = 0;

  @override
  void initState() {
    super.initState();
    _methodChannel.setMethodCallHandler(_onMethodCall);
  }

  Future<void> _onMethodCall(MethodCall call) async {
    print(call);
    try {
      print(call);
      if (call.method == "FromHostToClient") {
        final String data = call.arguments;
        final jData = json.decode(data);

        setState(() {
          _num1 = jData['num1'];
          _num2 = jData['num2'];
        });
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }

  void _sendResultsToHost() {
    final _result = {
      Operation.Add: _num1 + _num2,
      Operation.Multiply: _num1 * _num2,
      Operation.Subtract: _num1 - _num2,
      Operation.Divide: _num1 / _num2,
    }[_currentOperation];

    final resultMap = {'operation': _currentOperation.index, 'result': _result};

    _methodChannel.invokeMethod("FromClientToHost", resultMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Flutter Module')),
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
