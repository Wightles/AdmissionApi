import 'package:flutter/foundation.dart';
import '../models/exam_result.dart';
import '../models/subject_grade.dart';
import '../services/api_service.dart';

class DataProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<ExamResult> _examResults = [];
  List<SubjectGrade> _subjectGrades = [];
  bool _isLoading = false;
  String? _error;

  List<ExamResult> get examResults => _examResults;
  List<SubjectGrade> get subjectGrades => _subjectGrades;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        loadExamResultsWithApplicant(), // Используем новый метод
        loadSubjectGrades(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExamResults() async {
    try {
      _examResults = await _apiService.getExamResults();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadExamResultsWithApplicant() async {
    try {
      _examResults = await _apiService.getExamResultsWithApplicant();
    } catch (e) {
      _error = e.toString();
      // Fallback: загружаем обычные результаты
      await loadExamResults();
    }
    notifyListeners();
  }

  Future<void> loadSubjectGrades() async {
    try {
      _subjectGrades = await _apiService.getSubjectGrades();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<ExamResult> createExamResult(ExamResult examResult) async {
    final newExamResult = await _apiService.createExamResult(examResult);
    // После создания перезагружаем с информацией о студенте
    await loadExamResultsWithApplicant();
    return newExamResult;
  }

  Future<SubjectGrade> createSubjectGrade(SubjectGrade subjectGrade) async {
    final newSubjectGrade = await _apiService.createSubjectGrade(subjectGrade);
    _subjectGrades.add(newSubjectGrade);
    notifyListeners();
    return newSubjectGrade;
  }

  Future<void> deleteExamResult(int id) async {
    await _apiService.deleteExamResult(id);
    _examResults.removeWhere((er) => er.id == id);
    notifyListeners();
  }

  Future<void> deleteSubjectGrade(int id) async {
    await _apiService.deleteSubjectGrade(id);
    _subjectGrades.removeWhere((sg) => sg.id == id);
    notifyListeners();
  }

  List<ExamResult> getExamResultsByApplicationId(int applicationId) {
    return _examResults
        .where((er) => er.applicationId == applicationId)
        .toList();
  }

  List<ExamResult> getExamResultsByApplicantId(int applicantId) {
    return _examResults
        .where((er) => er.applicantId == applicantId)
        .toList();
  }

  List<SubjectGrade> getSubjectGradesByApplicationId(int applicationId) {
    return _subjectGrades
        .where((sg) => sg.applicationId == applicationId)
        .toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}