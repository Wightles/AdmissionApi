import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exam_result.dart';
import '../../providers/data_provider.dart';
import 'exam_form_screen.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({Key? key}) : super(key: key);

  @override
  _ExamListScreenState createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExamResults();
    });
  }

  Future<void> _loadExamResults() async {
    try {
      await context.read<DataProvider>().loadExamResultsWithApplicant();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты экзаменов'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExamResults,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.examResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Нет результатов экзаменов',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _addExamResult,
                    child: const Text('Добавить первый результат'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.examResults.length,
            itemBuilder: (context, index) {
              final exam = provider.examResults[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getScoreColor(exam.score),
                    child: Text(
                      exam.score.toString(),
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
                        exam.subject,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (exam.applicantName != null && exam.applicantName!.isNotEmpty)
                        Text(
                          exam.applicantName!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      if (exam.faculty != null && exam.faculty!.isNotEmpty)
                        Text(
                          '${exam.faculty}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (exam.specialty != null && exam.specialty!.isNotEmpty)
                        Text(
                          '${exam.specialty}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      Row(
                        children: [
                          Icon(Icons.meeting_room, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              exam.classroom != null && exam.classroom!.isNotEmpty
                                  ? 'Кабинет: ${exam.classroom}'
                                  : 'Кабинет не указан',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            exam.displayDate,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        'Оценка: ${exam.grade}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getScoreColor(exam.score),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                    onPressed: () => _deleteExamResult(exam),
                    tooltip: 'Удалить',
                  ),
                  onTap: () => _showExamDetails(exam),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExamResult,
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
        tooltip: 'Добавить результат экзамена',
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  void _addExamResult() {
    showDialog(
      context: context,
      builder: (context) => const ExamFormScreen(),
    ).then((_) => _loadExamResults());
  }

  void _showExamDetails(ExamResult exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.school, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.subject,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (exam.applicantName != null && exam.applicantName!.isNotEmpty)
                    Text(
                      exam.applicantName!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Студент:', exam.applicantName ?? 'Не указан'),
              if (exam.faculty != null && exam.faculty!.isNotEmpty)
                _buildDetailRow('Факультет:', exam.faculty!),
              if (exam.specialty != null && exam.specialty!.isNotEmpty)
                _buildDetailRow('Специальность:', exam.specialty!),
              _buildDetailRow('ID заявления:', exam.applicationId.toString()),
              if (exam.classroom != null && exam.classroom!.isNotEmpty)
                _buildDetailRow('Кабинет:', exam.classroom!),
              _buildDetailRow('Дата экзамена:', exam.displayDate),
              _buildDetailRow('Баллы:', '${exam.score}/100'),
              _buildDetailRow('Оценка:', exam.grade),
              const SizedBox(height: 16),
              Card(
                color: _getScoreColor(exam.score).withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: exam.score / 100,
                              backgroundColor: Colors.grey[200],
                              color: _getScoreColor(exam.score),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getScoreColor(exam.score),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${exam.score}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exam.grade,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(exam.score),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addExamResult();
            },
            child: const Text('Добавить еще'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteExamResult(ExamResult exam) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление результата'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Удалить результат экзамена по "${exam.subject}"?'),
            if (exam.applicantName != null && exam.applicantName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Студент: ${exam.applicantName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<DataProvider>().deleteExamResult(exam.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Результат по "${exam.subject}" удален' + 
                         (exam.applicantName != null ? ' (${exam.applicantName})' : '')),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления: $e')),
        );
      }
    }
  }
}