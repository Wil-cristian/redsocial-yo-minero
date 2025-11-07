import 'package:flutter/material.dart';
import 'core/theme/colors.dart';
import 'core/di/locator.dart';
import 'features/metrics/data/supabase_metrics_repository.dart';
import 'shared/models/project.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

class CompanyMetricsPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const CompanyMetricsPage({
    super.key,
    this.currentUser,
  });

  @override
  State<CompanyMetricsPage> createState() => _CompanyMetricsPageState();
}

class _CompanyMetricsPageState extends State<CompanyMetricsPage> {
  final _metricsRepo = sl<MetricsRepository>();
  String _selectedPeriod = 'Mes Actual';
  Map<String, dynamic>? _metrics;
  List<Project>? _projects;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }
  
  Future<void> _loadMetrics() async {
    if (widget.currentUser == null) return;
    
    setState(() => _isLoading = true);
    
    final companyId = widget.currentUser!['id'] as String;
    String period = 'month';
    
    switch (_selectedPeriod) {
      case 'Semana':
        period = 'week';
        break;
      case 'Trimestre':
        period = 'quarter';
        break;
      case 'Año':
        period = 'year';
        break;
      default:
        period = 'month';
    }
    
    final metrics = await _metricsRepo.getCompanyMetrics(companyId, period: period);
    final projects = await _metricsRepo.getCompanyProjects(companyId);
    
    setState(() {
      _metrics = metrics;
      _projects = projects;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Análisis y Reportes'),
        backgroundColor: AppColorsUnified.companySecondary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadReport(),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        child: Column(
          children: [
            // Period Selector
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedPeriod,
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedPeriod = value!;
                        });
                        _loadMetrics();
                      },
                      items: [
                        'Semana',
                        'Mes Actual',
                        'Trimestre',
                        'Año',
                      ]
                          .map((period) => DropdownMenuItem(
                                value: period,
                                child: Text(period),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Key Metrics Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildMetricCard(
                        title: 'Ingresos',
                        value: '\$${(_metrics?['income'] ?? 0.0).toStringAsFixed(0)}',
                        change: '+12.5%',
                        icon: Icons.trending_up,
                        color: Colors.green,
                        flex: 1,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        title: 'Gastos',
                        value: '\$${(_metrics?['expense'] ?? 0.0).toStringAsFixed(0)}',
                        change: '+5.2%',
                        icon: Icons.trending_down,
                        color: Colors.red,
                        flex: 1,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMetricCard(
                        title: 'Ganancia',
                        value: '\$${(_metrics?['profit'] ?? 0.0).toStringAsFixed(0)}',
                        change: '+18.3%',
                        icon: Icons.attach_money,
                        color: Colors.blue,
                        flex: 1,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        title: 'Proyectos',
                        value: '${_metrics?['projects_count'] ?? 0}',
                        change: '+${_metrics?['projects_count'] ?? 0}',
                        icon: Icons.folder_open,
                        color: Colors.orange,
                        flex: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Performance Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Desempeño por Proyecto',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildPerformanceChart(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Top Employees
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Empleados',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildTopEmployeesList(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Resource Usage
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Uso de Recursos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildResourceUsage(),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Color color,
    required int flex,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 14,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              change,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    if (_projects == null || _projects!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No hay proyectos activos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _projects!.take(5).map((project) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPerformanceBar(project.name, project.progress / 100),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPerformanceBar(String projectName, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              projectName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColorsUnified.companySecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopEmployeesList() {
    final topEmployees = [
      {
        'name': 'Carlos Mendez',
        'productivity': 95,
        'avatar': 'CM',
      },
      {
        'name': 'María Rodriguez',
        'productivity': 88,
        'avatar': 'MR',
      },
      {
        'name': 'Ana García',
        'productivity': 82,
        'avatar': 'AG',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: topEmployees.map((employee) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColorsUnified.companySecondary.withValues(alpha: 0.7),
                        const Color(0xFF2980B9).withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      employee['avatar'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee['name'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Productividad',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${employee['productivity']}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResourceUsage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildResourceBar('Equipos', 0.75),
          const SizedBox(height: 16),
          _buildResourceBar('Mano de Obra', 0.62),
          const SizedBox(height: 16),
          _buildResourceBar('Materiales', 0.58),
          const SizedBox(height: 16),
          _buildResourceBar('Servicios', 0.40),
        ],
      ),
    );
  }

  Widget _buildResourceBar(String resource, double usage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              resource,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              '${(usage * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: usage,
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColorsUnified.companySecondary,
            ),
          ),
        ),
      ],
    );
  }

  void _downloadReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Descargando reporte...')),
    );
  }
}
