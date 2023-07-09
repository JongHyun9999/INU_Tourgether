class MessageModel {
  final String author;
  final String content;
  final double latitude;
  final double longitude;

  MessageModel({
    required this.author,
    required this.content,
    required this.latitude,
    required this.longitude,
  });

  // 2023.07.09, jdk
  // API를 통해 전달받은 데이터를 Json으로 변경하는 factory 메서드.
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      author: json['author'] ?? "",
      content: json['body'] ?? "",
      latitude: json['latitude'] ?? "",
      longitude: json['longitude'] ?? "",
    );
  }

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

    // 객체로 반환
    return MessageModel(
      author: authorArg,
      content: contentArg,
      latitude: latitudeDouble!,
      longitude: longitudeDouble!,
    );
  }
}
