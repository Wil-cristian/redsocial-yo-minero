import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';

class CompanyRequestedServicesPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const CompanyRequestedServicesPage({
    super.key,
    this.currentUser,
  });

  @override
  State<CompanyRequestedServicesPage> createState() =>
      _CompanyRequestedServicesPageState();
}

class _CompanyRequestedServicesPageState
    extends State<CompanyRequestedServicesPage> {
  late List<Map<String, dynamic>> _services;
  String _selectedStatus = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _loadServices() {
    _services = [
      {
        'id': '1',
        'name': 'Mantenimiento de Equipos',
        'provider': 'Tecno Servicios S.A.S',
        'status': 'Completado',
        'date': '2024-10-15',
        'cost': 5000,
        'description': 'Mantenimiento preventivo de excavadoras',
      },
      {
        'id': '2',
        'name': 'Consultoría Ambiental',
        'provider': 'Eco Consultores',
        'status': 'En Progreso',
        'date': '2024-10-20',
        'cost': 8500,
        'description': 'Evaluación de impacto ambiental',
      },
      {
        'id': '3',
        'name': 'Seguridad y Protección',
        'provider': 'Vigilancia Pro',
        'status': 'Pendiente',
        'date': '2024-10-25',
        'cost': 12000,
        'description': 'Servicio de vigilancia 24/7',
      },
      {
        'id': '4',
        'name': 'Transporte de Minerales',
        'provider': 'Logística Minera',
        'status': 'En Progreso',
        'date': '2024-10-18',
        'cost': 15000,
        'description': 'Transporte de mineral a planta de procesamiento',
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredServices {
    if (_selectedStatus == 'Todos') {
      return _services;
    }
    return _services
        .where((service) => service['status'] == _selectedStatus)
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completado':
        return AppColorsUnified.success;
      case 'En Progreso':
        return AppColorsUnified.companyBlue;
      case 'Pendiente':
        return AppColorsUnified.warning;
      case 'Cancelado':
        return AppColorsUnified.error;
      default:
        return AppColorsUnified.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.background,
      appBar: AppBar(
        title: const Text('Servicios Pedidos'),
        backgroundColor: AppColorsUnified.pureWhite,
        foregroundColor: AppColorsUnified.textPrimary,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColorsUnified.grey200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColorsUnified.grey300),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColorsUnified.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColorsUnified.goldGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: AppColorsUnified.textPrimary),
              onPressed: () => _showAddServiceDialog(),
            ),
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
                children: ['Todos', 'Pendiente', 'En Progreso', 'Completado']
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
                    backgroundColor: AppColorsUnified.pureWhite,
                    selectedColor: AppColorsUnified.fade(AppColorsUnified.gold, 0.15),
                    side: BorderSide(
                      color: isSelected ? AppColorsUnified.gold : AppColorsUnified.grey300,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColorsUnified.gold : AppColorsUnified.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
            ),

            // Services Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${_filteredServices.length} servicios',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColorsUnified.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Services List
            if (_filteredServices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.build,
                      size: 48,
                      color: AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No se encontraron servicios',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColorsUnified.textSecondary,
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
                itemCount: _filteredServices.length,
                itemBuilder: (context, index) {
                  final service = _filteredServices[index];
                  return _buildServiceCard(service);
                },
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final statusColor = _getStatusColor(service['status']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorsUnified.grey300),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showServiceDetail(service),
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
                            service['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColorsUnified.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service['provider'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColorsUnified.textSecondary,
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
                        service['status'],
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

                // Description
                Text(
                  service['description'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColorsUnified.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fecha',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColorsUnified.textSecondary,
                          ),
                        ),
                        Text(
                          service['date'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColorsUnified.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Costo',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColorsUnified.textSecondary,
                          ),
                        ),
                        Text(
                          '\$${service['cost']}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColorsUnified.textPrimary,
                          ),
                        ),
                      ],
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

  void _showServiceDetail(Map<String, dynamic> service) {
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
                  service['name'] as String,
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
            Text('Proveedor: ${service['provider']}'),
            Text('Estado: ${service['status']}'),
            Text('Fecha: ${service['date']}'),
            Text('Costo: \$${service['cost']}'),
            Text('Descripción: ${service['description']}'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chat),
                    label: const Text('Contactar Proveedor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsUnified.companySecondary,
                      foregroundColor: AppColorsUnified.pureWhite,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsUnified.textSecondary,
                      foregroundColor: AppColorsUnified.pureWhite,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitar Nuevo Servicio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre del Servicio',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Proveedor',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Costo Estimado',
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
                const SnackBar(content: Text('Servicio solicitado exitosamente')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsUnified.companySecondary,
            ),
            child: const Text('Solicitar'),
          ),
        ],
      ),
    );
  }
}
