import 'dart:convert'; // jsonEncode() 사용하기 위함.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'widget/spinningWheel.dart';

// nodejs 서버가 작동하고 있는 PC의 IP를 적어야한다.
// 로컬에서 테스트했기 때문에 아래의 IP 주소는 개인의 것으로 수정해야함.
// ipconfig -> IPv4 주소 기입.
// AWS EC2에 서버를 올릴경우 public ip 설정을 해줘야할듯.
const String myIp = "192.168.219.101";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter with Node.js',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter with Node.js'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textController = TextEditingController();
  File? _image;
  // Uint8List? imageBytes;

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  Future<void> _sendMessage() async {
    String base64Image = base64Encode(_image!.readAsBytesSync());
    // List<int> imageBytes = await _image!.readAsBytesSync();
    // print('imageBytes: $imageBytes');
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Enter your message',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getImage,
              child: const Text('Choose an image'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text('Send'),
            ),
            const SpinningWheel(),
          ],
        ),
      ),
    );
  }
}
