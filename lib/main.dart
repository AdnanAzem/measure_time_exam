import 'package:excel_example/create_sheets_page.dart';
import 'package:excel_example/user_sheets_api.dart';
import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSheetsApi.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final String title = 'Details Page';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: Container(
        child: CreateSheetsPage(),
      ),
    );
  }
}
