class Application {
  int? id;
  int applicantId;
  String faculty;
  String specialty;
  String? educationalInstitution;
  int? graduationYear;
  String? documentType;
  String? documentNumber;
  double? averageScore;
  double? egeScore;
  String? groupNumber;

  Application({
    this.id,
    required this.applicantId,
    required this.faculty,
    required this.specialty,
    this.educationalInstitution,
    this.graduationYear,
    this.documentType,
    this.documentNumber,
    this.averageScore,
    this.egeScore,
    this.groupNumber,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['Id'] ?? json['id'],
      applicantId: json['ApplicantId'] ?? json['applicantId'] ?? 0,
      faculty: (json['Faculty'] ?? json['faculty'] ?? '').toString(),
      specialty: (json['Specialty'] ?? json['specialty'] ?? '').toString(),
      educationalInstitution: json['EducationalInstitution'] ?? json['educationalInstitution'],
      graduationYear: json['GraduationYear'] ?? json['graduationYear'],
      documentType: json['DocumentType'] ?? json['documentType'],
      documentNumber: json['DocumentNumber'] ?? json['documentNumber'],
      averageScore: (json['AverageScore'] ?? json['averageScore'])?.toDouble(),
      egeScore: (json['EgeScore'] ?? json['egeScore'])?.toDouble(),
      groupNumber: json['GroupNumber'] ?? json['groupNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'applicantId': applicantId,
      'faculty': faculty,
      'specialty': specialty,
      'educationalInstitution': educationalInstitution,
      'graduationYear': graduationYear,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'averageScore': averageScore,
      'egeScore': egeScore,
      'groupNumber': groupNumber,
    };
  }
}