import 'package:excel_example/button_config.dart';
import 'package:excel_example/final_page.dart';
import 'package:excel_example/styled_button.dart';
import 'package:excel_example/user_form_widget.dart';
import 'package:excel_example/user_sheets_api.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  static Future<int> getLastRaw() async {
    final res = await UserSheetsApi.getRowCount() + 1;
    return res;
  }

  @override
  State<GamePage> createState() => _GamePageState();
}

List<List<dynamic>> dataToWrite = [
  [
    'quesion',
    'answer',
    'response time from holding until the circles appearce',
    'response time from the realesing until pressing the answer'
  ]
];

late Color redColor;
bool pressedButton = false;
bool isRed = false;
bool isRightArrow = false;
bool isRanbow = false;
int correctAnswers = 0;
int wrongAnswers = 0;
Color containerColor = Colors.grey;
int currentTimeInNanoseconds = getCurrentTimeInNanoseconds();
int previousTimeInNanoseconds = getCurrentTimeInNanoseconds();
int responseTimeOfAnswer = 0;
int responseTimeOfHolding = 0;
final random = Random();
int randomNumber = random.nextInt(2) + 1;

Future<void> saveDataToCSV() async {
  List<List<dynamic>> data = dataToWrite;

  final directory = (await getApplicationDocumentsDirectory());
  final String path = directory.path;

  final csvFilePath = "$path/csv-$name.csv";

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

// return the time in nanoseconds
int getCurrentTimeInNanoseconds() {
  int currentTimeMicroseconds = DateTime.now().microsecondsSinceEpoch;
  int currentTimeNanoseconds = currentTimeMicroseconds * 1000;
  return currentTimeNanoseconds;
}

int getTime(int time) {
  final currentTimeMicroseconds = DateTime.now().microsecondsSinceEpoch;
  final currentTimeNanoseconds = currentTimeMicroseconds * 1000;
  return currentTimeNanoseconds - time;
}

// return random arrow (left or right)
Icon getRandomArrow() {
  Random random = Random();
  int choice = random.nextInt(2);

  // Set the arrow icon based on the chosen choice
  IconData iconData = choice == 0 ? Icons.arrow_back : Icons.arrow_forward;
  choice == 0 ? isRightArrow = false : isRightArrow = true;
  Icon res = Icon(
    iconData,
    size: 50,
    color: getRandomRedOrGreenColor(),
  );
  return res;
}

// return random color (red or green)
Color getRandomRedOrGreenColor() {
  Random random = Random();

  // Generate a random number (0 or 1) to choose between red and green
  int choice = random.nextInt(2);

  // Set the color component values based on the chosen color
  int red = choice == 0 ? 255 : 0;
  int green = choice == 1 ? 255 : 0;
  int blue = 0; // Set blue to 0 for a pure red or green color

  choice == 0 ? isRed = true : isRed = false;

  // Create a Color object using the chosen color components
  Color color = Color.fromARGB(255, red, green, blue);
  return color;
}

// return random picture (rainbow or arrow)
String getRandomPhoto() {
  final List<String> photoAssets = [
    'assets/gifs/arrows.gif',
    'assets/gifs/rainbow-clouds.gif'
    // 'assets/images/arrows2.png',
    // 'assets/images/rainbow2.jpeg'
  ];

  Random random = Random();
  int randomIndex = random.nextInt(photoAssets.length);
  randomIndex == 0 ? isRanbow = false : isRanbow = true;
  return photoAssets[randomIndex];
}

class _GamePageState extends State<GamePage> {
  // bool isButtonPressed = false;
  Icon randomArrow = const Icon(
    Icons.arrow_back,
    color: Colors.black,
  );
  String blackImg = 'assets/gifs/black.gif';
  String veryGoodImg = 'assets/gifs/goodjob.gif';
  String wrongImg = 'assets/gifs/wronganswer.gif';
  String randomPhoto = 'assets/gifs/black.gif';
  
  // String blackImg = 'assets/images/black.png';
  // String veryGoodImg = 'assets/images/verygood.png';
  // String randomPhoto = 'assets/images/black.png';
  int startTime = 0;
  int endTime = 0;
  int round = 0;

  void _handleCenterButtonPressDown() {
    Future.delayed(const Duration(seconds: 2), () {
      startTime = DateTime.now().microsecondsSinceEpoch;
      setState(() {
        randomArrow = getRandomArrow();
        randomPhoto = getRandomPhoto();
        pressedButton = true;
        // isButtonPressed = true;
        // print("the time when the user pressed the center button: $startTime");
      });
    });
  }

  void _handleCenterButtonPressUp() {
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
      randomArrow = const Icon(
        Icons.arrow_back,
        color: Colors.black,
      );
      Future.delayed(const Duration(milliseconds: 100), () {
        randomPhoto = blackImg;
      });
    });
  }

  Future<ButtonConfig> loadButtonConfig() async {
    String jsonString =
        await rootBundle.loadString('assets/buttons/red_button.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    if (randomNumber == 1) {
      return ButtonConfig.fromJson(jsonMap);
    } else if (randomNumber == 2) {
      jsonString =
          await rootBundle.loadString('assets/buttons/green_button.json');
      jsonMap = json.decode(jsonString);
      return ButtonConfig.fromJson(jsonMap);
    }
    return ButtonConfig.fromJson(jsonMap);
  }

  Future<ButtonConfig> loadButtonConfig1() async {
    String jsonString =
        await rootBundle.loadString('assets/buttons/green_button.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    if (randomNumber == 1) {
      return ButtonConfig.fromJson(jsonMap);
    } else if (randomNumber == 2) {
      jsonString =
          await rootBundle.loadString('assets/buttons/red_button.json');
      jsonMap = json.decode(jsonString);
      return ButtonConfig.fromJson(jsonMap);
    }
    return ButtonConfig.fromJson(jsonMap);
  }

  FutureBuilder<ButtonConfig> getRightCircle() {
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
                if ((randomNumber == 1 && isRanbow && isRed) ||
                    (randomNumber == 1 && !isRanbow && !isRightArrow)) {
                  UserSheetsApi.updateCell(
                    id: lastRow,
                    key: 'wrongAnswers',
                    value: ++wrongAnswers,
                  );
                  randomPhoto = wrongImg;
                  _handleOneOfTheCircelsIsPressed();
                  dataToWrite.add([
                    round,
                    'wrong',
                    responseTimeOfHolding,
                    responseTimeOfAnswer
                  ]);
                } else if ((randomNumber == 2 && !isRanbow && !isRightArrow) ||
                    (randomNumber == 2 && isRanbow && !isRed)) {
                  UserSheetsApi.updateCell(
                    id: lastRow,
                    key: 'wrongAnswers',
                    value: ++wrongAnswers,
                  );
                  _handleOneOfTheCircelsIsPressed();
                  dataToWrite.add([
                    round,
                    'wrong',
                    responseTimeOfHolding,
                    responseTimeOfAnswer
                  ]);
                  randomPhoto = wrongImg;
                } else { // correct answer
                  UserSheetsApi.updateCell(
                    id: lastRow,
                    key: 'correctAnswers',
                    value: ++correctAnswers,
                  );
                  _handleOneOfTheCircelsIsPressed();
                  dataToWrite.add([
                    round,
                    'correct',
                    responseTimeOfHolding,
                    responseTimeOfAnswer
                  ]);
                  randomPhoto = veryGoodImg;
                }
                randomNumber = random.nextInt(2) + 1;

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
    return FutureBuilder<ButtonConfig>(
      future: loadButtonConfig(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final buttonConfig = snapshot.data!;
          redColor = Color(int.parse(
            buttonConfig.buttonColor.replaceAll('#', '0x'),
          ));
          return StyledButton(
            // red button
            buttonConfig: buttonConfig,
            onPressed: () async {
              final last = await UserSheetsApi.getRowCount();
              setState(() {
                if ((randomNumber == 1 && isRanbow && !isRed) ||
                    (randomNumber == 1 && !isRanbow && isRightArrow)) {
                  UserSheetsApi.updateCell(
                    id: last,
                    key: 'wrongAnswers',
                    value: ++wrongAnswers,
                  );
                  _handleOneOfTheCircelsIsPressed();
                  dataToWrite.add([
                    round,
                    'wrong',
                    responseTimeOfHolding,
                    responseTimeOfAnswer
                  ]);
                  randomPhoto = wrongImg;
                } else if ((randomNumber == 2 && isRanbow && isRed) ||
                    (randomNumber == 2 && !isRanbow && isRightArrow)) {
                  UserSheetsApi.updateCell(
                    id: last,
                    key: 'wrongAnswers',
                    value: ++wrongAnswers,
                  );
                  _handleOneOfTheCircelsIsPressed();
                  dataToWrite.add([
                    round,
                    'wrong',
                    responseTimeOfHolding,
                    responseTimeOfAnswer
                  ]);
                  randomPhoto = wrongImg;
                } else { // correct answer
                  UserSheetsApi.updateCell(
                    id: last,
                    key: 'correctAnswers',
                    value: ++correctAnswers,
                  );
                  _handleOneOfTheCircelsIsPressed();
                  dataToWrite.add([
                    round,
                    'correct',
                    responseTimeOfHolding,
                    responseTimeOfAnswer
                  ]);
                  randomPhoto = veryGoodImg;
                }
                // _handleOneOfTheCircelsIsPressed();
                randomNumber = random.nextInt(2) + 1;
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
          'Trial $round out of 30',
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
                          image: AssetImage(randomPhoto),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: randomArrow,
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
                            round++;
                            if (round > 30) {
                              saveDataToCSV();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const FinalPage(),
                                ),
                              );
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
