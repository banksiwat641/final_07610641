class DataItem {
  final String image;
  final String answer;

  DataItem({
    required this.image,
    required this.answer,

  });

  factory DataItem.fromJson(Map<String, dynamic> json) {
    return DataItem(
      image: json['image'],
      answer: json['answer'],
    );
  }

  DataItem.fromJson2(Map<String, dynamic> json)
      : image = json['image'],
        answer = json['answer'];

  @override
  String toString() {
    return '$image $answer';
  }
}