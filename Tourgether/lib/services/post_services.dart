import 'dart:convert';
import 'package:http/http.dart' as http;
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

  static Future<void> postUserContent(Map<String, dynamic> postData) async {
    logger.d(
        "postUserContent : URL[${baseUrl + postUserContentUrl}]\npassed data : ${postData}");

    String jsonData = jsonEncode(postData);

    try {
      await http
          .post(
        Uri.parse(baseUrl + postUserContentUrl),
        headers: headers,
        body: jsonData,
      )
          .then((response) {
        if (response.statusCode == 200) {
          logger.d("A post successfully uploaded on DB.");
        } else {
          logger.e(
              "An error occurred while uploading a post on DB. (statusCode is not 200)");
        }
      });
    } catch (error) {
      logger.e("An error occurred while uploading a post on DB.", error: error);
    }
  }

  static Future<List<MessageModel>> getUsersPostsList() async {
    logger.d("getUsersPostsList : URL[${baseUrl + getUsersPostsListUrl}]");

    try {
      final response =
          await http.get(Uri.parse(baseUrl + getUsersPostsListUrl));

      var jsonResponse = convert.jsonDecode(response.body);

      if (jsonResponse is! List) {
        jsonResponse = [jsonResponse];
        logger.d("converted to List");
      }

      return jsonResponse.map((model) => MessageModel.fromJson(model)).toList();
    } catch (error) {
      logger.e("An error occurred while fetching users posts", error: error);
      throw Exception("An error occurred while fetching users posts");
    }
  }
}
