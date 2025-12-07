import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CustomDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<DataTableColumn> columns;
  final bool sortable;
  final bool selectable;
  final Function(Map<String, dynamic>)? onRowTap;
  final Function(List<Map<String, dynamic>>)? onSelectionChanged;
  final Widget? emptyState;
  final bool loading;
  final String? searchQuery;
  final Function(String)? onSearchChanged;
  final List<Widget>? headerActions;

  const CustomDataTable({
    Key? key,
    required this.data,
    required this.columns,
    this.sortable = true,
    this.selectable = false,
    this.onRowTap,
    this.onSelectionChanged,
    this.emptyState,
    this.loading = false,
    this.searchQuery,
    this.onSearchChanged,
    this.headerActions,
  }) : super(key: key);

  @override
  _CustomDataTableState createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  List<Map<String, dynamic>> _selectedRows = [];
  List<Map<String, dynamic>> _filteredData = [];

  @override
  void initState() {
    super.initState();
    _filteredData = widget.data;
    _filterData();
  }

  @override
  void didUpdateWidget(covariant CustomDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data || widget.searchQuery != oldWidget.searchQuery) {
      _filterData();
    }
  }

  void _filterData() {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      _filteredData = widget.data;
    } else {
      final query = widget.searchQuery!.toLowerCase();
      _filteredData = widget.data.where((row) {
        return row.values.any((value) {
          return value.toString().toLowerCase().contains(query);
        });
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredData.isEmpty) {
      return widget.emptyState ??
          const Center(
            child: Text('Нет данных для отображения'),
          );
    }

    return Column(
      children: [
        if (widget.onSearchChanged != null || widget.headerActions != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                if (widget.onSearchChanged != null)
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Поиск',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: widget.onSearchChanged,
                      controller: TextEditingController(text: widget.searchQuery),
                    ),
                  ),
                if (widget.headerActions != null) ...[
                  const SizedBox(width: 16),
                  ...widget.headerActions!,
                ],
              ],
            ),
          ),
        Expanded(
          child: SfDataGrid(
            source: _DataSource(_filteredData, widget.columns),
            columns: _buildColumns(),
            selectionMode: widget.selectable
                ? SelectionMode.multiple
                : SelectionMode.none,
            allowSorting: widget.sortable,
            allowFiltering: true,
            onCellTap: (details) {
              if (details.rowColumnIndex.rowIndex > 0) {
                final index = details.rowColumnIndex.rowIndex - 1;
                if (index < _filteredData.length) {
                  widget.onRowTap?.call(_filteredData[index]);
                }
              }
            },
            columnWidthMode: ColumnWidthMode.fill,
            gridLinesVisibility: GridLinesVisibility.both,
            headerGridLinesVisibility: GridLinesVisibility.both,
          ),
        ),
        if (widget.selectable && _selectedRows.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Выбрано: ${_selectedRows.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: () {
                    setState(() {
                      _selectedRows.clear();
                      widget.onSelectionChanged?.call(_selectedRows);
                    });
                  },
                  tooltip: 'Очистить выбор',
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<GridColumn> _buildColumns() {
    return widget.columns.map((column) {
      return GridColumn(
        columnName: column.key,
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: column.alignment,
          child: Text(
            column.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        width: column.width,
      );
    }).toList();
  }
}

class _DataSource extends DataGridSource {
  _DataSource(this.data, this.columns) {
    _buildDataGridRows();
  }

  final List<Map<String, dynamic>> data;
  final List<DataTableColumn> columns;
  List<DataGridRow> _dataGridRows = [];

  void _buildDataGridRows() {
    _dataGridRows = data.map((row) {
      return DataGridRow(
        cells: columns.map((column) {
          return DataGridCell(
            columnName: column.key,
            value: row[column.key] ?? '',
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        final column = columns.firstWhere(
          (c) => c.key == cell.columnName,
          orElse: () => columns.first,
        );
        
        return Container(
          padding: const EdgeInsets.all(8),
          alignment: column.alignment,
          child: column.builder != null
              ? column.builder!(cell.value)
              : Text(cell.value.toString()),
        );
      }).toList(),
    );
  }

  @override
  Future<void> handleRefresh() async {
    _buildDataGridRows();
    notifyListeners();
  }
}

class DataTableColumn {
  final String key;
  final String title;
  final double width;
  final Alignment alignment;
  final Widget Function(dynamic value)? builder;

  const DataTableColumn({
    required this.key,
    required this.title,
    this.width = 100,
    this.alignment = Alignment.centerLeft,
    this.builder,
  });
}

class ExportButton extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<DataTableColumn> columns;
  final String fileName;

  const ExportButton({
    Key? key,
    required this.data,
    required this.columns,
    this.fileName = 'export',
  }) : super(key: key);

  Future<void> _exportToCsv(BuildContext context) async {
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет данных для экспорта')),
      );
      return;
    }

    try {
      // Создаем CSV заголовок
      final header = columns.map((c) => c.title).join(',');
      
      // Создаем строки данных
      final rows = data.map((row) {
        return columns.map((column) {
          final value = row[column.key];
          // Экранируем кавычки и запятые для CSV
          final stringValue = value?.toString() ?? '';
          if (stringValue.contains(',') || stringValue.contains('"')) {
            return '"${stringValue.replaceAll('"', '""')}"';
          }
          return stringValue;
        }).join(',');
      }).join('\n');

      final csvContent = '$header\n$rows';

      // Здесь можно добавить сохранение файла
      // Для веба используем download
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Экспортировано ${data.length} записей'),
          action: SnackBarAction(
            label: 'Скачать',
            onPressed: () {
              // Реализация скачивания файла
            },
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка экспорта: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.download),
      onPressed: () => _exportToCsv(context),
      tooltip: 'Экспорт в CSV',
    );
  }
}