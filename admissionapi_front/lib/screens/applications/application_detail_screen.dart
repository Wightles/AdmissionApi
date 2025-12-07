import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/application.dart';
import '../../models/exam_result.dart';
import '../../models/subject_grade.dart';
import '../../providers/application_provider.dart';
import '../../providers/data_provider.dart';
import '../exams/exam_form_screen.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final int applicationId;

  const ApplicationDetailScreen({
    Key? key,
    required this.applicationId,
  }) : super(key: key);

  @override
  _ApplicationDetailScreenState createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  Application? _application;
  List<ExamResult> _examResults = [];
  List<SubjectGrade> _subjectGrades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final applicationProvider = context.read<ApplicationProvider>();
      final dataProvider = context.read<DataProvider>();
      
      // Загружаем все заявления и находим нужное по ID
      await applicationProvider.loadApplications();
      _application = applicationProvider.applications
          .firstWhere((app) => app.id == widget.applicationId);
      
      await dataProvider.loadAllData();
      
      _examResults = dataProvider.getExamResultsByApplicationId(widget.applicationId);
      _subjectGrades = dataProvider.getSubjectGradesByApplicationId(widget.applicationId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime? date) { // Изменено на nullable
    if (date == null) return 'Не указана';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _getScoreText(int score) {
    if (score >= 90) return 'Отлично';
    if (score >= 75) return 'Хорошо';
    if (score >= 60) return 'Удовлетворительно';
    return 'Неудовлетворительно';
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getGradeText(int grade) {
    switch (grade) {
      case 5: return 'Отлично';
      case 4: return 'Хорошо';
      case 3: return 'Удовлетворительно';
      case 2: return 'Неудовлетворительно';
      case 1: return 'Плохо';
      default: return 'Н/Д';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали заявления'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _application != null ? _editApplication : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _application == null
              ? const Center(child: Text('Заявление не найдено'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Основная информация
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _application!.specialty,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _application!.faculty,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const Divider(height: 24),
                              _buildInfoRow('ID абитуриента:', _application!.applicantId.toString()),
                              if (_application!.educationalInstitution != null)
                                _buildInfoRow(
                                  'Учебное заведение:',
                                  _application!.educationalInstitution!,
                                ),
                              if (_application!.graduationYear != null)
                                _buildInfoRow(
                                  'Год окончания:',
                                  _application!.graduationYear!.toString(),
                                ),
                              if (_application!.groupNumber != null)
                                _buildInfoRow(
                                  'Номер группы:',
                                  _application!.groupNumber!,
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Оценки
                      if (_subjectGrades.isNotEmpty) ...[
                        Text(
                          'Оценки по предметам',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        _buildSubjectGrades(),
                        const SizedBox(height: 16),
                      ],

                      // Результаты экзаменов
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Результаты экзаменов',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          ElevatedButton.icon(
                            onPressed: _addExamResult,
                            icon: const Icon(Icons.add),
                            label: const Text('Добавить экзамен'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildExamResults(),

                      const SizedBox(height: 16),

                      // Сводная информация
                      if (_application!.averageScore != null || _application!.egeScore != null)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Сводная информация',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_application!.averageScore != null)
                                  _buildScoreRow(
                                    'Средний балл аттестата:',
                                    _application!.averageScore!,
                                  ),
                                if (_application!.egeScore != null)
                                  _buildScoreRow(
                                    'Сумма баллов ЕГЭ:',
                                    _application!.egeScore!,
                                  ),
                                if (_examResults.isNotEmpty)
                                  _buildScoreRow(
                                    'Средний балл экзаменов:',
                                    _calculateAverageExamScore(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Chip(
            label: Text(score.toStringAsFixed(2)),
            backgroundColor: _getScoreColor(score.toInt()),
            labelStyle: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectGrades() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: _subjectGrades.map((grade) {
            return ListTile(
              title: Text(grade.subject),
              trailing: Chip(
                label: Text(
                  '${grade.grade} (${_getGradeText(grade.grade)})',
                ),
                backgroundColor: _getGradeColor(grade.grade),
                labelStyle: const TextStyle(color: Colors.white),
              ),
              dense: true,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildExamResults() {
    if (_examResults.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('Нет результатов экзаменов'),
          ),
        ),
      );
    }

    return Card(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _examResults.length,
        itemBuilder: (context, index) {
          final exam = _examResults[index];
          return ListTile(
            title: Text(exam.subject),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (exam.classroom != null && exam.classroom!.isNotEmpty)
                  Text('Аудитория: ${exam.classroom}'),
                Text('Дата: ${_formatDate(exam.examDate)}'), // Исправлено
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${exam.score}/100',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getScoreText(exam.score),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getScoreColor(exam.score),
                  ),
                ),
              ],
            ),
            onTap: () => _showExamDetails(exam),
          );
        },
      ),
    );
  }

  Color _getGradeColor(int grade) {
    switch (grade) {
      case 5: return Colors.green;
      case 4: return Colors.blue;
      case 3: return Colors.orange;
      default: return Colors.red;
    }
  }

  double _calculateAverageExamScore() {
    if (_examResults.isEmpty) return 0;
    final total = _examResults.map((e) => e.score).reduce((a, b) => a + b);
    return total / _examResults.length;
  }

  void _editApplication() {
    if (_application != null) {
      context.push(
        '/applications/${_application!.id}/edit',
        extra: _application,
      );
    }
  }

  void _addExamResult() {
    showDialog(
      context: context,
      builder: (context) => ExamFormScreen(
        applicationId: widget.applicationId,
      ),
    ).then((_) => _loadData());
  }

  void _showExamDetails(ExamResult exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Результат: ${exam.subject}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Баллы:', '${exam.score}/100'),
            _buildDetailRow('Оценка:', _getScoreText(exam.score)),
            if (exam.classroom != null && exam.classroom!.isNotEmpty)
              _buildDetailRow('Аудитория:', exam.classroom!),
            _buildDetailRow('Дата:', _formatDate(exam.examDate)), // Исправлено
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: exam.score / 100,
              backgroundColor: Colors.grey[200],
              color: _getScoreColor(exam.score),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${exam.score}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(exam.score),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}