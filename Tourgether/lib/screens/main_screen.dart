import 'package:flutter/material.dart';
import 'package:tourgether/models/message_model.dart';
import 'package:tourgether/services/message_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 2023.07.08, jdk
  // 화면 구성에 필요한 변수들.
  // 이후에 적절한 data class에 위치를 옮기도록 한다.
  final String appTitle = "TourGather";

  final TextEditingController authorController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  String author = "";
  String content = "";
  String latitude = "";
  String longitude = "";

  bool isPostSucceed = false;

  @override
  void initState() {
    /*
      2023.07.08, jdk
      MainScreen이 처음 만들어질 때 한번만 실행되는 메서드.
      화면 구성에 필요한 초기 변수를 초기화한다.
      * initState에서는 build 메서드를 부를 수 없다. *
    */
    super.initState();
  }

  @override
  void dispose() {
    // 컨트롤러를 사용한 뒤, 메모리 누수 방지를 위해 dispose()로 정리함.
    // print("disposed...");
    authorController.dispose();
    contentController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(appTitle),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // 작성된 내용을 바탕으로 서버에 데이터 전송
                    // 모든 내용이 정확히 기입되었는지 확인 필요.
                    // 즉, Null Checking이 필요하다.

                    author = authorController.text;
                    content = contentController.text;
                    latitude = latitudeController.text;
                    longitude = longitudeController.text;

                    MessageModel messageData = MessageModel.fromData(
                      author,
                      content,
                      latitude,
                      longitude,
                    );

                    isPostSucceed =
                        await postMessageData(messageData: messageData);

                    // 전송에 성공했으면 isPostSucceed flag를 false로 바꿈.
                    if (isPostSucceed) isPostSucceed = false;
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    // 현재 작성된 글 리스트를 출력하기 위해 페이지 이동
                    Navigator.pushNamed(context, "/messages");
                  },
                  child: const Icon(Icons.list),
                ),
              ],
            ),
            const SizedBox(
              width: 15,
            ),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(
                labelText: "Author",
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: "Content",
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            TextField(
              controller: latitudeController,
              decoration: const InputDecoration(
                labelText: "Latitude",
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            TextField(
              controller: longitudeController,
              decoration: const InputDecoration(
                labelText: "Longitude",
              ),
            )
          ],
        ),
      ),
    );
  }
}
