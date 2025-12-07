import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/applicant.dart';
import '../../providers/applicant_provider.dart';
import 'applicant_form_screen.dart';
import 'applicant_detail_screen.dart';

class ApplicantListScreen extends StatefulWidget {
  const ApplicantListScreen({Key? key}) : super(key: key);

  @override
  _ApplicantListScreenState createState() => _ApplicantListScreenState();
}

class _ApplicantListScreenState extends State<ApplicantListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Applicant> _filteredApplicants = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterApplicants);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterApplicants();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterApplicants() {
    final provider = context.read<ApplicantProvider>();
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredApplicants = provider.applicants;
      } else {
        _filteredApplicants = provider.applicants.where((applicant) {
          return applicant.lastName.toLowerCase().contains(query) ||
                 applicant.firstName.toLowerCase().contains(query) ||
                 applicant.passportData.toLowerCase().contains(query) ||
                 applicant.fullName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Абитуриенты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _filterApplicants();
            },
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск абитуриентов',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterApplicants();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Consumer<ApplicantProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_filteredApplicants.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Нет абитуриентов',
                          style: TextStyle(fontSize: 18),
                        ),
                        if (_searchController.text.isNotEmpty)
                          Text(
                            'По запросу "${_searchController.text}" ничего не найдено',
                            style: const TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: _filteredApplicants.length,
                  itemBuilder: (context, index) {
                    final applicant = _filteredApplicants[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: applicant.gender == 'm' 
                              ? Colors.blue[100] 
                              : Colors.pink[100],
                          child: Text(
                            applicant.lastName[0],
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          applicant.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Паспорт: ${applicant.passportData}'),
                            Text('Дата рождения: ${_formatDate(applicant.birthDate)}'),
                            Text('Возраст: ${applicant.age}'),
                            Text('Гражданство: ${applicant.citizenship}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editApplicant(applicant),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteApplicant(applicant),
                            ),
                          ],
                        ),
                        onTap: () => _viewApplicantDetails(applicant),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewApplicant,
        child: const Icon(Icons.add),
        tooltip: 'Добавить абитуриента',
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _addNewApplicant() {
    context.push('/applicants/new');
  }

  void _editApplicant(Applicant applicant) {
    context.push('/applicants/${applicant.id}/edit');
  }

  void _viewApplicantDetails(Applicant applicant) {
    context.push('/applicants/${applicant.id}');
  }

  void _deleteApplicant(Applicant applicant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление абитуриента'),
        content: Text('Вы уверены, что хотите удалить ${applicant.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<ApplicantProvider>().deleteApplicant(applicant.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Абитуриент ${applicant.fullName} удален'),
            backgroundColor: Colors.green,
          ),
        );
        _filterApplicants(); // Обновляем список после удаления
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка удаления: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}