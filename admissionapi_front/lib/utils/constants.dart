import 'package:flutter/material.dart';
class AppConstants {
  static const String appName = 'Приемная комиссия';
  static const String apiBaseUrl = 'http://localhost:5047/api';
  
  // Гендеры
  static const Map<String, String> genders = {
    'm': 'Мужской',
    'f': 'Женский',
  };

  // Предметы
  static const List<String> subjects = [
    'Математика',
    'Физика',
    'Информатика',
    'Русский язык',
    'Иностранный язык',
    'История',
    'Обществознание',
    'Химия',
    'Биология',
  ];

  // Факультеты
  static const List<String> faculties = [
    'Информационных технологий',
    'Инженерный',
    'Экономический',
    'Юридический',
    'Медицинский',
    'Гуманитарный',
    'Естественных наук',
  ];

  // Специальности
  static const Map<String, List<String>> specialties = {
    'Информационных технологий': [
      'Программная инженерия',
      'Информационная безопасность',
      'Прикладная информатика',
      'Веб-технологии',
    ],
    'Инженерный': [
      'Строительство',
      'Машиностроение',
      'Электроэнергетика',
      'Архитектура',
    ],
    'Экономический': [
      'Экономика',
      'Менеджмент',
      'Финансы и кредит',
      'Бухгалтерский учет',
    ],
  };
}

class AppRoutes {
  static const String home = '/';
  static const String applicants = '/applicants';
  static const String applicantDetail = '/applicants/:id';
  static const String applicantForm = '/applicants/new';
  static const String applications = '/applications';
  static const String applicationForm = '/applications/new';
  static const String exams = '/exams';
  static const String examForm = '/exams/new';
}

class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color accent = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
}