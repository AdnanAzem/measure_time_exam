import 'package:excel_example/button_config.dart';
import 'package:excel_example/final_page.dart';
import 'package:excel_example/styled_button.dart';
import 'package:excel_example/user_form_widget.dart';
import 'package:excel_example/user_sheets_api.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

bool pressedButton = false;

class _GamePageState extends State<GamePage> {
  Timer? _timer;
  Timer? _timer1;

  List<List<dynamic>> dataToWrite = [
    [
      'quesion',
      'answer',
      'response time from holding until the circles appearce',
      'response time from the realesing until pressing the answer'
    ]
  ];

  List<List<dynamic>> dataFromCSV = [];

  String blackImg = 'assets/gifs/black.gif';
  String veryGoodImg = 'assets/gifs/goodjob.gif';
  String wrongImg = 'assets/gifs/wronganswer.gif';

  int startTime = 0;
  int endTime = 0;

  int correctAnswers = 0;
  int wrongAnswers = 0;
  Color containerColor = Colors.grey;
  int responseTimeOfAnswer = 0;
  int responseTimeOfHolding = 0;

  int index = 0;
  String answer = '';
  Color lefttCircleColor = Colors.black;
  Color rightCircleColor = Colors.black;
  String centerImage = 'assets/gifs/black.gif';
  Color arrowColor = Colors.black;
  Icon centerArrow = const Icon(
    Icons.arrow_forward,
    color: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    index = 0;
    loadCSV();
  }

  Future<void> saveDataToCSV() async {
    List<List<dynamic>> data = dataToWrite;

    final directory = (await getApplicationDocumentsDirectory());
    final String path = directory.path;

    final csvFilePath = "$path/$name.csv";

    // Create a File instance and open it for writing.
    File file = File(csvFilePath);
    IOSink sink = file.openWrite();

    // Create a CSV converter and write the data to the file.
    String csvData = const ListToCsvConverter().convert(data);
    sink.write(csvData);

    // Close the file when done writing.
    await sink.flush();
    await sink.close();
  }

  void _cancelTimer() {
    _timer?.cancel();
  }

  void _cancelTimer1() {
    _timer1?.cancel();
  }

  Future<void> loadCSV() async {
    String path = 'assets/data/exam1.csv';
    if (type == 2) {
      path = 'assets/data/exam2.csv';
    }
    final rawData = await rootBundle.loadString(path);
    final List<List<dynamic>> csvTable =
        const CsvToListConverter().convert(rawData);
    setState(() {
      dataFromCSV = csvTable;
    });
  }

  void fillInfo() {
    // question(0)	leftCircle(1)	rightCircle(2)	image(3)	arrowDirect(4)	arrowColor(5)	answer(6)

    int len = dataFromCSV.length;
    // dataFromCSV.removeAt(0);
    setState(() {
      if (index < len) {
        // left circle color
        dataFromCSV[index][1] == 'red'
            ? lefttCircleColor = Colors.red
            : lefttCircleColor = Colors.green;

        // right circle color
        dataFromCSV[index][2] == 'red'
            ? rightCircleColor = Colors.red
            : rightCircleColor = Colors.green;

        // image (arrows OR rainbow)
        dataFromCSV[index][3] == 'arrow'
            ? centerImage = 'assets/gifs/arrows.gif'
            : centerImage = 'assets/gifs/rainbow-clouds.gif';

        // arrow direction & color
        if (dataFromCSV[index][4] == 'left' && dataFromCSV[index][5] == 'red') {
          centerArrow = const Icon(
            Icons.arrow_back,
            color: Colors.red,
            size: 50,
          );
        } else if (dataFromCSV[index][4] == 'left' &&
            dataFromCSV[index][5] == 'green') {
          centerArrow = const Icon(
            Icons.arrow_back,
            color: Colors.green,
            size: 50,
          );
        } else if (dataFromCSV[index][4] == 'right' &&
            dataFromCSV[index][5] == 'red') {
          centerArrow = const Icon(
            Icons.arrow_forward,
            color: Colors.red,
            size: 50,
          );
        } else {
          centerArrow = const Icon(
            Icons.arrow_forward,
            color: Colors.green,
            size: 50,
          );
        }

        dataFromCSV[index][6] == 'left' ? answer = 'left' : answer = 'right';
      }
    });
  }

  void _handleCenterButtonPressDown() {
    _timer1 = Timer(const Duration(seconds: 3), () {
      startTime = DateTime.now().microsecondsSinceEpoch;
      setState(() {
        pressedButton = true;
        index++;
      });
    });
    _timer = Timer(const Duration(seconds: 2), () {
      setState(() {
        fillInfo();
      });
    });
  }

  void _handleCenterButtonPressUp() {
    _cancelTimer();
    _cancelTimer1();
    setState(() {
      endTime = DateTime.now().microsecondsSinceEpoch;
      // isButtonPressed = false;
      // print("the time when the user released the center button: $endTime");
      int timeOfHoldingTheButton = endTime - startTime;
      responseTimeOfHolding = timeOfHoldingTheButton;
      // print("response time from holding until the circles appearce:$time_of_holding_the_button");
    });
  }

