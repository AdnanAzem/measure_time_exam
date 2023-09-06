import 'package:excel_example/button_config.dart';
import 'package:excel_example/final_page.dart';
import 'package:excel_example/styled_button.dart';
import 'package:excel_example/user_sheets_api.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  static Future<int> getLastRaw() async {
    final res = await UserSheetsApi.getRowCount() + 1;
    return res;
  }

  @override
  State<GamePage> createState() => _GamePageState();
}

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
    'assets/images/arrows2.png',
    'assets/images/rainbow2.jpeg'
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
  String blackImg = 'assets/images/black.png';
  String veryGoodImg = 'assets/images/verygood.png';
  String randomPhoto = 'assets/images/black.png';
  int startTime = 0;
  int endTime = 0;
  int round = 0;

  void _handleCenterButtonPressDown() {
    startTime = DateTime.now().microsecondsSinceEpoch;
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        randomArrow = getRandomArrow();
        randomPhoto = getRandomPhoto();
        pressedButton = true;
        // isButtonPressed = true;
        print("the time when the user pressed the center button: $startTime");
      });
    });
  }

  void _handleCenterButtonPressUp() {
    setState(() {
      endTime = DateTime.now().microsecondsSinceEpoch;
      // isButtonPressed = false;
      print("the time when the user released the center button: $endTime");
      int time_of_holding_the_button = endTime - startTime;
      print("time_of_holding_the_button:$time_of_holding_the_button");
    });
  }

  void _handleOneOfTheCircelsIsPressed() {
    if (endTime > startTime) {
      int elapsedNanoseconds = DateTime.now().microsecondsSinceEpoch - endTime;
      print("response time: $elapsedNanoseconds microseconds");
    }
    setState(() {
      pressedButton = false;
      randomArrow = const Icon(
        Icons.arrow_back,
        color: Colors.black,
      );
      Future.delayed(const Duration(milliseconds: 100), () {
        randomPhoto = 'assets/images/black.png';
      });
    });
  }

  Future<ButtonConfig> loadButtonConfig() async {
    String jsonString =
        await rootBundle.loadString('assets/buttons/red_button.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    return ButtonConfig.fromJson(jsonMap);
  }

  Future<ButtonConfig> loadButtonConfig1() async {
    String jsonString =
        await rootBundle.loadString('assets/buttons/green_button.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    return ButtonConfig.fromJson(jsonMap);
  }

  FutureBuilder<ButtonConfig> getGreenCircle() {
    return FutureBuilder<ButtonConfig>(
      future: loadButtonConfig1(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final buttonConfig = snapshot.data!;
          // redCircle = redColor;
          return StyledButton(
            // red button
            buttonConfig: buttonConfig,
            onPressed: () async {
              final lastRow = await UserSheetsApi.getRowCount();
              setState(() {
                if ((isRanbow && isRed) || (!isRanbow && !isRightArrow)) {
                  UserSheetsApi.updateCell(
                    id: lastRow,
                    key: 'wrongAnswers',
                    value: ++wrongAnswers,
                  );
                  randomPhoto = blackImg;
                  print("wrong");
                } else {
                  UserSheetsApi.updateCell(
                    id: lastRow,
                    key: 'correctAnswers',
                    value: ++correctAnswers,
                  );
                  randomPhoto = veryGoodImg;
                }
                _handleOneOfTheCircelsIsPressed();
                startTime = 0;
                endTime = 0;
              });
            },
          );
        }
      },
    );
  }

  FutureBuilder<ButtonConfig> getRedCircle() {
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
                if ((isRanbow && !isRed) || (!isRanbow && isRightArrow)) {
                  UserSheetsApi.updateCell(
                    id: last,
                    key: 'wrongAnswers',
                    value: ++wrongAnswers,
                  );
                  randomPhoto = blackImg;
                  print("wrong");
                } else {
                  UserSheetsApi.updateCell(
                    id: last,
                    key: 'correctAnswers',
                    value: ++correctAnswers,
                  );
                  randomPhoto = veryGoodImg;
                }
                _handleOneOfTheCircelsIsPressed();
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
              child: getRedCircle(),
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
                    child: GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          _handleCenterButtonPressDown();
                          containerColor = Colors.purple;
                          round++;
                          if (round > 30) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => const FinalPage(),
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
                        color: containerColor,
                        child: const Center(
                          child: Text(
                            "Keep Holding!",
                            style: TextStyle(fontSize: 20),
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
              child: getGreenCircle(),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
