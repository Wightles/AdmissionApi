import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime date, {String format = 'dd.MM.yyyy'}) {
    return DateFormat(format, 'ru_RU').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm', 'ru_RU').format(dateTime);
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'ru_RU',
      symbol: '₽',
      decimalDigits: 2,
    ).format(amount);
  }

  static String formatNumber(double number, {int decimalDigits = 2}) {
    return NumberFormat.decimalPatternDigits(
      locale: 'ru_RU',
      decimalDigits: decimalDigits,
    ).format(number);
  }

  static String getInitials(String firstName, String lastName, {String? patronymic}) {
    String initials = '${_getFirstChar(lastName)}${_getFirstChar(firstName)}';
    if (patronymic != null && patronymic.isNotEmpty) {
      initials += _getFirstChar(patronymic);
    }
    return initials.toUpperCase();
  }

  static String _getFirstChar(String text) {
    if (text.isEmpty) return '';
    return text[0];
  }

  static String capitalize(String text) {
    if (text.isEmpty) return '';
    return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
  }

  static String truncate(String text, {int length = 50}) {
    if (text.length <= length) return text;
    return '${text.substring(0, length)}...';
  }

  static String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes Б';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} КБ';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} ГБ';
  }

  static Color getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  static String getScoreText(int score) {
    if (score >= 90) return 'Отлично';
    if (score >= 75) return 'Хорошо';
    if (score >= 60) return 'Удовлетворительно';
    return 'Неудовлетворительно';
  }

  static String getGradeText(int grade) {
    switch (grade) {
      case 5: return 'Отлично';
      case 4: return 'Хорошо';
      case 3: return 'Удовлетворительно';
      case 2: return 'Неудовлетворительно';
      case 1: return 'Плохо';
      default: return 'Н/Д';
    }
  }

  static Future<void> showSuccessDialog(
    BuildContext context,
    String message, {
    String title = 'Успешно',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context,
    String message, {
    String title = 'Подтверждение',
    String confirmText = 'Подтвердить',
    String cancelText = 'Отмена',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Введите корректный email адрес';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Введите корректный номер телефона';
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

  static String? validateMaxLength(
    String? value, {
    int maxLength = 255,
    String fieldName = 'Поле',
  }) {
    if (value != null && value.length > maxLength) {
      return '$fieldName должно содержать не более $maxLength символов';
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

  static String? validateRange(
    double? value, {
    required double min,
    required double max,
    String fieldName = 'Значение',
  }) {
    if (value == null) return null;
    
    if (value < min || value > max) {
      return '$fieldName должно быть от $min до $max';
    }
    return null;
  }

  static String? validateDate(
    DateTime? value, {
    DateTime? minDate,
    DateTime? maxDate,
    String fieldName = 'Дата',
  }) {
    if (value == null) return null;
    
    if (minDate != null && value.isBefore(minDate)) {
      return '$fieldName не может быть раньше ${formatDate(minDate)}';
    }
    
    if (maxDate != null && value.isAfter(maxDate)) {
      return '$fieldName не может быть позже ${formatDate(maxDate)}';
    }
    
    return null;
  }

  static Map<String, dynamic> filterNullValues(Map<String, dynamic> map) {
    final filtered = <String, dynamic>{};
    
    map.forEach((key, value) {
      if (value != null) {
        if (value is String && value.isEmpty) {
          return;
        }
        filtered[key] = value;
      }
    });
    
    return filtered;
  }

  static String generateUniqueId() {
    return DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  }

  static String maskString(String text, {int visibleChars = 4}) {
    if (text.length <= visibleChars * 2) return text;
    
    final firstPart = text.substring(0, visibleChars);
    final lastPart = text.substring(text.length - visibleChars);
    final middle = '*' * (text.length - visibleChars * 2);
    
    return '$firstPart$middle$lastPart';
  }
}