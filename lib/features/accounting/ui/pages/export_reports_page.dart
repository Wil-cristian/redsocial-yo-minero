import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors_unified.dart';

class ExportReportsPage extends StatefulWidget {
  final String odooMineId;

  const ExportReportsPage({
    super.key,
    required this.odooMineId,
  });

  @override
  State<ExportReportsPage> createState() => _ExportReportsPageState();
}

class _ExportReportsPageState extends State<ExportReportsPage> {
  // ignore: unused_field
  final _currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedFormat = 'pdf';
  final Set<String> _selectedReports = {'financial_summary'};
  bool _isExporting = false;

  final List<ReportOption> _reportOptions = [
    ReportOption(
      id: 'financial_summary',
      name: 'Resumen Financiero',
      description: 'Ingresos, gastos y utilidad del período',
      icon: Icons.summarize,
      category: 'Financiero',
    ),
    ReportOption(
      id: 'income_statement',
      name: 'Estado de Resultados',
      description: 'Reporte completo de pérdidas y ganancias',
      icon: Icons.account_balance,
      category: 'Financiero',
    ),
    ReportOption(
      id: 'balance_sheet',
      name: 'Balance General',
      description: 'Activos, pasivos y capital',
      icon: Icons.balance,
      category: 'Financiero',
    ),
    ReportOption(
      id: 'cash_flow',
      name: 'Flujo de Efectivo',
      description: 'Entradas y salidas de efectivo',
      icon: Icons.swap_horiz,
      category: 'Financiero',
    ),
    ReportOption(
      id: 'transactions',
      name: 'Detalle de Transacciones',
      description: 'Listado de todas las transacciones',
      icon: Icons.receipt_long,
      category: 'Transacciones',
    ),
    ReportOption(
      id: 'receivables',
      name: 'Cuentas por Cobrar',
      description: 'Saldos pendientes de clientes',
      icon: Icons.arrow_downward,
      category: 'Cuentas',
    ),
    ReportOption(
      id: 'payables',
      name: 'Cuentas por Pagar',
      description: 'Saldos pendientes a proveedores',
      icon: Icons.arrow_upward,
      category: 'Cuentas',
    ),
    ReportOption(
      id: 'budget_vs_actual',
      name: 'Presupuesto vs Real',
      description: 'Comparativo de presupuesto ejecutado',
      icon: Icons.compare_arrows,
      category: 'Presupuesto',
    ),
    ReportOption(
      id: 'payroll',
      name: 'Reporte de Nómina',
      description: 'Detalle de pagos a empleados',
      icon: Icons.people,
      category: 'Nómina',
    ),
    ReportOption(
      id: 'inventory_valuation',
      name: 'Valoración de Inventario',
      description: 'Valor contable del inventario',
      icon: Icons.inventory,
      category: 'Inventario',
    ),
    ReportOption(
      id: 'mining_kpis',
      name: 'KPIs Mineros',
      description: 'Métricas de producción y eficiencia',
      icon: Icons.analytics,
      category: 'Minería',
    ),
    ReportOption(
      id: 'aging_report',
      name: 'Antigüedad de Saldos',
      description: 'Análisis de vencimientos',
      icon: Icons.schedule,
      category: 'Cuentas',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColorsUnified.backgroundDark,
        title: const Text(
          'Exportar Reportes',
          style: TextStyle(color: AppColorsUnified.gold),
        ),
        iconTheme: const IconThemeData(color: AppColorsUnified.gold),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showExportHistory,
            tooltip: 'Historial',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de período
            _buildPeriodSelector(),
            const SizedBox(height: 16),
            
            // Selector de formato
            _buildFormatSelector(),
            const SizedBox(height: 16),
            
            // Reportes disponibles
            _buildReportsList(),
            const SizedBox(height: 24),
            
            // Resumen de selección
            _buildSelectionSummary(),
            const SizedBox(height: 16),
            
            // Botón de exportar
            _buildExportButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.date_range, color: AppColorsUnified.gold),
              SizedBox(width: 8),
              Text(
                'Período del Reporte',
                style: TextStyle(
                  color: AppColorsUnified.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateField('Desde', _startDate, (date) {
                  setState(() => _startDate = date);
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField('Hasta', _endDate, (date) {
                  setState(() => _endDate = date);
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quick date options
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickDateChip('Hoy', 0),
              _buildQuickDateChip('7 días', 7),
              _buildQuickDateChip('30 días', 30),
              _buildQuickDateChip('90 días', 90),
              _buildQuickDateChip('Este año', 365),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime date, Function(DateTime) onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: AppColorsUnified.gold,
                  surface: AppColorsUnified.backgroundDark,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColorsUnified.backgroundDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColorsUnified.textSecondary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 11),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(date),
                    style: const TextStyle(color: AppColorsUnified.textPrimary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_today, color: AppColorsUnified.gold, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateChip(String label, int days) {
    return ActionChip(
      label: Text(label),
      labelStyle: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 12),
      backgroundColor: AppColorsUnified.backgroundDark,
      onPressed: () {
        setState(() {
          _endDate = DateTime.now();
          _startDate = days == 365 
              ? DateTime(DateTime.now().year, 1, 1)
              : DateTime.now().subtract(Duration(days: days));
        });
      },
    );
  }

  Widget _buildFormatSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.file_present, color: AppColorsUnified.gold),
              SizedBox(width: 8),
              Text(
                'Formato de Exportación',
                style: TextStyle(
                  color: AppColorsUnified.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildFormatOption('pdf', 'PDF', Icons.picture_as_pdf, Colors.red)),
              const SizedBox(width: 12),
              Expanded(child: _buildFormatOption('excel', 'Excel', Icons.table_chart, Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildFormatOption('csv', 'CSV', Icons.description, Colors.blue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormatOption(String format, String label, IconData icon, Color color) {
    final isSelected = _selectedFormat == format;
    
    return InkWell(
      onTap: () => setState(() => _selectedFormat = format),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : AppColorsUnified.backgroundDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : AppColorsUnified.textSecondary, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColorsUnified.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsList() {
    // Agrupar por categoría
    final grouped = <String, List<ReportOption>>{};
    for (var report in _reportOptions) {
      grouped.putIfAbsent(report.category, () => []).add(report);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.checklist, color: AppColorsUnified.gold),
                  SizedBox(width: 8),
                  Text(
                    'Reportes a Exportar',
                    style: TextStyle(
                      color: AppColorsUnified.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (_selectedReports.length == _reportOptions.length) {
                      _selectedReports.clear();
                    } else {
                      _selectedReports.addAll(_reportOptions.map((r) => r.id));
                    }
                  });
                },
                child: Text(
                  _selectedReports.length == _reportOptions.length ? 'Deseleccionar todo' : 'Seleccionar todo',
                  style: const TextStyle(color: AppColorsUnified.gold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...grouped.entries.map((entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: AppColorsUnified.gold,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ...entry.value.map((report) => _buildReportCheckbox(report)),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildReportCheckbox(ReportOption report) {
    final isSelected = _selectedReports.contains(report.id);
    
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedReports.remove(report.id);
          } else {
            _selectedReports.add(report.id);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColorsUnified.gold : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? AppColorsUnified.gold : AppColorsUnified.textSecondary,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.black, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Icon(report.icon, color: AppColorsUnified.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.name,
                    style: TextStyle(
                      color: isSelected ? AppColorsUnified.textPrimary : AppColorsUnified.textSecondary,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  Text(
                    report.description,
                    style: const TextStyle(
                      color: AppColorsUnified.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSummary() {
    final days = _endDate.difference(_startDate).inDays;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorsUnified.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resumen de Exportación',
                style: TextStyle(
                  color: AppColorsUnified.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColorsUnified.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _selectedFormat.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Reportes', '${_selectedReports.length}'),
              _buildSummaryItem('Período', '$days días'),
              _buildSummaryItem('Formato', _selectedFormat.toUpperCase()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColorsUnified.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColorsUnified.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedReports.isEmpty ? null : _exportReports,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsUnified.gold,
          foregroundColor: Colors.black,
          disabledBackgroundColor: AppColorsUnified.textSecondary.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isExporting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedFormat == 'pdf' 
                        ? Icons.picture_as_pdf 
                        : _selectedFormat == 'excel' 
                            ? Icons.table_chart 
                            : Icons.description,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Exportar ${_selectedReports.length} Reporte${_selectedReports.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _exportReports() async {
    setState(() => _isExporting = true);

    // Simular exportación
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isExporting = false);

    if (!mounted) return;

    // Mostrar resultado
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColorsUnified.backgroundDark,
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text(
          '¡Exportación Exitosa!',
          style: TextStyle(color: AppColorsUnified.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_selectedReports.length} reporte${_selectedReports.length > 1 ? 's' : ''} exportado${_selectedReports.length > 1 ? 's' : ''} correctamente.',
              style: const TextStyle(color: AppColorsUnified.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColorsUnified.backgroundDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedFormat == 'pdf' 
                        ? Icons.picture_as_pdf 
                        : _selectedFormat == 'excel' 
                            ? Icons.table_chart 
                            : Icons.description,
                    color: _selectedFormat == 'pdf' 
                        ? Colors.red 
                        : _selectedFormat == 'excel' 
                            ? Colors.green 
                            : Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Reporte_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.${_selectedFormat}',
                      style: const TextStyle(
                        color: AppColorsUnified.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: AppColorsUnified.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Compartiendo archivo...'),
                  backgroundColor: AppColorsUnified.gold,
                ),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Compartir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsUnified.gold,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showExportHistory() {
    final history = [
      ExportHistory(
        fileName: 'Reporte_20241208_1430.pdf',
        reports: ['Estado de Resultados', 'Balance General'],
        date: DateTime.now().subtract(const Duration(hours: 2)),
        format: 'pdf',
      ),
      ExportHistory(
        fileName: 'Nomina_Diciembre_2024.xlsx',
        reports: ['Reporte de Nómina'],
        date: DateTime.now().subtract(const Duration(days: 1)),
        format: 'excel',
      ),
      ExportHistory(
        fileName: 'Transacciones_Nov2024.csv',
        reports: ['Detalle de Transacciones'],
        date: DateTime.now().subtract(const Duration(days: 5)),
        format: 'csv',
      ),
      ExportHistory(
        fileName: 'KPIs_Mineros_Q4.pdf',
        reports: ['KPIs Mineros', 'Resumen Financiero'],
        date: DateTime.now().subtract(const Duration(days: 10)),
        format: 'pdf',
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsUnified.backgroundDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColorsUnified.textSecondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.history, color: AppColorsUnified.gold),
                      SizedBox(width: 8),
                      Text(
                        'Historial de Exportaciones',
                        style: TextStyle(
                          color: AppColorsUnified.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return _buildHistoryCard(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(ExportHistory item) {
    IconData icon;
    Color color;
    
    switch (item.format) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'excel':
        icon = Icons.table_chart;
        color = Colors.green;
        break;
      default:
        icon = Icons.description;
        color = Colors.blue;
    }

    return Card(
      color: AppColorsUnified.backgroundDark,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          item.fileName,
          style: const TextStyle(
            color: AppColorsUnified.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.reports.join(', '),
              style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _formatDate(item.date),
              style: const TextStyle(color: AppColorsUnified.textSecondary, fontSize: 11),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download, color: AppColorsUnified.gold),
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Descargando ${item.fileName}'),
                backgroundColor: AppColorsUnified.gold,
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inHours < 1) {
      return 'Hace ${diff.inMinutes} minutos';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} horas';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} días';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}

// Modelos
class ReportOption {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String category;

  ReportOption({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
  });
}

class ExportHistory {
  final String fileName;
  final List<String> reports;
  final DateTime date;
  final String format;

  ExportHistory({
    required this.fileName,
    required this.reports,
    required this.date,
    required this.format,
  });
}
