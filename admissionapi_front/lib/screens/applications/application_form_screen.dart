import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/application.dart';
import '../../providers/application_provider.dart';

class ApplicationFormScreen extends StatefulWidget {
  final int? applicantId;
  final Application? application;

  const ApplicationFormScreen({
    Key? key,
    this.applicantId,
    this.application,
  }) : super(key: key);

  @override
  _ApplicationFormScreenState createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.application != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.patchValue({
          'applicantId': widget.application!.applicantId,
          'faculty': widget.application!.faculty,
          'specialty': widget.application!.specialty,
          'educationalInstitution': widget.application!.educationalInstitution,
          'graduationYear': widget.application!.graduationYear,
          'documentType': widget.application!.documentType,
          'documentNumber': widget.application!.documentNumber,
          'averageScore': widget.application!.averageScore,
          'egeScore': widget.application!.egeScore,
          'groupNumber': widget.application!.groupNumber,
        });
      });
    } else if (widget.applicantId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.patchValue({
          'applicantId': widget.applicantId,
        });
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.saveAndValidate()) {
      setState(() => _isLoading = true);
      
      try {
        final data = _formKey.currentState!.value;
        final application = Application(
          id: widget.application?.id,
          applicantId: data['applicantId'],
          faculty: data['faculty'],
          specialty: data['specialty'],
          educationalInstitution: data['educationalInstitution'],
          graduationYear: data['graduationYear'] != null 
              ? int.tryParse(data['graduationYear'].toString())
              : null,
          documentType: data['documentType'],
          documentNumber: data['documentNumber'],
          averageScore: data['averageScore']?.toDouble(),
          egeScore: data['egeScore']?.toDouble(),
          groupNumber: data['groupNumber'],
        );

        final provider = context.read<ApplicationProvider>();
        if (widget.application == null) {
          await provider.createApplication(application);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Заявление успешно создано')),
          );
        } else {
          await provider.updateApplication(application);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Заявление обновлено')),
          );
        }

        context.pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.application == null 
            ? 'Новое заявление' 
            : 'Редактирование заявления'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                if (widget.applicantId == null && widget.application == null)
                  FormBuilderTextField(
                    name: 'applicantId',
                    decoration: const InputDecoration(
                      labelText: 'ID абитуриента *',
                      border: OutlineInputBorder(),
                      hintText: 'Введите ID абитуриента',
                    ),
                    keyboardType: TextInputType.number,
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

                // Основная информация
                FormBuilderTextField(
                  name: 'faculty',
                  decoration: const InputDecoration(
                    labelText: 'Факультет *',
                    border: OutlineInputBorder(),
                    hintText: 'Например: Информационных технологий',
                  ),
                  validator: FormBuilderValidators.required(
                    errorText: 'Обязательное поле',
                  ),
                ),
                const SizedBox(height: 16),

                FormBuilderTextField(
                  name: 'specialty',
                  decoration: const InputDecoration(
                    labelText: 'Специальность *',
                    border: OutlineInputBorder(),
                    hintText: 'Например: Программная инженерия',
                  ),
                  validator: FormBuilderValidators.required(
                    errorText: 'Обязательное поле',
                  ),
                ),
                const SizedBox(height: 16),

                FormBuilderTextField(
                  name: 'educationalInstitution',
                  decoration: const InputDecoration(
                    labelText: 'Учебное заведение',
                    border: OutlineInputBorder(),
                    hintText: 'Школа/Колледж',
                  ),
                ),
                const SizedBox(height: 16),

                FormBuilderTextField(
                  name: 'graduationYear',
                  decoration: const InputDecoration(
                    labelText: 'Год окончания',
                    border: OutlineInputBorder(),
                    hintText: '2024',
                  ),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.numeric(errorText: 'Введите год'),
                    FormBuilderValidators.maxLength(4, errorText: '4 цифры'),
                    FormBuilderValidators.min(1900, errorText: 'С 1900 года'),
                    FormBuilderValidators.max(2100, errorText: 'До 2100 года'),
                  ]),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Документы
                Text(
                  'Документы об образовании',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),

                FormBuilderTextField(
                  name: 'documentType',
                  decoration: const InputDecoration(
                    labelText: 'Тип документа',
                    border: OutlineInputBorder(),
                    hintText: 'Аттестат/Диплом',
                  ),
                ),
                const SizedBox(height: 16),

                FormBuilderTextField(
                  name: 'documentNumber',
                  decoration: const InputDecoration(
                    labelText: 'Номер документа',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                FormBuilderTextField(
                  name: 'averageScore',
                  decoration: const InputDecoration(
                    labelText: 'Средний балл документа',
                    border: OutlineInputBorder(),
                    hintText: '4.5',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.numeric(errorText: 'Введите число'),
                    FormBuilderValidators.min(0, errorText: 'От 0'),
                    FormBuilderValidators.max(5, errorText: 'До 5'),
                  ]),
                ),
                const SizedBox(height: 16),

                FormBuilderTextField(
                  name: 'egeScore',
                  decoration: const InputDecoration(
                    labelText: 'Сумма баллов ЕГЭ',
                    border: OutlineInputBorder(),
                    hintText: '280',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.numeric(errorText: 'Введите число'),
                    FormBuilderValidators.min(0, errorText: 'От 0'),
                    FormBuilderValidators.max(300, errorText: 'До 300'),
                  ]),
                ),
                const SizedBox(height: 16),

                FormBuilderTextField(
                  name: 'groupNumber',
                  decoration: const InputDecoration(
                    labelText: 'Номер группы для экзаменов',
                    border: OutlineInputBorder(),
                    hintText: 'Группа 1',
                  ),
                  maxLength: 10,
                ),

                const SizedBox(height: 32),

                // Кнопки
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.application == null 
                                    ? 'Создать заявление' 
                                    : 'Сохранить изменения',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Отмена',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}