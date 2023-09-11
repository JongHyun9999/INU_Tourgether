class UserComment {
  // 글을 입력할 경우에는 rid가 필요하지 않으므로
  // 기본값은 0으로 설정한다.
  final int rid;
  final int comment_idx;
  final bool is_reply;
  final int reply_idx;
  final String user_name;
  final String content;
  final int liked_num;

  UserComment({
    required this.rid,
    required this.comment_idx,
    required this.is_reply,
    required this.reply_idx,
    required this.user_name,
    required this.content,
    required this.liked_num,
  });

  // 2023.07.09, jdk
  // API를 통해 전달받은 데이터를 Json으로 변경하는 factory 메서드.
  UserComment.fromJson(Map<String, dynamic> json)
      : rid = json['rid'],
        comment_idx = json['comment_idx'],
        is_reply = json['is_reply'],
        reply_idx = json['reply_idx'],
        user_name = json['user_name'],
        content = json['content'],
        liked_num = json['liked_num'];
  /*
  // 2023.07.09, jdk
  // 현재 전달된 argument에 대한 Null Checking이 없으므로 주의해야 함.
  factory UserPostModel.fromData(
    String authorArg,
    String contentArg,
    String latitudeArg,
    String longitudeArg,
  ) {
    // 전달받은 데이터 중, latitude와 longitude는 double 형식으로 변경
    final latitudeString = latitudeArg;
    final longitudeString = longitudeArg;

    final latitudeDouble = double.tryParse(latitudeString);
    final longitudeDouble = double.tryParse(longitudeString);

    // 2023.07.10, jdk
    // 만약 latitudeArg, longitudeArg가 숫자형식이 아닐 경우,
    // tryParse의 결과로 Null이 반환되어 문제가 발생할 수 있음.
    // 우선 현재는 반드시 숫자로 넣는다고 가정하기 때문에 추가적인 block을 넣지 않음.
    // 이후에 geolocator를 거치게 함으로써 문제 해결할 예정.

    // 객체로 반환
    return UserPostModel(
      author: authorArg,
      content: contentArg,
      latitude: latitudeDouble!,
      longitude: longitudeDouble!,
    );
  }
  */
}
