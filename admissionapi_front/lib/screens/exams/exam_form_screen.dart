import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../../models/exam_result.dart';
import '../../providers/data_provider.dart';

class ExamFormScreen extends StatefulWidget {
  final int? applicationId;

  const ExamFormScreen({
    Key? key,
    this.applicationId,
  }) : super(key: key);

  @override
  _ExamFormScreenState createState() => _ExamFormScreenState();
}

class _ExamFormScreenState extends State<ExamFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  double _currentScore = 60;

  @override
  void initState() {
    super.initState();
    if (widget.applicationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.patchValue({
          'applicationId': widget.applicationId,
        });
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.saveAndValidate()) {
      setState(() => _isLoading = true);

      try {
        final data = _formKey.currentState!.value;
        
        // Обработка даты - может быть null
        DateTime? examDate;
        if (data['examDate'] != null) {
          examDate = data['examDate'] as DateTime;
        }

        final examResult = ExamResult(
          applicationId: int.parse(data['applicationId'].toString()),
          classroom: data['classroom']?.toString().trim(),
          subject: data['subject'],
          examDate: examDate,
          score: int.parse(data['score'].toString()),
        );

        await context.read<DataProvider>().createExamResult(examResult);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Результат экзамена сохранен')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.school, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  const Text(
                    'Добавить результат экзамена',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FormBuilder(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: 'applicationId',
                      decoration: const InputDecoration(
                        labelText: 'ID заявления *',
                        border: OutlineInputBorder(),
                        hintText: 'Введите ID заявления',
                        prefixIcon: Icon(Icons.description),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: widget.applicationId?.toString(),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: 'Обязательное поле',
                        ),
                        FormBuilderValidators.numeric(
                          errorText: 'Введите число',
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'subject',
                      decoration: const InputDecoration(
                        labelText: 'Предмет *',
                        border: OutlineInputBorder(),
                        hintText: 'Математика, Физика и т.д.',
                        prefixIcon: Icon(Icons.menu_book),
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: 'Обязательное поле',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'classroom',
                      decoration: const InputDecoration(
                        labelText: 'Кабинет',
                        border: OutlineInputBorder(),
                        hintText: '101, 202-A и т.д.',
                        prefixIcon: Icon(Icons.meeting_room),
                      ),
                      maxLength: 20,
                    ),
                    const SizedBox(height: 16),
                    FormBuilderDateTimePicker(
                      name: 'examDate',
                      decoration: const InputDecoration(
                        labelText: 'Дата экзамена',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      inputType: InputType.date,
                      initialValue: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    ),
                    const SizedBox(height: 16),
                    // Слайдер для баллов
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Баллы (0-100) *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FormBuilderSlider(
                          name: 'score',
                          min: 0,
                          max: 100,
                          initialValue: _currentScore,
                          divisions: 100,
                          activeColor: _getScoreColor(_currentScore),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          validator: FormBuilderValidators.required(
                            errorText: 'Обязательное поле',
                          ),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _currentScore = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: _currentScore / 100,
                                backgroundColor: Colors.grey[200],
                                color: _getScoreColor(_currentScore),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getScoreColor(_currentScore),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_currentScore.toInt()}/100',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getScoreText(_currentScore),
                          style: TextStyle(
                            fontSize: 14,
                            color: _getScoreColor(_currentScore),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Сохранить',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cancel, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Отмена',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getScoreText(double score) {
    if (score >= 90) return 'Отлично';
    if (score >= 75) return 'Хорошо';
    if (score >= 60) return 'Удовлетворительно';
    return 'Неудовлетворительно';
  }
}