import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

class CustomFormFields {
  static FormBuilderTextField textField({
    required String name,
    required String label,
    String? hintText,
    bool required = false,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return FormBuilderTextField(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
        counterText: '',
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      validator: required
          ? FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Обязательное поле'),
              if (validator != null) validator,
            ])
          : validator,
    );
  }

  static FormBuilderDropdown dropdown({
    required String name,
    required String label,
    required List<DropdownMenuItem<dynamic>> items,
    bool required = false,
    dynamic initialValue,
  }) {
    return FormBuilderDropdown(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items,
      initialValue: initialValue,
      validator: required
          ? FormBuilderValidators.required(errorText: 'Обязательное поле')
          : null,
    );
  }

  static FormBuilderDateTimePicker datePicker({
    required String name,
    required String label,
    bool required = false,
    DateTime? initialValue,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return FormBuilderDateTimePicker(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      inputType: InputType.date,
      initialValue: initialValue,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      format: DateFormat('dd.MM.yyyy'),
      validator: required
          ? FormBuilderValidators.required(errorText: 'Обязательное поле')
          : null,
    );
  }

  static FormBuilderSlider slider({
    required String name,
    required String label,
    required double min,
    required double max,
    int? divisions,
    bool required = false,
    double initialValue = 0,
    ValueChanged<double?>? onChanged,
  }) {
    return FormBuilderSlider(
      name: name,
      min: min,
      max: max,
      divisions: divisions,
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
      ),
      displayValues: DisplayValues.all,
      onChanged: onChanged,
      validator: required
          ? FormBuilderValidators.required(errorText: 'Обязательное поле')
          : null,
    );
  }

  static FormBuilderCheckbox checkbox({
    required String name,
    required String title,
    bool initialValue = false,
  }) {
    return FormBuilderCheckbox(
      name: name,
      title: Text(title),
      initialValue: initialValue,
    );
  }

  static FormBuilderRadioGroup radioGroup({
    required String name,
    required String label,
    required List<FormBuilderFieldOption> options,
    bool required = false,
  }) {
    return FormBuilderRadioGroup(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      options: options,
      validator: required
          ? FormBuilderValidators.required(errorText: 'Обязательное поле')
          : null,
    );
  }

  static Widget sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  static Widget formActions({
    required VoidCallback onSave,
    required VoidCallback onCancel,
    bool isLoading = false,
    String saveText = 'Сохранить',
    String cancelText = 'Отмена',
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : onSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      saveText,
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                cancelText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomInputDecoration extends InputDecoration {
  const CustomInputDecoration({
    String? labelText,
    String? hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? helperText,
    String? errorText,
    bool enabled = true,
  }) : super(
          labelText: labelText,
          hintText: hintText,
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          helperText: helperText,
          errorText: errorText,
          enabled: enabled,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          filled: true,
        );

  // Альтернативный вариант без константного конструктора
  static InputDecoration create({
    String? labelText,
    String? hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? helperText,
    String? errorText,
    bool enabled = true,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      helperText: helperText,
      errorText: errorText,
      enabled: enabled,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}