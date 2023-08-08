import 'package:TourGather/utilities/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:TourGather/screens/user_post_detail_screen.dart';
import '../models/message_model.dart';
import '../services/post_services.dart';

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
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(
            title: Text(
              "자유 게시판",
              style: TextStyle(
                color: ColorPalette.whiteColor,
                fontFamily: 'Pretendard',
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
          child: FutureBuilder<List<MessageModel>>(
            future: PostServices.getUsersPostsList(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Container(
                  child: Center(
                    child: Text("Error."),
                  ),
                );
              } else if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: ColorPalette.secondaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 1),
                      elevation: 5,
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserPostDetailScreen(
                                user_id: snapshot.data![index].user_id,
                                content: snapshot.data![index].content,
                                latitude: snapshot.data![index].latitude,
                                longitude: snapshot.data![index].longitude,
                                liked: snapshot.data![index].liked,
                                posted_time: snapshot.data![index].posted_time,
                              ),
                            ),
                          );
                        },
                        title: Text(
                          "${snapshot.data![index].title}",
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "${snapshot.data![index].posted_time}",
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "${snapshot.data![index].user_id}",
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          "인천대학교 어딘가",
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ));
  }
}
