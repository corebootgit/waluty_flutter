import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waluty',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Waluty'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<String> getData(String address) async {

  Uri myUri = Uri.parse(address);
  var response = await http.get(myUri);

  if (response.statusCode == 200) {
    return response.body;
  } else {
    print('Request failed with status: ${response.statusCode}.');
    return 'Error';
  }
}

var rate = '---';

class _MyHomePageState extends State<MyHomePage> {

  String dropdownValue = 'USD';
  String selected_date = '2022-01-01';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selected_date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print(selected_date);
    getRate(dropdownValue, selected_date);
  }

  void getRate(String currency, String date) async {
    String requestString = 'http://api.nbp.pl/api/exchangerates/rates/A/$currency/$date/?format=json';
    String response;
    var responseJson;

    print(requestString);

    response = await getData(requestString);

    if(response == 'Error')
    {
      responseJson = 'No data';
    }
    else
    {
      responseJson = json.decode(response)['rates'][0]['mid'].toString();
      print(responseJson);
    }

    setState(() {
      rate = responseJson;
    });
  }
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) async {
    selected_date = DateFormat('yyyy-MM-dd').format(args.value);
    getRate(dropdownValue, selected_date);

  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body:  Column(
        children: <Widget>[
          SfDateRangePicker(
          onSelectionChanged: _onSelectionChanged,
          selectionMode: DateRangePickerSelectionMode.single,
          initialSelectedDate: DateTime.now(),
          // initialSelectedRange: PickerDateRange(
          //     DateTime.now().subtract(const Duration(days: 4)),
          //     DateTime.now().add(const Duration(days: 3))),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(rate),

          DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.blue),
              underline: Container(
                height: 2,
                color: Colors.blueAccent,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                  getRate(dropdownValue, selected_date);
                });
              },
              items: <String>['USD', 'EUR', 'GBP', 'CNY', 'JPY', 'BGN']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ]
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
