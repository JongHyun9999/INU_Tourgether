import 'package:TourGather/models/message/messageProduct.dart';
import 'package:TourGather/providers/near_message_info_provider.dart';
import 'package:TourGather/utilities/log.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExScreen extends StatefulWidget {
  const ExScreen({super.key});

  @override
  State<ExScreen> createState() => _ExScreenState();
}

class _ExScreenState extends State<ExScreen> {
  final PageController pageViewController =
      PageController(initialPage: 0, viewportFraction: 0.7);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Stack(
              children: [
                // 배경 클릭 시 나가지도록 함.
                GestureDetector(
                  // 2023.09.23, JKE
                  // stack 내에서 겹쳐진 배경 부분을 감지하려면
                  // 해당 property를 설정해야함.
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    // TODO
                    // 2023.09.23, JKE
                    // Navigator의 pop을 이용해서 나가도록 구현하였는데,
                    // 테스트 시 매우 느리게 나가지는 것을 확인
                    // 더 나은 방법이 있다면 수정하는 것이 좋을 것 같음
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),
                Positioned(
                  //left: MediaQuery.of(context).size.width / 2,
                  top: MediaQuery.of(context).size.height / 2 -
                      MediaQuery.of(context).size.height * 0.27,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: PageView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: pageViewController,
                          itemCount: context
                              .read<NearMessageInfoProvider>()
                              .message_info_list
                              .length,
                          itemBuilder: (context, index) {
                            var messageInfo = context
                                .read<NearMessageInfoProvider>()
                                .message_info_list[index];

                            // posted_time 문자열 가공
                            var stringTemp1 =
                                messageInfo.posted_time.substring(0, 10);
                            var stringTemp2 =
                                messageInfo.posted_time.substring(11, 19);
                            messageInfo.posted_time =
                                stringTemp1 + " " + stringTemp2;
                            Log.logger.d("JKE!!! ${messageInfo.posted_time}");

                            // 근처의 게시물 더미를 표현하는 container
                            return Container(
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 25.0,
                                        backgroundImage: AssetImage(
                                            "images/userInfo_profile.jpg"),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${messageInfo.user_name}",
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "${messageInfo.posted_time}",
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  Text(
                                    "${messageInfo.title}",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),

                                  // TODO
                                  // 2023-09-24, JKE
                                  // 이 container는 content를 담는 부분으로
                                  // 사이즈가 하드코딩되어있으니, 수정이 필요
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    height: MediaQuery.of(context).size.height *
                                        0.35,
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Center(
                                        child: Text(
                                      "${messageInfo.content}",
                                      style: TextStyle(color: Colors.white),
                                    )),
                                  )
                                ],
                              ),
                              padding: EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                color: Colors.amberAccent,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              margin: EdgeInsets.all(15.0),
                            );
                          })
                      //color: Colors.amber,
                      ),
                  // child: Column(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: [
                  //     Container(
                  //       width: MediaQuery.of(context).size.width,
                  //       //color: Colors.white,
                  //       //child: Text("HIHIIHIHIH")
                  //       child: PageView(
                  //         controller: pageViewController,
                  //         children: <Widget>[
                  //           Container(
                  //             width: 100,
                  //             height: 100,
                  //             child: Text("HI"),
                  //             color: Colors.amber,
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                )
              ],
            ),
          )
          // PageView.builder(
          //   itemCount: 4,
          //   itemBuilder: (_, index) {
          //     Log.logger.d('hiiiiiiii');
          //     return Center(
          //       child: Container(
          //         width: 100,
          //         height: 100,
          //         color: Colors.red,
          //         child: Column(
          //           children: [
          //             Text(
          //               "${context.read<NearMessageInfoProvider>().message_info_list[0].title}",
          //             )
          //           ],
          //         ),
          //       ),
          //     );
          //   },
          // )
        ],
      ),
    );
  }
}
