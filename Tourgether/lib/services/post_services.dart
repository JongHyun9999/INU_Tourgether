import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert' as convert;
import '../models/message_model.dart';
import '../utilities/log.dart';

class PostServices {
  static Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  static const baseUrl = "http://10.0.2.2:3000";
  static const String postUserContentUrl = "/api/postUserContent";
  static const String getUsersPostsListUrl = "/api/getUsersPostsList";
  static const String pressedLikeButtonUrl = "/api/pressedLikeButton";
  static const String isLikeButtonPressedUrl = "/api/isLikeButtonPressed";

  static Future<bool> postUserContent(Map<String, dynamic> postData) async {
    Log.logger.d(
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
          Log.logger.d("A post successfully uploaded on DB.");
          return true;
        } else {
          Log.logger.e(
            "An error occurred while uploading a post on DB. (statusCode is not 200)",
          );
          throw Exception();
        }
      });
    } catch (error) {
      Log.logger.e("error", error: error);
      return false;
    }
  }

  static Future<List<MessageModel>> getUsersPostsList() async {
    Log.logger.d("getUsersPostsList : URL[${baseUrl + getUsersPostsListUrl}]");

    // TODO
    // 2023.08.07, jdk
    // 일정 시간 이상이 경과하면 에러 화면 출력하도록 수정하기.
    try {
      final response =
          await http.get(Uri.parse(baseUrl + getUsersPostsListUrl));

      Log.logger.d(response.body);
      var jsonResponse = convert.jsonDecode(response.body);

      if (jsonResponse is! List) {
        jsonResponse = [jsonResponse];
        Log.logger.d("converted to List");
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
      Log.logger
          .e("An error occurred while fetching users posts", error: error);
      throw Exception("An error occurred while fetching users posts");
    }
  }

  // 2023.08.13, jdk
  // 현재 게시글에 좋아요를 눌렀는지 체크하는 API
  static Future<bool> isLikeButtonPressed(Map<String, dynamic> postData) async {
    String jsonData = jsonEncode(postData);
    Log.logger.d("jsonData : ${jsonData}");

    try {
      var response = await http.post(
        Uri.parse(baseUrl + isLikeButtonPressedUrl),
        headers: headers,
        body: jsonData,
      );

      var jsonResponse;
      if (response.statusCode == 200) {
        Log.logger.d(
          "Successfully received the response on /api/isPressedPostLikeButton",
        );

        jsonResponse = convert.jsonDecode(response.body);
      } else {
        Log.logger.d(
          "Failed to receive the response on /api/isPressedPostLikeButton",
        );

        // 2023.08.13, jdk
        // 여기서 exception이 나면 바깥의 catch로 빠지는지 확인해보기.
        throw Exception();
      }

      Log.logger.d("jsonResponse['isPressed'] : ${jsonResponse['isPressed']}");

      if (jsonResponse['isPressed'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception();
    }
  }

  static Future<bool> pressedLikeButton(
    Map<String, dynamic> likedPostData,
  ) async {
    Log.logger.d("pressedLikeButton : URL[${baseUrl + pressedLikeButtonUrl}]");

    String jsonData = jsonEncode(likedPostData);
    Log.logger.d("jsonData : ${jsonData}");

    try {
      return await http
          .post(
        Uri.parse(baseUrl + pressedLikeButtonUrl),
        headers: headers,
        body: jsonData,
      )
          .then((response) {
        if (response.statusCode == 200) {
          Log.logger.d("User's like is successfully aplied on DB.");
          return true;
        } else {
          Log.logger.d(
            "An error occurred while applying User's like on DB. (status code is not 200)",
          );

          throw Exception();
        }
      });
      // TODO
      // 2023.08.11, jdk
      // API 실패에 따른 error catch와 status code is not 200 error catch의 구분이 필요함.
    } catch (error) {
      Log.logger.e("error", error: error);
      return false;
    }
  }
}
