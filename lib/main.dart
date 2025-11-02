import 'package:flutter/cupertino.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AgentApp());
}

class AgentApp extends StatelessWidget {
  const AgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Insurance Agent',
      theme: const CupertinoThemeData(
        primaryColor: Color(0xFF6366F1),
        scaffoldBackgroundColor: Color(0xFFF9FAFB),
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: 'MontserratExtraLight',
            color: CupertinoColors.black,
          ),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
