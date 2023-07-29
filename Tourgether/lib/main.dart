import 'dart:convert'; // jsonEncode() 사용하기 위함.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tourgether/setting.dart';

// AWS EC2의 public ip + port
final String myIp = "15.164.62.89";
final String myPort = "3000";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter with Node.js',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SettingsPage()
        //MyHomePage(title: 'Flutter with Node.js'),
        );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

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
        .post(Uri.parse('http://$myIp:$myPort/api/upload'),
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
