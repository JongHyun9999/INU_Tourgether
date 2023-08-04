import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mytourgether/screens/user_post_detail_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: AppBar(
            title: Text(
              "POST LIST",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
                logger.d("${snapshot.data![0].author}");
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserPostDetailScreen(
                              author: snapshot.data![index].author,
                              content: snapshot.data![index].content,
                              latitude: snapshot.data![index].latitude,
                              longitude: snapshot.data![index].longitude,
                              liked: snapshot.data![index].liked,
                              posted_time: snapshot.data![index].posted_time,
                            ),
                          ),
                        );
                      },
                      title: Text("${snapshot.data![index].content}"),
                      leading: Text("${snapshot.data![index].author}"),
                      subtitle: Text("${snapshot.data![index].posted_time}"),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${snapshot.data![index].latitude}"),
                          Text("${snapshot.data![index].longitude}"),
                        ],
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
