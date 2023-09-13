import 'package:TourGather/providers/user_post_provider.dart';
import 'package:TourGather/utilities/color_palette.dart';
import 'package:TourGather/widgets/post/user_post.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:TourGather/screens/nav/post_list/user_post_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../models/message/user_post_model.dart';
import '../../services/post_services.dart';

class UsersPostsListScreen extends StatefulWidget {
  const UsersPostsListScreen({super.key});

  @override
  State<UsersPostsListScreen> createState() => _UserPostListScreenState();
}

class _UserPostListScreenState extends State<UsersPostsListScreen> {
  var logger = Logger(
    printer: PrettyPrinter(),
  );

  // 2023.08.07, jdk
  // 특정 글꼴로 Text를 생성할 수 있는
  // Utility 생성 필요함.
  @override
  Widget build(BuildContext context) {
    // 2023.08.13, jdk
    // user_post_list_screen.dart
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          title: Text(
            "자유게시판",
            style: TextStyle(
              color: ColorPalette.whiteColor,
              fontFamily: 'Pretendard',
              fontSize: 15,
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(
            color: ColorPalette.onPrimaryContainer,
          ),
          backgroundColor: ColorPalette.primaryContainer,
        ),
      ),
      body: Container(
        child: FutureBuilder<List<UserPostModel>>(
          future: context.read<UserPostProvider>().getUsersPostsList(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Container(
                child: Center(
                  child: Text("Error."),
                ),
              );
            } else if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                child: Container(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      return UserPost(
                        postData: snapshot.data![index],
                        index: index,
                      );
                    },
                  ),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
