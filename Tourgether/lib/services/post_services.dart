import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert' as convert;
import '../models/user_comment.dart';
import '../models/user_post_model.dart';
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
  static const String postSigninUrl = "/api/postSignin";
  static const String postSignupUrl = "/api/postSignup";
  static const String emailVerifyUrl = "/api/emailVerify";
  static const String addUserUrl = "/api/addUser";
  static const String checkDupNameUrl = "/api/checkDupName";
  static const String postGetMessageUrl = "/api/postGetMessage";
  static const String getUserCommentsUrl = "/api/getUserComments";
  static const String postUserCommentUrl = "/api/postUserComment";

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

  static Future<List<UserPostModel>> getUsersPostsList() async {
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
        return UserPostModel.fromJson(model);
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

  static Future<bool> postSignin(Map<String, dynamic> postData) async {
    Log.logger.d(
        "postUserContent : URL[${baseUrl + postSigninUrl}]\npassed data : ${postData}");

    String jsonData = jsonEncode(postData);

    try {
      return await http
          .post(
        Uri.parse(baseUrl + postSigninUrl),
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

  static Future<bool> postSignup(Map<String, dynamic> postData) async {
    Log.logger.d(
        "postUserContent : URL[${baseUrl + postSignupUrl}]\npassed data : ${postData}");
    String jsonData = jsonEncode(postData);

    try {
      return await http
          .post(
        Uri.parse(baseUrl + postSignupUrl),
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

  static Future<bool> emailVerify(Map<String, dynamic> postData) async {
    Log.logger.d(
        "postUserContent : URL[${baseUrl + emailVerifyUrl}]\npassed data : ${postData}");
    String jsonData = jsonEncode(postData);

    try {
      return await http
          .post(
        Uri.parse(baseUrl + emailVerifyUrl),
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

  static Future<bool> postAddUser(Map<String, dynamic> postData) async {
    Log.logger.d(
        "postUserContent : URL[${baseUrl + addUserUrl}]\npassed data : ${postData}");
    String jsonData = jsonEncode(postData);

    try {
      return await http
          .post(
        Uri.parse(baseUrl + addUserUrl),
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

  static Future<bool> checkDupName(Map<String, dynamic> postData) async {
    Log.logger.d(
        "checkDupNameContent : URL[${baseUrl + checkDupNameUrl}]\npassed data : ${postData}");
    String jsonData = jsonEncode(postData);

    try {
      return await http
          .post(
        Uri.parse(baseUrl + checkDupNameUrl),
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

  static Future<dynamic> postGetMessage(Map<String, dynamic> postData) async {
    print('getMessage 호출');
    Log.logger.d(
        "postUserContent : URL[${baseUrl + postGetMessageUrl}]\npassed data : ${postData}");
    String jsonData = jsonEncode(postData);

    try {
      return await http
          .post(
        Uri.parse(baseUrl + postGetMessageUrl),
        headers: headers,
        body: jsonData,
      )
          .then((response) {
        var jsonResponse = convert.jsonDecode(response.body);
        if (jsonResponse is! List) {
          jsonResponse = [jsonResponse];
          Log.logger.d("converted to List");
          print('배열로 만듬');
        }

        // for(int i =0; i< jsonResponse.length; i++){
        //   if(jsonResponse[i]['gps']['x'] < MapInfo.left_down_gps['x'] || jsonResponse[i]['gps']['x'] > MapInfo.left_up_gps['x'] ||
        //       jsonResponse[i]['gps']['y'] < MapInfo.left_down_gps['y'] || jsonResponse[i]['gps']['y'] > MapInfo.right_down_gps['y']){

        //   }
        // }

        return jsonResponse;
      });
    } catch (error) {
      Log.logger.e("error", error: error);
      return false;
    }
  }

  static Future<List<UserComment>> getUserComments(int rid) async {
    Log.logger.d("getUserComments : URL[${baseUrl + getUserCommentsUrl}]");

    // 몇 번 게시글의 댓글을 가져올 것인지 rid 전달.
    Map<String, dynamic> comment_json_data = {
      "rid": rid,
    };

    var jsonData = jsonEncode(comment_json_data);

    try {
      final response = await http.post(
        Uri.parse(baseUrl + getUserCommentsUrl),
        headers: headers,
        body: jsonData,
      );

      Log.logger.d(response.body);
      var jsonResponse = convert.jsonDecode(response.body);

      // Map으로 json data가 반환된다.
      // List 형태가 아닐 경우 List로 변환한다.
      if (jsonResponse is! List) {
        jsonResponse = [jsonResponse];
        Log.logger.d("converted to List [/api/getUserComments]");
      }

      List<UserComment> user_comments_list = jsonResponse.map((model) {
        return UserComment.fromJson(model);
      }).toList();

      // 2023.09.06, jdk
      // 전달받은 comment 데이터를 정렬해야 함.

      return user_comments_list;
    } catch (error) {
      Log.logger
          .e("An error occurred while fetching users posts", error: error);
      throw Exception("An error occurred while fetching users posts");
    }
  }

  static Future<bool> postUserComment(Map<String, dynamic> commentData) async {
    Log.logger.d(
      "postUserContent : URL[${baseUrl + postUserCommentUrl}]\npassed data : ${commentData}",
    );

    // 서버로 보낼 데이터를 jsonEncode
    String jsonData = jsonEncode(commentData);

    try {
      return await http
          .post(
        Uri.parse(baseUrl + postUserCommentUrl),
        headers: headers,
        body: jsonData,
      )
          .then((response) {
        if (response.statusCode == 200) {
          Log.logger.d("The comment successfully uploaded on DB.");
          return true;
        } else {
          Log.logger.e(
            "An error occurred while uploading a comment on DB. (statusCode is not 200)",
          );
          throw Exception();
        }
      });
    } catch (error) {
      Log.logger.e("error", error: error);
      return false;
    }
  }
}
