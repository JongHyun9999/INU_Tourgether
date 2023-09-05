// 2023.09.06, jdk
// 유저가 작성한 comment/reply를 처리하는 데이터 클래스.
class UserComment {
  // 2023.09.06, jdk
  // 전달받은 데이터가 reply가 아니고 comment일 수 있으므로,
  // reply_index는 null이 될 수 있다.
  final int comment_id;
  final int rid;
  final int comment_idx;
  final bool is_reply;
  final int? reply_index;
  final String user_name;
  final String content;
  final int liked_num;

  UserComment({
    required this.comment_id,
    required this.rid,
    required this.comment_idx,
    required this.is_reply,
    required this.reply_index,
    required this.user_name,
    required this.content,
    required this.liked_num,
  });

  // -------------------------------------------------------------
  // 2023.07.09, jdk
  // API를 통해 전달받은 데이터를 Json으로 변경하는 factory 메서드.
  // -------------------------------------------------------------
  UserComment.fromJson(Map<String, dynamic> json)
      : comment_id = json['comment_id'],
        rid = json['rid'],
        comment_idx = json['comment_idx'],
        is_reply = json['is_reply'],
        reply_index = json['reply_index'],
        user_name = json['user_name'],
        content = json['content'],
        liked_num = json['liked_num'];
}
