class UserCommentReply {
  // 글을 입력할 경우에는 rid가 필요하지 않으므로
  // 기본값은 0으로 설정한다.
  final int reply_idx;
  final int rid;
  final int comment_idx;
  final String user_name;
  final String content;
  final int liked_num;

  UserCommentReply({
    required this.reply_idx,
    required this.rid,
    required this.comment_idx,
    required this.user_name,
    required this.content,
    required this.liked_num,
  });

  // 2023.07.09, jdk
  // API를 통해 전달받은 데이터를 Json으로 변경하는 factory 메서드.
  UserCommentReply.fromJson(Map<String, dynamic> json)
      : reply_idx = json['reply_idx'],
        rid = json['rid'],
        comment_idx = json['comment_idx'],
        user_name = json['user_name'],
        content = json['content'],
        liked_num = json['liked_num'];
}
