// pjh. 메인페이지 메세지 리스트 전용 class.
class messageProduct {
  final String imagePath;
  final String userName;
  final String textContent;
  final String department;
  int goodCount;

  messageProduct(
      {required this.imagePath,
      required this.userName,
      required this.textContent,
      required this.department,
      required this.goodCount});
}
