import 'package:flutter/material.dart';
import 'core/theme/colors.dart';

class CompanyProjectsPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const CompanyProjectsPage({
    super.key,
    this.currentUser,
  });

  @override
  State<CompanyProjectsPage> createState() => _CompanyProjectsPageState();
}

class _CompanyProjectsPageState extends State<CompanyProjectsPage> {
  late List<Map<String, dynamic>> _projects;
  String _selectedStatus = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    _projects = [
      {
        'id': '1',
        'name': 'Exploración Mina Sur',
        'status': 'En Progreso',
        'progress': 65,
        'team': 5,
        'startDate': '2024-01-15',
        'endDate': '2024-06-30',
        'budget': 150000,
        'spent': 97500,
        'location': 'Región Sur',
      },
      {
        'id': '2',
        'name': 'Perforación Profunda',
        'status': 'Completado',
        'progress': 100,
        'team': 8,
        'startDate': '2023-06-01',
        'endDate': '2024-02-28',
        'budget': 250000,
        'spent': 248000,
        'location': 'Región Central',
      },
      {
        'id': '3',
        'name': 'Extracción de Minerales',
        'status': 'Planificación',
        'progress': 15,
        'team': 3,
        'startDate': '2024-11-01',
        'endDate': '2025-05-31',
        'budget': 180000,
        'spent': 27000,
        'location': 'Región Norte',
      },
      {
        'id': '4',
        'name': 'Análisis Geológico',
        'status': 'En Pausa',
        'progress': 40,
        'team': 2,
        'startDate': '2024-02-01',
        'endDate': '2024-08-31',
        'budget': 75000,
        'spent': 45000,
        'location': 'Región Este',
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredProjects {
    if (_selectedStatus == 'Todos') {
      return _projects;
    }
    return _projects.where((project) => project['status'] == _selectedStatus).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'En Progreso':
        return Colors.blue;
      case 'Completado':
        return Colors.green;
      case 'Planificación':
        return Colors.orange;
      case 'En Pausa':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestión de Proyectos'),
        backgroundColor: const Color(0xFF45B7D1),
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
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProjectDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Filter Chips
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                children: ['Todos', 'En Progreso', 'Completado', 'Planificación', 'En Pausa']
                    .map((status) {
                  final isSelected = _selectedStatus == status;
                  return FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF45B7D1),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
            ),

            // Projects Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${_filteredProjects.length} proyectos',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Projects List
            if (_filteredProjects.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No se encontraron proyectos',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredProjects.length,
                itemBuilder: (context, index) {
                  final project = _filteredProjects[index];
                  return _buildProjectCard(project);
                },
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    final statusColor = _getStatusColor(project['status']);
    final budgetUsed = (project['spent'] / project['budget'] * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showProjectDetail(project),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            project['location'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        project['status'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progreso',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${project['progress']}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: project['progress'] / 100,
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF45B7D1),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat('Equipo', '${project['team']} miembros', Icons.people),
                    _buildStat(
                        'Presupuesto',
                        '\$${(project['spent'] / 1000).toStringAsFixed(0)}K / \$${(project['budget'] / 1000).toStringAsFixed(0)}K',
                        Icons.attach_money),
                    _buildStat('Uso', '$budgetUsed%', Icons.show_chart),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showProjectDetail(Map<String, dynamic> project) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  project['name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Estado: ${project['status']}'),
            Text('Ubicación: ${project['location']}'),
            Text('Equipo: ${project['team']} miembros'),
            Text('Progreso: ${project['progress']}%'),
            Text('Presupuesto: \$${project['budget']}'),
            Text('Gastado: \$${project['spent']}'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar Proyecto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF45B7D1),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Proyecto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre del Proyecto',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Ubicación',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Presupuesto',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Proyecto creado exitosamente')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF45B7D1),
            ),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}
