import 'package:flutter/foundation.dart';
import '../models/application.dart';
import '../services/api_service.dart';

class ApplicationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Application> _applications = [];
  bool _isLoading = false;
  String? _error;

  List<Application> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadApplications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _applications = await _apiService.getApplications();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Application> createApplication(Application application) async {
    final newApplication = await _apiService.createApplication(application);
    _applications.add(newApplication);
    notifyListeners();
    return newApplication;
  }

  Future<void> updateApplication(Application application) async {
    await _apiService.updateApplication(application.id!, application);
    final index = _applications.indexWhere((a) => a.id == application.id);
    if (index != -1) {
      _applications[index] = application;
      notifyListeners();
    }
  }

  Future<void> deleteApplication(int id) async {
    await _apiService.deleteApplication(id);
    _applications.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  List<Application> getApplicationsByApplicantId(int applicantId) {
    return _applications
        .where((app) => app.applicantId == applicantId)
        .toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}