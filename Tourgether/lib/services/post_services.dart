import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert' as convert;
import 'package:logger/logger.dart';
import '../models/message_model.dart';

class PostServices {
  static var logger = Logger(
    printer: PrettyPrinter(),
  );

  static Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  static const baseUrl = "http://10.0.2.2:3000";
  static const String postUserContentUrl = "/api/postUserContent";
  static const String getUsersPostsListUrl = "/api/getUsersPostsList";

  static Future<bool> postUserContent(Map<String, dynamic> postData) async {
    logger.d(
        "postUserContent : URL[${baseUrl + postUserContentUrl}]\npassed data : ${postData}");

    String jsonData = jsonEncode(postData);

    try {
      return await http
          .post(
        Uri.parse(baseUrl + postUserContentUrl),
        headers: headers,
        body: jsonData,
      )
          .then((response) {
        if (response.statusCode == 200) {
          logger.d("A post successfully uploaded on DB.");
          return true;
        } else {
          logger.e(
            "An error occurred while uploading a post on DB. (statusCode is not 200)",
          );
          throw Exception();
        }
      });
    } catch (error) {
      logger.e("error", error: error);
      return false;
    }
  }

  static Future<List<MessageModel>> getUsersPostsList() async {
    logger.d("getUsersPostsList : URL[${baseUrl + getUsersPostsListUrl}]");

    // TODO
    // 2023.08.07, jdk
    // 일정 시간 이상이 경과하면 에러 화면 출력하도록 수정하기.
    try {
      final response =
          await http.get(Uri.parse(baseUrl + getUsersPostsListUrl));

      logger.d(response.body);
      var jsonResponse = convert.jsonDecode(response.body);

      if (jsonResponse is! List) {
        jsonResponse = [jsonResponse];
        logger.d("converted to List");
      }

      return jsonResponse.map((model) {
        // 2023.08.07, jdk
        // 시간 보정 추가, 우선 임시적으로 18시간을 더해 줌.
        // 추후에 문제 해결을 위해 제대로 확인이 필요함.
        DateTime initialDateTime = DateTime.parse(model['posted_time']);
        DateTime correctedDateTime = initialDateTime.add(Duration(hours: 18));
        String formattedDateTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(correctedDateTime);
        model['posted_time'] = formattedDateTime;
        return MessageModel.fromJson(model);
      }).toList();
    } catch (error) {
      logger.e("An error occurred while fetching users posts", error: error);
      throw Exception("An error occurred while fetching users posts");
    }
  }
}