  void _handleOneOfTheCircelsIsPressed() {
    if (endTime > startTime) {
      int elapsedNanoseconds = DateTime.now().microsecondsSinceEpoch - endTime;
      responseTimeOfAnswer = elapsedNanoseconds;
      // print("response time: $elapsedNanoseconds microseconds");
    }
    setState(() {
      pressedButton = false;
      centerArrow = const Icon(
        Icons.arrow_back,
        color: Colors.black,
      );
      Future.delayed(const Duration(milliseconds: 100), () {
        centerImage = blackImg;
      });
    });
  }

  Future<ButtonConfig> loadButtonConfig() async {
    String jsonString =
        await rootBundle.loadString('assets/buttons/red_button.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    if (index < dataFromCSV.length) {
      if (dataFromCSV[index][1] == 'red') {
        return ButtonConfig.fromJson(jsonMap);
      } else if (dataFromCSV[index][1] == 'green') {
        jsonString =
            await rootBundle.loadString('assets/buttons/green_button.json');
        jsonMap = json.decode(jsonString);
        return ButtonConfig.fromJson(jsonMap);
      }
    }
    return ButtonConfig.fromJson(jsonMap);
  }

  Future<ButtonConfig> loadButtonConfig1() async {
    String jsonString =
        await rootBundle.loadString('assets/buttons/green_button.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    if (index < dataFromCSV.length) {
      if (dataFromCSV[index][2] == 'green') {
        return ButtonConfig.fromJson(jsonMap);
      } else if (dataFromCSV[index][2] == 'red') {
        jsonString =
            await rootBundle.loadString('assets/buttons/red_button.json');
        jsonMap = json.decode(jsonString);
        return ButtonConfig.fromJson(jsonMap);
      }
    }
    return ButtonConfig.fromJson(jsonMap);
  }

  FutureBuilder<ButtonConfig> getRightCircle() {
    String result = 'right';
    return FutureBuilder<ButtonConfig>(
      future: loadButtonConfig1(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final buttonConfig = snapshot.data!;
          return StyledButton(
            buttonConfig: buttonConfig,
            onPressed: () async {
              final lastRow = await UserSheetsApi.getRowCount();
              setState(() {
                if (result != answer) {
                  UserSheetsApi.updateCell(
                    id: lastRow,
                    key: 'wrongAnswers',
                    value: ++wrongAnswers,
                  );
                  centerImage = wrongImg;
                  _handleOneOfTheCircelsIsPressed();
                  dataToWrite.add([
                    index, 
                    'wrong',
                    responseTimeOfHolding,
                    responseTimeOfAnswer
                  ]);
                }
                else {
                  // correct answer
                  UserSheetsApi.updateCell(
                    id: lastRow,
                    key: 'correctAnswers',
                    value: ++correctAnswers,
                  );
                  _handleOneOfTheCircelsIsPressed();
                  dataToWrite.add([
                    index, 
                    'correct',
                    responseTimeOfHolding,
                    responseTimeOfAnswer
                  ]);
                  centerImage = veryGoodImg;
                }
                startTime = 0;
                endTime = 0;
              });
            },
          );
        }
      },
    );
  }


  FutureBuilder<ButtonConfig> getLeftCircle() {
    String result = 'left';
    return FutureBuilder<ButtonConfig>(
      future: loadButtonConfig(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final buttonConfig = snapshot.data!;
          return StyledButton(
            buttonConfig: buttonConfig,
            onPressed: () async {
              final last = await UserSheetsApi.getRowCount();
              setState(() {
                if (result != answer) {
                  UserSheetsApi.updateCell(
                    id: last,
                    key: 'wrongAnswers',
                    value: ++wrongAnswers,
                  );
                  _handleOneOfTheCircelsIsPressed();
                  dataToWrite.add([
                    index, 
                    'wrong',
                    responseTimeOfHolding,
                    responseTimeOfAnswer
                  ]);
                  centerImage = wrongImg;
                }
                else {
                  // correct answer
                  UserSheetsApi.updateCell(
                    id: last,
                    key: 'correctAnswers',
                    value: ++correctAnswers,
                  );
                  _handleOneOfTheCircelsIsPressed();
                  dataToWrite.add([
                    index, 
                    'correct',
                    responseTimeOfHolding,
                    responseTimeOfAnswer
                  ]);
                  centerImage = veryGoodImg;
                }
                startTime = 0;
                endTime = 0;
              });
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trial $index out of 30',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: getLeftCircle(),
            ),
          ),
          Expanded(
            flex: 6,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    child: Container(
                      width: 200,
                      height: 200,
                      // child: Image.network(randomPhoto),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              centerImage), //AssetImage(randomPhoto),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: centerArrow, //randomArrow,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Material(
                      color:
                          containerColor, // This sets the color when not pressed
                      borderRadius: BorderRadius.circular(100),
                      child: InkWell(
                        onTapDown: (_) {
                          setState(() {
                            _handleCenterButtonPressDown();
                            containerColor = Colors.purple;
                            if (index >= 30) {
                              saveDataToCSV();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const FinalPage(),
                                ),
                              );
                              // index++;
                            }
                          });
                        },
                        onTapUp: (_) {
                          setState(() {
                            _handleCenterButtonPressUp();
                            containerColor = Colors.grey;
                          });
                        },
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF8636FF), Color(0xFF6D2BFF)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6D2BFF).withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                              BoxShadow(
                                color: const Color(0xFF8636FF).withOpacity(0.5),
                                spreadRadius: -2,
                                blurRadius: 10,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "Hold Me!",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: getRightCircle(),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
