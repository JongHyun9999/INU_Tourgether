import 'package:http/http.dart' as http;

import 'dart:convert';

// server로부터 response를 받는 코드
class Network {
  final String url;

  Network(this.url);
  // 끊임없이 체크하는 것이 아니라,
  // future 타입으로 response를 줘서 비동기적인 대기 및 처리를 하도록 함
  // 아래는 jsonData를 얻는 메서드이다.
  Future<dynamic> getJsonData() async {
    print("getJsonData is executed...");

    // http.get 메서드에 url을 넘기고 response를 받는 코드
    // response는 http.dart에 선언된 http.response 타입을 이용한다
    http.Response response = await http.get(Uri.parse(url));

    // response의 body에 사용자 정보가 들어있다.
    // response.request로 거꾸로 요청도 보낼 수 있다.
    var userJson = response.body;

    // decode 후 parsingData 반환
    // jsonDecode 명령어는 json 데이터 구조를 Map 데이터 타입으로 변경해준다.
    var parsingData = jsonDecode(userJson);
    return parsingData;
  }

  // 아래는 데이터를 보내는 코드이다.
  // 데이터는 http.post를 이용해서 보낸다.

  Future<dynamic> updateUserStatus(Map<String, String> data) async {
    // body부분에 json 데이터를 보낸다.
    // map형으로 가져와서 jsonEncode 명령어를 이용해서 json형으로 바꾼 후 보내도 된다.
    //print("send!");
    print(data);

    // --------------------------------------------------------
    // 2023.07.29, jdk
    // 현재 data['user_schoolnum'], data['user_status']이 data에 존재하지 않아서
    // Null 값이 body로 넘어가 통신이 제대로 안된 것임.
    // 항상 내가 설정한 데이터가 제대로 전달되었는지 체크를 해 주어야 함.

    // print(data['user_schoolnum']);
    // print(data['user_status']);

    // http.Response response = await http.post(Uri.parse(url), body: {
    //   'user_schoolnum': data['user_schoolnum'],
    //   'user_status': data['user_status']
    // });
    // --------------------------------------------------------

    //print(data['user_schoolnum']);
    //print(data['user_status']);

    var response = await http.post(Uri.parse(url), body: {
      'user_schoolnum': data['user_schoolnum'],
      'user_status': data['user_status']
    });

    //print("received!");

    // check the status code for the result
    if (response.statusCode == 201) {
      print(response.body);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return json.decode(utf8.decode(response.bodyBytes));
  }
}
