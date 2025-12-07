import 'package:flutter/foundation.dart';
import '../models/applicant.dart';
import '../services/api_service.dart';

// Класс для хранения истории действий
class ApplicantAction {
  final String type; // 'added' или 'deleted'
  final int applicantId;
  final String applicantName;
  final DateTime timestamp;

  ApplicantAction({
    required this.type,
    required this.applicantId,
    required this.applicantName,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ApplicantAction.fromJson(Map<String, dynamic> json) {
    return ApplicantAction(
      type: json['type'],
      applicantId: json['applicantId'],
      applicantName: json['applicantName'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ApplicantProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Applicant> _applicants = [];
  List<ApplicantAction> _applicantActions = [];
  bool _isLoading = false;
  String? _error;
  
  // Кэширование статистики для оптимизации
  Map<String, int>? _cachedStats;
  DateTime? _lastStatsUpdate;

  List<Applicant> get applicants => _applicants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Метод для получения статистики
  Map<String, int> getStatistics() {
    final now = DateTime.now();
    
    // Проверяем, не устарели ли кэшированные данные (обновляем каждые 10 секунд)
    if (_cachedStats != null && 
        _lastStatsUpdate != null && 
        now.difference(_lastStatsUpdate!).inSeconds < 10) {
      return _cachedStats!;
    }
    
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));
    
    // Добавлено сегодня
    final addedToday = _applicantActions.where((action) {
      return action.type == 'added' && 
             action.timestamp.isAfter(today);
    }).length;
    
    // Удалено сегодня
    final deletedToday = _applicantActions.where((action) {
      return action.type == 'deleted' && 
             action.timestamp.isAfter(today);
    }).length;
    
    // Добавлено за неделю
    final addedThisWeek = _applicantActions.where((action) {
      return action.type == 'added' && 
             action.timestamp.isAfter(weekAgo);
    }).length;
    
    // Удалено за неделю
    final deletedThisWeek = _applicantActions.where((action) {
      return action.type == 'deleted' && 
             action.timestamp.isAfter(weekAgo);
    }).length;
    
    // Добавлено за месяц
    final addedThisMonth = _applicantActions.where((action) {
      return action.type == 'added' && 
             action.timestamp.isAfter(monthAgo);
    }).length;
    
    // Удалено за месяц
    final deletedThisMonth = _applicantActions.where((action) {
      return action.type == 'deleted' && 
             action.timestamp.isAfter(monthAgo);
    }).length;
    
    // Всего добавлено (за все время)
    final totalAdded = _applicantActions.where((action) {
      return action.type == 'added';
    }).length;
    
    // Всего удалено (за все время)
    final totalDeleted = _applicantActions.where((action) {
      return action.type == 'deleted';
    }).length;
    
    // Активных абитуриентов (всего в системе)
    final activeApplicants = _applicants.length;
    
    _cachedStats = {
      'total': activeApplicants,
      'addedToday': addedToday,
      'deletedToday': deletedToday,
      'addedThisWeek': addedThisWeek,
      'deletedThisWeek': deletedThisWeek,
      'addedThisMonth': addedThisMonth,
      'deletedThisMonth': deletedThisMonth,
      'totalAdded': totalAdded,
      'totalDeleted': totalDeleted,
    };
    
    _lastStatsUpdate = now;
    
    return _cachedStats!;
  }

  // Метод для получения детальной статистики
  Map<String, dynamic> getDetailedStatistics() {
    final stats = getStatistics();
    
    return {
      'stats': stats,
      'history': getRecentActions(10), // Последние 10 действий
      'totalActions': _applicantActions.length,
      'lastUpdate': DateTime.now(),
    };
  }

  // Получение последних действий - исправленный тип возвращаемого значения
  List<ApplicantAction> getRecentActions(int count) {
    final sortedActions = List<ApplicantAction>.from(_applicantActions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return sortedActions.take(count).toList();
  }

  Future<void> loadApplicants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 ApplicantProvider: Загрузка абитуриентов...');
      final data = await _apiService.getApplicants();
      
      print('✅ ApplicantProvider: Загружено ${data.length} абитуриентов');
      
      if (data.isNotEmpty) {
        print('📋 Первый абитуриент в списке:');
        print('  id: ${data[0].id}');
        print('  fullName: ${data[0].fullName}');
        print('  passportData: ${data[0].passportData}');
      }
      
      _applicants = data;
      
      // При загрузке инициализируем историю действий
      // (в реальном приложении история должна загружаться с сервера)
      _initializeActionHistory();
      
      print('✅ ApplicantProvider: Список обновлен, уведомляем слушателей');
      
    } catch (e) {
      _error = e.toString();
      print('❌ ApplicantProvider: Ошибка загрузки: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      print('✅ ApplicantProvider: Загрузка завершена');
    }
  }

  // Инициализация истории действий на основе текущих данных
  void _initializeActionHistory() {
    if (_applicantActions.isEmpty && _applicants.isNotEmpty) {
      print('📊 Инициализация истории действий...');
      // Для существующих абитуриентов создаем действия добавления
      for (final applicant in _applicants) {
        _applicantActions.add(ApplicantAction(
          type: 'added',
          applicantId: applicant.id ?? 0,
          applicantName: applicant.fullName,
          timestamp: DateTime.now().subtract(const Duration(days: 30)), // Примерно месяц назад
        ));
      }
      print('📊 Инициализировано ${_applicantActions.length} действий');
    }
  }

  Future<Applicant> getApplicantById(int id) async {
    return await _apiService.getApplicant(id);
  }

  Future<Applicant> createApplicant(Applicant applicant) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      print('➕ Создание нового абитуриента: ${applicant.fullName}');
      final newApplicant = await _apiService.createApplicant(applicant);
      _applicants.add(newApplicant);
      
      // Логируем действие добавления
      _applicantActions.add(ApplicantAction(
        type: 'added',
        applicantId: newApplicant.id ?? 0,
        applicantName: newApplicant.fullName,
        timestamp: DateTime.now(),
      ));
      
      // Сбрасываем кэш статистики
      _cachedStats = null;
      
      print('✅ Абитуриент успешно создан, ID: ${newApplicant.id}');
      return newApplicant;
      
    } catch (e) {
      print('❌ Ошибка создания абитуриента: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateApplicant(Applicant applicant) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      print('✏️ Обновление абитуриента ID: ${applicant.id}');
      await _apiService.updateApplicant(applicant.id!, applicant);
      final index = _applicants.indexWhere((a) => a.id == applicant.id);
      if (index != -1) {
        _applicants[index] = applicant;
      }
      
      print('✅ Абитуриент успешно обновлен');
      
    } catch (e) {
      print('❌ Ошибка обновления абитуриента: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteApplicant(int id) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Находим абитуриента перед удалением для логирования
      final applicantToDelete = findApplicantById(id);
      final applicantName = applicantToDelete?.fullName ?? 'Неизвестный абитуриент';
      
      print('🗑️ Удаление абитуриента ID: $id ($applicantName)');
      
      await _apiService.deleteApplicant(id);
      _applicants.removeWhere((a) => a.id == id);
      
      // Логируем действие удаления
      _applicantActions.add(ApplicantAction(
        type: 'deleted',
        applicantId: id,
        applicantName: applicantName,
        timestamp: DateTime.now(),
      ));
      
      // Сбрасываем кэш статистики
      _cachedStats = null;
      
      print('✅ Абитуриент успешно удален');
      
    } catch (e) {
      print('❌ Ошибка удаления абитуриента: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Applicant? findApplicantById(int id) {
    try {
      return _applicants.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Applicant> searchApplicants(String query) {
    if (query.isEmpty) return _applicants;
    
    return _applicants.where((applicant) {
      return applicant.lastName.toLowerCase().contains(query.toLowerCase()) ||
             applicant.firstName.toLowerCase().contains(query.toLowerCase()) ||
             applicant.passportData.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Метод для сохранения истории действий (например, в SharedPreferences)
  Future<void> saveActionHistory() async {
    // Реализуйте сохранение в локальное хранилище при необходимости
  }

  // Метод для загрузки истории действий
  Future<void> loadActionHistory() async {
    // Реализуйте загрузку из локального хранилища при необходимости
  }

  // Метод для сброса статистики (только для тестирования)
  void resetStatistics() {
    _applicantActions.clear();
    _cachedStats = null;
    notifyListeners();
    print('📊 Статистика сброшена');
  }

  // Метод для получения статистики в виде текста для отображения
  String getStatisticsText() {
    final stats = getStatistics();
    
    return '''
📊 Статистика по абитуриентам:

👥 Всего активных: ${stats['total']}
➕ Сегодня добавлено: ${stats['addedToday']}
➖ Сегодня удалено: ${stats['deletedToday']}
📈 За неделю добавлено: ${stats['addedThisWeek']}
📉 За неделю удалено: ${stats['deletedThisWeek']}
📊 Всего добавлено: ${stats['totalAdded']}
🗑️ Всего удалено: ${stats['totalDeleted']}
''';
  }
}