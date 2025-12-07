class ExamResult {
  int? id;
  int applicationId;
  int? applicantId; // Добавлено: ID абитуриента
  String? classroom;
  String subject;
  DateTime? examDate;
  int score; // 0-100
  // Дополнительные поля из связанных таблиц (для отображения)
  String? applicantName;
  String? specialty;
  String? faculty;

  ExamResult({
    this.id,
    required this.applicationId,
    this.applicantId,
    this.classroom,
    required this.subject,
    this.examDate,
    required this.score,
    this.applicantName,
    this.specialty,
    this.faculty,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['Id'] ?? json['id'],
      applicationId: json['ApplicationId'] ?? json['applicationId'] ?? 0,
      applicantId: json['ApplicantId'] ?? json['applicantId'],
      classroom: json['Classroom'] ?? json['classroom'],
      subject: (json['Subject'] ?? json['subject'] ?? '').toString(),
      examDate: json['ExamDate'] != null
          ? DateTime.tryParse(json['ExamDate'].toString())
          : null,
      score: json['Score'] ?? json['score'] ?? 0,
      applicantName: json['ApplicantName'] ?? json['applicantName'],
      specialty: json['Specialty'] ?? json['specialty'],
      faculty: json['Faculty'] ?? json['faculty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'ApplicationId': applicationId,
      'classroom': classroom,
      'subject': subject,
      'examDate': examDate?.toIso8601String(),
      'score': score,
    };
  }

  String get grade {
    if (score >= 90) return 'Отлично (A)';
    if (score >= 75) return 'Хорошо (B)';
    if (score >= 60) return 'Удовлетворительно (C)';
    return 'Неудовлетворительно (F)';
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) return 'Не указана';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
  
  String get displayDate => _formatDate(examDate);
  
  String get displayName {
    if (applicantName != null && applicantName!.isNotEmpty) {
      return applicantName!;
    }
    return 'Заявление #$applicationId';
  }
}