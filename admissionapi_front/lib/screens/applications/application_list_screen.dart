import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/application.dart';
import '../../models/applicant.dart';
import '../../providers/application_provider.dart';
import '../../providers/applicant_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_app_bar.dart';
import 'application_form_screen.dart';
import 'application_detail_screen.dart';

class ApplicationListScreen extends StatefulWidget {
  const ApplicationListScreen({Key? key}) : super(key: key);

  @override
  _ApplicationListScreenState createState() => _ApplicationListScreenState();
}

class _ApplicationListScreenState extends State<ApplicationListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Application> _filteredApplications = [];
  List<Applicant> _applicants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterApplications);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final applicationProvider = context.read<ApplicationProvider>();
      final applicantProvider = context.read<ApplicantProvider>();
      
      await Future.wait([
        applicationProvider.loadApplications(),
        applicantProvider.loadApplicants(),
      ]);
      
      _applicants = applicantProvider.applicants;
      _filterApplications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterApplications() {
    final provider = context.read<ApplicationProvider>();
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredApplications = provider.applications;
      } else {
        _filteredApplications = provider.applications.where((application) {
          final applicant = _getApplicantById(application.applicantId);
          if (applicant != null) {
            return applicant.fullName.toLowerCase().contains(query) ||
                   application.faculty.toLowerCase().contains(query) ||
                   application.specialty.toLowerCase().contains(query);
          }
          return false;
        }).toList();
      }
    });
  }

  Applicant? _getApplicantById(int id) {
    return _applicants.firstWhere((a) => a.id == id);
  }

  String _getApplicantName(int applicantId) {
    final applicant = _getApplicantById(applicantId);
    return applicant?.fullName ?? 'Неизвестный абитуриент (ID: $applicantId)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Заявления на поступление',
        showBackButton: true,
        onBackPressed: () => context.pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: Column(
        children: [
          // Поисковая строка
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск заявлений',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterApplications();
                        },
                      )
                    : null,
                hintText: 'Поиск по ФИО, факультету или специальности...',
              ),
            ),
          ),

          // Статистика
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildStatCard(
                  'Всего заявлений',
                  _filteredApplications.length.toString(),
                  Icons.description,
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Уникальных абитуриентов',
                  _getUniqueApplicantsCount().toString(),
                  Icons.people,
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Факультетов',
                  _getFacultiesCount().toString(),
                  Icons.school,
                  Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Список заявлений
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'Загрузка заявлений...')
                : _filteredApplications.isEmpty
                    ? _buildEmptyState()
                    : _buildApplicationsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewApplication,
        child: const Icon(Icons.add),
        tooltip: 'Добавить заявление',
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.description_outlined,
            size: 72,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Нет заявлений на поступление',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Добавьте первое заявление',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addNewApplication,
            icon: const Icon(Icons.add),
            label: const Text('Создать заявление'),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList() {
    return ListView.builder(
      itemCount: _filteredApplications.length,
      itemBuilder: (context, index) {
        final application = _filteredApplications[index];
        final applicant = _getApplicantById(application.applicantId);
        
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getFacultyColor(application.faculty),
              child: Text(
                application.faculty[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.specialty,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  application.faculty,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getApplicantName(application.applicantId),
                  style: const TextStyle(fontSize: 12),
                ),
                if (application.educationalInstitution != null)
                  Text(
                    application.educationalInstitution!,
                    style: const TextStyle(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (application.averageScore != null || application.egeScore != null)
                  Row(
                    children: [
                      if (application.averageScore != null)
                        Chip(
                          label: Text(
                            'Ср. балл: ${application.averageScore!.toStringAsFixed(1)}',
                          ),
                          backgroundColor: Colors.blue[50],
                          labelStyle: const TextStyle(fontSize: 10),
                        ),
                      if (application.egeScore != null) ...[
                        const SizedBox(width: 4),
                        Chip(
                          label: Text(
                            'ЕГЭ: ${application.egeScore!.toStringAsFixed(1)}',
                          ),
                          backgroundColor: Colors.green[50],
                          labelStyle: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (application.groupNumber != null)
                  Chip(
                    label: Text(application.groupNumber!),
                    backgroundColor: Colors.orange[50],
                    labelStyle: const TextStyle(fontSize: 10),
                  ),
                const SizedBox(width: 8),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 18),
                          SizedBox(width: 8),
                          Text('Просмотр'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Редактировать'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Удалить'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) => _handleMenuSelection(value, application),
                  child: const Icon(Icons.more_vert),
                ),
              ],
            ),
            onTap: () => _viewApplicationDetails(application),
          ),
        );
      },
    );
  }

  Color _getFacultyColor(String faculty) {
    // Генерируем цвет на основе хэша названия факультета
    int hash = faculty.hashCode;
    return Color((hash & 0xFFFFFF) | 0xFF000000).withOpacity(0.8);
  }

  int _getUniqueApplicantsCount() {
    final applicantIds = _filteredApplications
        .map((app) => app.applicantId)
        .toSet();
    return applicantIds.length;
  }

  int _getFacultiesCount() {
    final faculties = _filteredApplications
        .map((app) => app.faculty)
        .toSet();
    return faculties.length;
  }

  void _addNewApplication() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ApplicationFormScreen(),
      ),
    ).then((_) => _loadData());
  }

  void _viewApplicationDetails(Application application) {
    context.push(
      '/applications/${application.id}',
      extra: application,
    );
  }

  void _handleMenuSelection(String value, Application application) {
    switch (value) {
      case 'view':
        _viewApplicationDetails(application);
        break;
      case 'edit':
        _editApplication(application);
        break;
      case 'delete':
        _deleteApplication(application);
        break;
    }
  }

  void _editApplication(Application application) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ApplicationFormScreen(application: application),
      ),
    ).then((_) => _loadData());
  }

  void _deleteApplication(Application application) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление заявления'),
        content: Text(
          'Вы уверены, что хотите удалить заявление по специальности '
          '"${application.specialty}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<ApplicationProvider>().deleteApplication(application.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заявление успешно удалено')),
        );
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления: $e')),
        );
      }
    }
  }
}