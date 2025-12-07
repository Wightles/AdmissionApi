import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/applicant.dart';
import '../../models/application.dart';
import '../../providers/applicant_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/data_provider.dart';
import '../applications/application_form_screen.dart';
import '../exams/exam_form_screen.dart';

class ApplicantDetailScreen extends StatefulWidget {
  final int applicantId;

  const ApplicantDetailScreen({
    Key? key,
    required this.applicantId,
  }) : super(key: key);

  @override
  _ApplicantDetailScreenState createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen> {
  Applicant? _applicant;
  List<Application> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final applicantProvider = context.read<ApplicantProvider>();
      final applicationProvider = context.read<ApplicationProvider>();
      
      _applicant = await applicantProvider.getApplicantById(widget.applicantId);
      await applicationProvider.loadApplications();
      
      _applications = applicationProvider
          .getApplicationsByApplicantId(widget.applicantId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали абитуриента'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _applicant != null ? _editApplicant : null,
            tooltip: 'Редактировать',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applicant == null
              ? const Center(child: Text('Абитуриент не найден'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                child: Text(
                                  _applicant!.lastName[0],
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _applicant!.fullName,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Паспорт: ${_applicant!.passportData}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Личные данные
                      _buildSection('Личные данные', [
                        _buildInfoRow('Фамилия:', _applicant!.lastName),
                        _buildInfoRow('Имя:', _applicant!.firstName),
                        if (_applicant!.patronymic != null)
                          _buildInfoRow('Отчество:', _applicant!.patronymic!),
                        _buildInfoRow('Пол:', _applicant!.genderText),
                        _buildInfoRow('Гражданство:', _applicant!.citizenship),
                        _buildInfoRow(
                          'Дата рождения:',
                          '${_formatDate(_applicant!.birthDate)} (${_applicant!.age})',
                        ),
                      ]),

                      const SizedBox(height: 16),

                      // Контактная информация
                      _buildSection('Контактная информация', [
                        _buildInfoRow(
                          'Адрес абитуриента:',
                          _applicant!.applicantAddress,
                        ),
                        if (_applicant!.parentsAddress != null)
                          _buildInfoRow(
                            'Адрес родителей:',
                            _applicant!.parentsAddress!,
                          ),
                        if (_applicant!.foreignLanguage != null)
                          _buildInfoRow(
                            'Иностранный язык:',
                            _applicant!.foreignLanguage!,
                          ),
                      ]),

                      const SizedBox(height: 24),

                      // Заявления
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Заявления на поступление',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          ElevatedButton.icon(
                            onPressed: _addApplication,
                            icon: const Icon(Icons.add),
                            label: const Text('Добавить заявление'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildApplicationsList(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList() {
    if (_applications.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Нет заявлений на поступление'),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _applications.length,
      itemBuilder: (context, index) {
        final application = _applications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(application.specialty),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Факультет: ${application.faculty}'),
                if (application.educationalInstitution != null)
                  Text('Уч. заведение: ${application.educationalInstitution}'),
                if (application.averageScore != null)
                  Text('Средний балл: ${application.averageScore!.toStringAsFixed(2)}'),
                if (application.egeScore != null)
                  Text('ЕГЭ: ${application.egeScore!.toStringAsFixed(2)}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, size: 20),
                  onPressed: () => _viewApplicationDetails(application),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                  onPressed: () => _editApplication(application),
                ),
              ],
            ),
            onTap: () => _viewApplicationDetails(application),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _editApplicant() {
    if (_applicant != null) {
      context.push('/applicants/${_applicant!.id}/edit');
    }
  }

  void _addApplication() {
    if (_applicant != null) {
      context.push(
        '/applications/new',
        extra: _applicant!.id,
      );
    }
  }

  void _editApplication(Application application) {
    // Реализуйте редактирование заявления
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактирование заявления'),
        content: const Text('Функция редактирования в разработке'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _viewApplicationDetails(Application application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Детали заявления'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogInfoRow('Факультет:', application.faculty),
              _buildDialogInfoRow('Специальность:', application.specialty),
              if (application.educationalInstitution != null)
                _buildDialogInfoRow(
                  'Уч. заведение:',
                  application.educationalInstitution!,
                ),
              if (application.graduationYear != null)
                _buildDialogInfoRow(
                  'Год окончания:',
                  application.graduationYear!.toString(),
                ),
              if (application.averageScore != null)
                _buildDialogInfoRow(
                  'Средний балл:',
                  application.averageScore!.toStringAsFixed(2),
                ),
              if (application.egeScore != null)
                _buildDialogInfoRow(
                  'ЕГЭ:',
                  application.egeScore!.toStringAsFixed(2),
                ),
              if (application.groupNumber != null)
                _buildDialogInfoRow('Группа:', application.groupNumber!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () => _addExamResult(application),
            child: const Text('Добавить экзамен'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _addExamResult(Application application) {
    Navigator.pop(context); // Закрыть диалог
    showDialog(
      context: context,
      builder: (context) => ExamFormScreen(
        applicationId: application.id!,
      ),
    );
  }
}