class Applicant {
  int? id;
  String lastName;
  String firstName;
  String? patronymic;
  String gender; // 'm' or 'f'
  String citizenship;
  DateTime birthDate;
  String passportData;
  String applicantAddress;
  String? parentsAddress;
  String? foreignLanguage;

  Applicant({
    this.id,
    required this.lastName,
    required this.firstName,
    this.patronymic,
    required this.gender,
    required this.citizenship,
    required this.birthDate,
    required this.passportData,
    required this.applicantAddress,
    this.parentsAddress,
    this.foreignLanguage,
  });

  factory Applicant.fromJson(Map<String, dynamic> json) {
    // Сервер отправляет PascalCase, но проверяем оба варианта
    return Applicant(
      id: json['Id'] ?? json['id'],
      lastName: (json['LastName'] ?? json['lastName'] ?? '').toString(),
      firstName: (json['FirstName'] ?? json['firstName'] ?? '').toString(),
      patronymic: json['Patronymic'] ?? json['patronymic'],
      gender: (json['Gender'] ?? json['gender'] ?? 'm').toString(),
      citizenship: (json['Citizenship'] ?? json['citizenship'] ?? '').toString(),
      birthDate: DateTime.parse(
          (json['BirthDate'] ?? json['birthDate'])?.toString() ?? 
          DateTime.now().toIso8601String()),
      passportData: (json['PassportData'] ?? json['passportData'] ?? '').toString(),
      applicantAddress: (json['ApplicantAddress'] ?? json['applicantAddress'] ?? '').toString(),
      parentsAddress: json['ParentsAddress'] ?? json['parentsAddress'],
      foreignLanguage: json['ForeignLanguage'] ?? json['foreignLanguage'],
    );
  }

  Map<String, dynamic> toJson() {
    // Отправляем camelCase на сервер
    return {
      if (id != null) 'id': id,
      'lastName': lastName,
      'firstName': firstName,
      'patronymic': patronymic,
      'gender': gender,
      'citizenship': citizenship,
      'birthDate': birthDate.toUtc().toIso8601String(),
      'passportData': passportData,
      'applicantAddress': applicantAddress,
      'parentsAddress': parentsAddress,
      'foreignLanguage': foreignLanguage,
    };
  }

  String get fullName => '$lastName $firstName ${patronymic ?? ''}'.trim();
  
  String get genderText => gender == 'm' ? 'Мужской' : 'Женский';
  
  String get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return '$age лет';
  }
}