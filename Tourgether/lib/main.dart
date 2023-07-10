// jsonEncode() 사용하기 위함.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourgether/providers/gps_provider.dart';
import 'package:tourgether/screens/login_screen.dart';
import 'package:tourgether/screens/main_screen.dart';
import 'package:tourgether/screens/map_screen.dart';
import 'package:tourgether/screens/messages_screen.dart';

// 2023.07.08, pjh
// nodejs 서버가 작동하고 있는 PC의 IP를 적어야한다.
// 로컬에서 테스트했기 때문에 아래의 IP 주소는 개인의 것으로 수정해야함.
// ipconfig -> IPv4 주소 기입.
// AWS EC2에 서버를 올릴경우 public ip 설정을 해줘야할듯.
const String myIp = "192.168.219.101";

// 2023.07.08, jdk
// 프로그램의 메인 진입점
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2023.07.10, jdk
    // MultiProvider를 적용하기 위해 앱 최상단에 MultiProvider Widget으로 감싸줌.
    // 현재는 GPSProvider 하나만 적용된 상황.
    // 이후에는 GPSProvider가 필요한 부분에만 적용될 수 있도록 위치 조정이 필요함.
    // (현재는 마치 전역변수처럼 아무곳에서나 접근 가능하도록 설정해놓은 상태임)
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GPSProvider(),
        ),
      ],
      child: MaterialApp(
        initialRoute: "/login",
        routes: {
          "/login": (context) => const LoginScreen(),
          "/main": (context) => const MainScreen(),
          "/messages": (context) => const MessagesScreen(),
          "/map": (context) => const MapScreen(),
        },
        title: "TourGather",
        debugShowCheckedModeBanner: false, // debug banner를 띄우지 않음.
        // home: MainScreen(), // MainScreen을 home widget으로 설정.
      ),
    );
  }
}

/*
// 2023.07.08, jdk
// 홈 화면에 출력될 메인 화면 widget
class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textController = TextEditingController();
  File? _image;
  Uint8List? imageBytes;

  // 2023.07.08, jdk
  // 메인 화면의 이미지 추가 버튼(+)에 대한 콜백 함수(private)
  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  // 2023.07.08, jdk
  // 추가된 이미지를 HTTP 통신을 통해 서버에 전달하는 콜백 함수(private)
  Future<void> _sendMessage() async {
    String base64Image = base64Encode(_image!.readAsBytesSync());
    List<int> imageBytes = await _image!.readAsBytesSync();
    print('imageBytes: $imageBytes');
    final json = {"message": _textController.text, "image": base64Image};

    await http
        .post(Uri.parse('http://$myIp:3000/api/upload'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(json))
        .then((response) {
      print(response.body);
    }).catchError((error) {
      print('Error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Enter your message',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getImage,
              child: Text('Choose an image'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
*/