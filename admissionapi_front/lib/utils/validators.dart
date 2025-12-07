import 'package:intl/intl.dart';

class CustomValidators {
  static String? passportValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Поле обязательно для заполнения';
    }
    if (value.length < 10) {
      return 'Паспортные данные должны содержать не менее 10 символов';
    }
    return null;
  }

  static String? dateOfBirthValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Поле обязательно для заполнения';
    }
    
    final date = DateTime.tryParse(value);
    if (date == null) {
      return 'Неверный формат даты';
    }
    
    final now = DateTime.now();
    if (date.isAfter(now)) {
      return 'Дата рождения не может быть в будущем';
    }
    
    int age = now.year - date.year;
    if (now.month < date.month || 
        (now.month == date.month && now.day < date.day)) {
      age--;
    }
    
    if (age < 16) {
      return 'Абитуриенту должно быть не менее 16 лет';
    }
    
    if (age > 100) {
      return 'Проверьте дату рождения';
    }
    
    return null;
  }

  static String? scoreValidator(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Поле необязательное
    }
    
    final score = double.tryParse(value);
    if (score == null) {
      return 'Введите число';
    }
    
    if (score < 0 || score > 100) {
      return 'Баллы должны быть от 0 до 100';
    }
    
    return null;
  }

  static String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Поле необязательное
    }
    
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Введите корректный номер телефона';
    }
    
    return null;
  }

  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Поле необязательное
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Введите корректный email адрес';
    }
    
    return null;
  }

  static String? validateNumeric(String? value, {String fieldName = 'Поле'}) {
    if (value == null || value.isEmpty) return null;
    
    if (double.tryParse(value) == null) {
      return '$fieldName должно быть числом';
    }
    return null;
  }

  static String? validateRequired(String? value, {String fieldName = 'Поле'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName обязательно для заполнения';
    }
    return null;
  }

  static String? validateMinLength(
    String? value, {
    int minLength = 1,
    String fieldName = 'Поле',
  }) {
    if (value == null || value.length < minLength) {
      return '$fieldName должно содержать не менее $minLength символов';
    }
    return null;
  }
}