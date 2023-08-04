class MessageModel {
  String author;
  String content;
  double latitude;
  double longitude;

  String posted_time;
  int liked;

  MessageModel(
      {required this.author,
      required this.content,
      required this.latitude,
      required this.longitude,
      required this.posted_time,
      required this.liked});

  // 2023.07.09, jdk
  // API를 통해 전달받은 데이터를 Json으로 변경하는 factory 메서드.
  MessageModel.fromJson(Map<String, dynamic> json)
      : author = json['user_id'],
        content = json['content'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        posted_time = json['posted_time'],
        liked = json['liked'];

  /*
  // 2023.07.09, jdk
  // 현재 전달된 argument에 대한 Null Checking이 없으므로 주의해야 함.
  factory MessageModel.fromData(
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
    return MessageModel(
      author: authorArg,
      content: contentArg,
      latitude: latitudeDouble!,
      longitude: longitudeDouble!,
    );
  }
  */
}
