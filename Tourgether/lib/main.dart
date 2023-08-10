import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourgether/provider/userInfo_provider.dart';
import 'package:tourgether/screens/NavBar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserInfoProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final userInfo = UserInfoProvider();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<UserInfoProvider>(context, listen: false).getTestData());
    //print("왜 안되지?");
  }

  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const NarBar(),
        appBar: AppBar(
          title: const Text("사용자 정보 위젯 실습"),
        ),
        body: Center(
          child: Text("${Provider.of<UserInfoProvider>(context).userName}"),
        ));
  }
}
