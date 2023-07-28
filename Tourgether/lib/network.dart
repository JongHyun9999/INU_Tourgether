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
  /*
  Future<dynamic> post(String url, dynamic data) async {
    
    // body부분에 json 데이터를 보낸다.
    // map형으로 가져와서 jsonEncode 명령어를 이용해서 json형으로 바꾼 후 보내도 된다.
    var response = await http
        .post(Uri.parse(url), body: {'title': 'foo', 'body': 'bar', 'userId': '1'});
    // check the status code for the result
    if (response.statusCode == 201) {
      print(response.body);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return json.decode(utf8.decode(response.bodyBytes));
  }
  */
}
