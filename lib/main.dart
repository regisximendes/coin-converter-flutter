import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.lightBlue,
        primaryColor: Colors.lightBlue,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlue)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlue)),
          hintStyle: TextStyle(color: Colors.lightBlue),
        )),
  ));
}

Future<Map> fetchApiData() async {
  http.Response response = await http.get(
      "https://api.hgbrasil.com/finance?format=json-cors&key=YOUR_API_KEY");
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  var dollar;
  var euro;

  void _onRealChanged(String text) {
    var real = double.parse(text);
    dollarController.text = (real / dollar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _onDollarChanged(String text) {
    var dollar = double.parse(text);
    realController.text = (dollar * this.dollar).toStringAsFixed(2);
    euroController.text = (dollar * this.dollar / euro).toStringAsFixed(2);
  }

  void _onEuroChanged(String text) {
    var euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dollarController.text = (euro * this.euro / dollar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text("Coin Converter"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: fetchApiData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text("Loading...",
                      style: TextStyle(fontSize: 25.0, color: Colors.lightBlue),
                      textAlign: TextAlign.center),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Something wrong happen try later",
                        style:
                            TextStyle(fontSize: 25.0, color: Colors.lightBlue),
                        textAlign: TextAlign.center),
                  );
                } else {
                  dollar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on,
                            size: 100.0, color: Colors.lightBlue),
                        Divider(),
                        buildTextFieldWidget(
                            "Reais", realController, _onRealChanged),
                        Divider(),
                        buildTextFieldWidget(
                            "Dollar", dollarController, _onDollarChanged),
                        Divider(),
                        buildTextFieldWidget(
                            "Euro", euroController, _onEuroChanged)
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextFieldWidget(
    String hint, TextEditingController controller, Function fun) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(color: Colors.lightBlue),
        border: OutlineInputBorder()),
    style: TextStyle(fontSize: 20.0),
    onChanged: fun,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
