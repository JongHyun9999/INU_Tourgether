// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:tourgether/models/message_model.dart';

// 2023.07.09, jdk
// postMessageData 함수는 현재 유저가 작성한 글의 내용을 MessageModel type으로 받아오고,
// 이를 parsing하여 서버에 HTTP POST를 통해 보내는 기능을 한다.
Future<bool> postMessageData({required MessageModel messageData}) async {
  // 서버에 전송할 Json 데이터 생성
  final json = {
    "author": messageData.author,
    "content": messageData.content,
    "latitude": messageData.latitude,
    "longitude": messageData.longitude,
  };

  bool isPostSucceed = false;

  try {
    await http
        .post(Uri.parse("http://localhost:3000/api/postMessages"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(json))
        .then((response) {
      if (response.statusCode == 200) {
        isPostSucceed = true;
      }
    }).catchError((error) {
      // catchError는 HTTP에서 발생하는 오류를 처리
      print("Error: $error");
    });
  } catch (error) {
    // catch는 동기적인 동작에서 발생하는 오류를 처리
    log(error.toString());
  }

  // statusCode가 200일 때만 true를 return함.
  return isPostSucceed;
}

// 2023.07.09, jdk
// getMessageData 함수는 현재 DB상에 존재하는 모든 게시글을 불러오게 된다.
// 현재는 게시글이 많이 존재하지 않기 때문에 모든 게시글을 불러와도 문제가 없지만,
// 게시글이 많아질 경우 한번에 출력할 게시글의 개수를 조정하여 불러올 수 있어야 한다.
Future<MessageModel?> getMessageData() async {
  MessageModel? messageData;

  try {
    // 2023.07.09, jdk
    // API path 수정 필요. 이후에 전역 변수를 모아두는 Data Class를 생성하여
    // path를 끌어다 쓰도록 하고, String Interpolation을 통해 상세 path를 조정한다.
    await http.get(
      Uri.parse("http://localhost:3000/api/getMessages"),
      headers: {"Content-Type": "application/json"},
    ).then((value) {
      if (value.statusCode == 200) {
        final item = json.decode(value.body);
        messageData = MessageModel.fromJson(item);
      } else {
        print("Error");
      }
    }).catchError((error) {
      // catchError는 HTTP에서 발생하는 오류를 처리
      print("Error : $error");
    });
  } catch (error) {
    // catch는 동기적인 동작에서 발생하는 오류를 처리
    log(error.toString());
  }

  // 반환된 messageData를 return한다.
  // 단, error 발생 시 messageData는 null이 될 수 있음.
  return messageData;
}
