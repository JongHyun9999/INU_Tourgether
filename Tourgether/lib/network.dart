import 'package:http/http.dart' as http;

import 'dart:convert';

class Network {
  final String url;
  Network(this.url);

  Future<dynamic> getJsonData() async {
    print("getJsonData is executed...");

    // api(get) 통신 실시

    // -------------------------------------------------------------
    // Flutter Future
    // Future란, 시간이 매우 오래 걸릴 것으로 예상되는 작업
    // 또는 비동기적인 동작이 필요한 작업에 사용되는 것이다.
    // 예를 들어 API 통신의 경우 시간이 얼마나 오래 걸릴지 모르고,
    // 또 서버의 상태에 따라 통신이 가능할지 불가능할지 모르기 때문에
    // 항상 Future라는 Type으로 response를 줌으로써
    // 비동기적인 대기 및 처리가 가능하도록 해야 한다.
    // -------------------------------------------------------------

    // req, res => server로부터 전달받는 응답을, 대기하고 있다는 것.

    http.Response response = await http.get(Uri.parse(url));
    //encode 후 parsingData 반환
    var userJson = response.body;
    var parsingData = jsonDecode(userJson);
    return parsingData;
  }
}
