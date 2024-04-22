import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MaterialApp(
    title: 'Student Performance App',
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => MyForm(),
      '/dashboard': (context) => SubmittedDetailsPage(),
      '/admin': (context) => AdminPage(),
    },
    onUnknownRoute: (settings) {
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Error'),
          ),
          body: Center(
            child: Text('404 - Page not found'),
          ),
        ),
      );
    },
  ));
}

class MyForm extends StatefulWidget {
  const MyForm({Key? key}) : super(key: key);

  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _madController = TextEditingController();
  final TextEditingController _coaController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _webxController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student performance app'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/admin');
            },
            icon: Icon(Icons.account_box),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Enter Marks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              keyboardType: TextInputType.text,
            ),
            TextField(
              controller: _rollNoController,
              decoration: InputDecoration(labelText: 'Roll No'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _madController,
              decoration: InputDecoration(labelText: 'MAD Marks'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _coaController,
              decoration: InputDecoration(labelText: 'COA Marks'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _ipController,
              decoration: InputDecoration(labelText: 'IP Marks'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _webxController,
              decoration: InputDecoration(labelText: 'WEBX Marks'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitMarks,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submitMarks() async {
    final Map<String, dynamic> requestData = {
      'MAD': int.tryParse(_madController.text) ?? 0,
      'COA': int.tryParse(_coaController.text) ?? 0,
      'IP': int.tryParse(_ipController.text) ?? 0,
      'WEBX': int.tryParse(_webxController.text) ?? 0,
      'name': _nameController.text,
      'rollNo': _rollNoController.text,
    };

    final response = await http.post(
      Uri.parse('https://server2-oiod.onrender.com/submit'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      Navigator.pushNamed(
        context,
        '/dashboard',
        arguments: requestData,
      );
    } else {
      print('Failed to submit marks. Status code: ${response.statusCode}');
    }
  }
}

class SubmittedDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> submittedData =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Submitted Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Marks Bar Graph',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),

            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 20,
                  barTouchData: BarTouchData(
                    enabled: false,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      getTooltipItem: (
                          BarChartGroupData group,
                          int groupIndex,
                          BarChartRodData rod,
                          int rodIndex,
                          ) {
                        return BarTooltipItem(
                          rod.y.round().toString(),
                          TextStyle(color: Colors.black),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (value) =>
                      const TextStyle(color: Colors.black, fontSize: 14),
                      margin: 20,
                      getTitles: (double value) {
                        switch (value.toInt()) {
                          case 0:
                            return 'MAD';
                          case 1:
                            return 'COA';
                          case 2:
                            return 'IP';
                          case 3:
                            return 'WEBX';
                          default:
                            return '';
                        }
                      },
                    ),
                    leftTitles: SideTitles(showTitles: false),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(y: submittedData['MAD'] * 1.0, colors: [Colors.blue]),
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(y: submittedData['COA'] * 1.0, colors: [Colors.green]),
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(y: submittedData['IP'] * 1.0, colors: [Colors.orange]),
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(y: submittedData['WEBX'] * 1.0, colors: [Colors.red]),
                      ],
                      showingTooltipIndicators: [0],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> marksData = [];

  @override
  void initState() {
    super.initState();
    fetchMarksData();
  }

  Future<void> fetchMarksData() async {
    try {
      final response =
      await http.get(Uri.parse('https://server2-oiod.onrender.com/marks'));
      if (response.statusCode == 200) {
        setState(() {
          marksData = List<Map<String, dynamic>>.from(json.decode(response.body));
          // Sort marksData based on roll number
          marksData.sort((a, b) => int.parse(a['rollNo']).compareTo(int.parse(b['rollNo'])));
        });
      } else {
        print('Failed to fetch marks data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching marks data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: marksData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: marksData.length,
        itemBuilder: (context, index) {
          final marks = marksData[index];
          return Column(
            children: [
              ListTile(
                title: Text('Name: ${marks['name']}'),
                subtitle: Text('Roll No: ${marks['rollNo']}'),
                trailing: Text('Total Marks: ${marks['MAD'] + marks['COA'] + marks['IP'] + marks['WEBX']}'),
              ),
              SizedBox(height: 40),

              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 20,
                    barTouchData: BarTouchData(
                      enabled: false,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.transparent,
                        tooltipPadding: EdgeInsets.zero,
                        getTooltipItem: (
                            BarChartGroupData group,
                            int groupIndex,
                            BarChartRodData rod,
                            int rodIndex,
                            ) {
                          return BarTooltipItem(
                            rod.y.round().toString(),
                            TextStyle(color: Colors.black),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: SideTitles(
                        showTitles: true,
                        getTextStyles: (value) =>
                        const TextStyle(color: Colors.black, fontSize: 14),
                        margin: 20,
                        getTitles: (double value) {
                          switch (value.toInt()) {
                            case 0:
                              return 'MAD';
                            case 1:
                              return 'COA';
                            case 2:
                              return 'IP';
                            case 3:
                              return 'WEBX';
                            default:
                              return '';
                          }
                        },
                      ),
                      leftTitles: SideTitles(showTitles: false),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(y: marks['MAD'] * 1.0, colors: [Colors.blue]),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(y: marks['COA'] * 1.0, colors: [Colors.green]),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(y: marks['IP'] * 1.0, colors: [Colors.orange]),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                      BarChartGroupData(
                        x: 3,
                        barRods: [
                          BarChartRodData(y: marks['WEBX'] * 1.0, colors: [Colors.red]),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
