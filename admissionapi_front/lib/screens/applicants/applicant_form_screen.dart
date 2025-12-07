import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/applicant.dart';
import '../../providers/applicant_provider.dart';

class ApplicantFormScreen extends StatefulWidget {
  final Applicant? applicant;
  const ApplicantFormScreen({Key? key, this.applicant}) : super(key: key);

  @override
  _ApplicantFormScreenState createState() => _ApplicantFormScreenState();
}

class _ApplicantFormScreenState extends State<ApplicantFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.applicant != null) {
      // Заполняем форму существующими данными
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.patchValue({
          'lastName': widget.applicant!.lastName,
          'firstName': widget.applicant!.firstName,
          'patronymic': widget.applicant!.patronymic,
          'gender': widget.applicant!.gender,
          'citizenship': widget.applicant!.citizenship,
          'birthDate': widget.applicant!.birthDate,
          'passportData': widget.applicant!.passportData,
          'applicantAddress': widget.applicant!.applicantAddress,
          'parentsAddress': widget.applicant!.parentsAddress,
          'foreignLanguage': widget.applicant!.foreignLanguage,
        });
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.saveAndValidate()) {
      setState(() => _isLoading = true);

      try {
        final data = _formKey.currentState!.value;
        final applicant = Applicant(
          id: widget.applicant?.id,
          lastName: data['lastName']?.toString().trim() ?? '',
          firstName: data['firstName']?.toString().trim() ?? '',
          patronymic: data['patronymic']?.toString().trim(),
          gender: data['gender']?.toString() ?? 'm',
          citizenship: data['citizenship']?.toString().trim() ?? '',
          birthDate: data['birthDate'] is DateTime
              ? data['birthDate']
              : DateTime.now(), // Дефолтная дата
          passportData: data['passportData']?.toString().trim() ?? '',
          applicantAddress: data['applicantAddress']?.toString().trim() ?? '',
          parentsAddress: data['parentsAddress']?.toString().trim(),
          foreignLanguage: data['foreignLanguage']?.toString().trim(),
        );

        final provider = context.read<ApplicantProvider>();
        if (widget.applicant == null) {
          await provider.createApplicant(applicant);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Абитуриент успешно создан')),
          );
        } else {
          await provider.updateApplicant(applicant);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Данные абитуриента обновлены')),
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
        title: Text(widget.applicant == null
            ? 'Новый абитуриент'
            : 'Редактирование абитуриента'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                // Личные данные
                _buildSection('Личные данные', [
                  FormBuilderTextField(
                    name: 'lastName',
                    decoration: const InputDecoration(
                      labelText: 'Фамилия *',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.required(
                      errorText: 'Обязательное поле',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'firstName',
                    decoration: const InputDecoration(
                      labelText: 'Имя *',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.required(
                      errorText: 'Обязательное поле',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'patronymic',
                    decoration: const InputDecoration(
                      labelText: 'Отчество',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ]),

                const SizedBox(height: 24),

                // Демографические данные
                _buildSection('Демографические данные', [
                  FormBuilderDropdown(
                    name: 'gender',
                    decoration: const InputDecoration(
                      labelText: 'Пол *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'm', child: Text('Мужской')),
                      DropdownMenuItem(value: 'f', child: Text('Женский')),
                    ],
                    validator: FormBuilderValidators.required(
                      errorText: 'Обязательное поле',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'citizenship',
                    decoration: const InputDecoration(
                      labelText: 'Гражданство *',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.required(
                      errorText: 'Обязательное поле',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderDateTimePicker(
                    name: 'birthDate',
                    decoration: const InputDecoration(
                      labelText: 'Дата рождения *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    inputType: InputType.date,
                    validator: FormBuilderValidators.required(
                      errorText: 'Обязательное поле',
                    ),
                  ),
                ]),

                const SizedBox(height: 24),

                // Паспортные данные
                _buildSection('Паспортные данные', [
                  FormBuilderTextField(
                    name: 'passportData',
                    decoration: const InputDecoration(
                      labelText: 'Паспортные данные *',
                      border: OutlineInputBorder(),
                      helperText: 'Серия и номер паспорта',
                    ),
                    validator: FormBuilderValidators.required(
                      errorText: 'Обязательное поле',
                    ),
                  ),
                ]),

                const SizedBox(height: 24),

                // Адреса
                _buildSection('Адреса', [
                  FormBuilderTextField(
                    name: 'applicantAddress',
                    decoration: const InputDecoration(
                      labelText: 'Адрес абитуриента *',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: FormBuilderValidators.required(
                      errorText: 'Обязательное поле',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'parentsAddress',
                    decoration: const InputDecoration(
                      labelText: 'Адрес родителей',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ]),

                const SizedBox(height: 24),

                // Дополнительная информация
                _buildSection('Дополнительная информация', [
                  FormBuilderTextField(
                    name: 'foreignLanguage',
                    decoration: const InputDecoration(
                      labelText: 'Иностранный язык',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ]),

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
                        child: Text(
                          widget.applicant == null ? 'Создать' : 'Сохранить',
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

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
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
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}
