class TypingModel {
  String typing;
  String sender;
  String receiver;

  TypingModel(
      {required this.typing, required this.sender, required this.receiver});

  factory TypingModel.fromJson(Map<String, dynamic> json) {
    return TypingModel(
        typing: json['typing'],
        sender: json['sender'],
        receiver: json['receiver']);
  }
}
