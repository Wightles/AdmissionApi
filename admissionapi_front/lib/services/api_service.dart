import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/applicant.dart';
import '../models/application.dart';
import '../models/exam_result.dart';
import '../models/subject_grade.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:5047/api';
  static final ApiService _instance = ApiService._internal();
  
  factory ApiService() => _instance;
  ApiService._internal();

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      throw Exception(
        'HTTP ${response.statusCode}: ${response.reasonPhrase}\n${response.body}'
      );
    }
  }

  // ========== Applicants CRUD ==========
  Future<List<Applicant>> getApplicants() async {
    try {
      print('🌐 GET запрос на: $_baseUrl/applicants');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/applicants'),
        headers: _headers,
      );
      
      print('📥 Статус: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Данные получены, тип: ${data.runtimeType}');
        
        if (data is List) {
          print('📊 Количество абитуриентов: ${data.length}');
          if (data.isNotEmpty) {
            print('📊 Первый элемент JSON: ${data[0]}');
          }
          final applicants = data.map((json) => Applicant.fromJson(json)).toList();
          print('✅ Успешно создано моделей: ${applicants.length}');
          return applicants;
        } else {
          throw Exception('Ожидался массив, получили: ${data.runtimeType}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🔥 Ошибка в getApplicants: $e');
      rethrow;
    }
  }

  Future<Applicant> getApplicant(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/applicants/$id'),
      headers: _headers,
    );
    final data = await _handleResponse(response);
    return Applicant.fromJson(data);
  }

  Future<Applicant> createApplicant(Applicant applicant) async {
    try {
      print('📤 Создание абитуриента...');
      final jsonData = applicant.toJson();
      print('📦 Отправляемые данные: $jsonData');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/applicants'),
        headers: _headers,
        body: json.encode(jsonData),
      );
      
      print('📥 Ответ: ${response.statusCode}');
      print('📄 Тело ответа: ${response.body}');
      
      final data = await _handleResponse(response);
      return Applicant.fromJson(data);
    } catch (e) {
      print('🔥 Ошибка при создании: $e');
      rethrow;
    }
  }

  Future<void> updateApplicant(int id, Applicant applicant) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/applicants/$id'),
      headers: _headers,
      body: json.encode(applicant.toJson()),
    );
    await _handleResponse(response);
  }

  Future<void> deleteApplicant(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/applicants/$id'),
      headers: _headers,
    );
    await _handleResponse(response);
  }

  // ========== Applications CRUD ==========
  Future<List<Application>> getApplications() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/applications'),
      headers: _headers,
    );
    final data = await _handleResponse(response);
    return (data as List).map((json) => Application.fromJson(json)).toList();
  }

  Future<Application> getApplication(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/applications/$id'),
      headers: _headers,
    );
    final data = await _handleResponse(response);
    return Application.fromJson(data);
  }

  Future<Application> createApplication(Application application) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/applications'),
      headers: _headers,
      body: json.encode(application.toJson()),
    );
    final data = await _handleResponse(response);
    return Application.fromJson(data);
  }

  Future<void> updateApplication(int id, Application application) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/applications/$id'),
      headers: _headers,
      body: json.encode(application.toJson()),
    );
    await _handleResponse(response);
  }

  Future<void> deleteApplication(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/applications/$id'),
      headers: _headers,
    );
    await _handleResponse(response);
  }

  // ========== Exam Results CRUD ==========
  Future<List<ExamResult>> getExamResults() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/examresults'),
      headers: _headers,
    );
    final data = await _handleResponse(response);
    return (data as List).map((json) => ExamResult.fromJson(json)).toList();
  }

  Future<List<ExamResult>> getExamResultsWithApplicant() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/examresults/with-applicant'),
      headers: _headers,
    );
    final data = await _handleResponse(response);
    return (data as List).map((json) => ExamResult.fromJson(json)).toList();
  }

  Future<ExamResult> getExamResult(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/examresults/$id'),
      headers: _headers,
    );
    final data = await _handleResponse(response);
    return ExamResult.fromJson(data);
  }

  Future<ExamResult> getExamResultWithApplicant(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/examresults/$id/with-applicant'),
      headers: _headers,
    );
    final data = await _handleResponse(response);
    return ExamResult.fromJson(data);
  }

  Future<ExamResult> createExamResult(ExamResult examResult) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/examresults'),
      headers: _headers,
      body: json.encode(examResult.toJson()),
    );
    final data = await _handleResponse(response);
    return ExamResult.fromJson(data);
  }

  Future<void> updateExamResult(int id, ExamResult examResult) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/examresults/$id'),
      headers: _headers,
      body: json.encode(examResult.toJson()),
    );
    await _handleResponse(response);
  }

  Future<void> deleteExamResult(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/examresults/$id'),
      headers: _headers,
    );
    await _handleResponse(response);
  }

  // ========== Subject Grades CRUD ==========
  Future<List<SubjectGrade>> getSubjectGrades() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/subjectgrades'),
      headers: _headers,
    );
    final data = await _handleResponse(response);
    return (data as List).map((json) => SubjectGrade.fromJson(json)).toList();
  }

  Future<SubjectGrade> getSubjectGrade(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/subjectgrades/$id'),
      headers: _headers,
    );
    final data = await _handleResponse(response);
    return SubjectGrade.fromJson(data);
  }

  Future<SubjectGrade> createSubjectGrade(SubjectGrade subjectGrade) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/subjectgrades'),
      headers: _headers,
      body: json.encode(subjectGrade.toJson()),
    );
    final data = await _handleResponse(response);
    return SubjectGrade.fromJson(data);
  }

  Future<void> updateSubjectGrade(int id, SubjectGrade subjectGrade) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/subjectgrades/$id'),
      headers: _headers,
      body: json.encode(subjectGrade.toJson()),
    );
    await _handleResponse(response);
  }

  Future<void> deleteSubjectGrade(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/subjectgrades/$id'),
      headers: _headers,
    );
    await _handleResponse(response);
  }

  // ========== Statistics ==========
  Future<Map<String, dynamic>> getStatistics() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/statistics'),
      headers: _headers,
    );
    return await _handleResponse(response);
  }
}