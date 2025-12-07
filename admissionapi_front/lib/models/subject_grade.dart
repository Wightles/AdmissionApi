class SubjectGrade {
  int? id;
  int applicationId;
  String subject;
  int grade; // 1-5

  SubjectGrade({
    this.id,
    required this.applicationId,
    required this.subject,
    required this.grade,
  });

  factory SubjectGrade.fromJson(Map<String, dynamic> json) {
    return SubjectGrade(
      id: json['Id'] ?? json['id'],
      applicationId: json['ApplicationId'] ?? json['applicationId'] ?? 0,
      subject: (json['Subject'] ?? json['subject'] ?? '').toString(),
      grade: json['Grade'] ?? json['grade'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'ApplicationId': applicationId,
      'subject': subject,
      'grade': grade,
    };
  }

  String get gradeText {
    switch (grade) {
      case 5:
        return 'Отлично';
      case 4:
        return 'Хорошо';
      case 3:
        return 'Удовлетворительно';
      case 2:
        return 'Неудовлетворительно';
      case 1:
        return 'Плохо';
      default:
        return 'Н/Д';
    }
  }
}