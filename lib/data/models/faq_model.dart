class FaqItemModel {
  final String question;
  final String answer;
  final String category;

  const FaqItemModel({
    required this.question,
    required this.answer,
    required this.category,
  });

  factory FaqItemModel.fromJson(Map<String, dynamic> json) {
    return FaqItemModel(
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'answer': answer,
    'category': category,
  };
}
