import 'package:flutter/material.dart';
import 'core/theme/colors.dart';

class CompanyResourcesPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const CompanyResourcesPage({
    super.key,
    this.currentUser,
  });

  @override
  State<CompanyResourcesPage> createState() => _CompanyResourcesPageState();
}

class _CompanyResourcesPageState extends State<CompanyResourcesPage> {
  late List<Map<String, dynamic>> _resources;
  String _selectedCategory = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  void _loadResources() {
    _resources = [
      {
        'id': '1',
        'name': 'Excavadora CAT 390F',
        'category': 'Equipos',
        'status': 'Disponible',
        'location': 'Mina Sur',
        'purchaseDate': '2021-03-15',
        'value': 450000,
        'condition': 'Excelente',
        'hours': 2340,
      },
      {
        'id': '2',
        'name': 'Perforadora Atlas Copco',
        'category': 'Equipos',
        'status': 'En Uso',
        'location': 'Proyecto Central',
        'purchaseDate': '2022-08-20',
        'value': 350000,
        'condition': 'Bueno',
        'hours': 1580,
      },
      {
        'id': '3',
        'name': 'Casco de Seguridad (Lote)',
        'category': 'Seguridad',
        'status': 'Disponible',
        'location': 'Almacén',
        'purchaseDate': '2024-01-10',
        'value': 2500,
        'condition': 'Nueva',
        'quantity': 25,
      },
      {
        'id': '4',
        'name': 'Camión Volqueta Volvo',
        'category': 'Transporte',
        'status': 'Disponible',
        'location': 'Taller',
        'purchaseDate': '2021-11-05',
        'value': 280000,
        'condition': 'Necesita Mantenimiento',
        'hours': 4200,
      },
      {
        'id': '5',
        'name': 'Generador Diesel 500kW',
        'category': 'Equipos',
        'status': 'En Uso',
        'location': 'Mina Norte',
        'purchaseDate': '2020-06-12',
        'value': 95000,
        'condition': 'Regular',
        'hours': 6500,
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredResources {
    if (_selectedCategory == 'Todos') {
      return _resources;
    }
    return _resources
        .where((resource) => resource['category'] == _selectedCategory)
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Disponible':
        return Colors.green;
      case 'En Uso':
        return Colors.blue;
      case 'Mantenimiento':
        return Colors.orange;
      case 'Necesita Mantenimiento':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'Excelente':
        return Colors.green;
      case 'Bueno':
        return Colors.blue;
      case 'Regular':
        return Colors.orange;
      case 'Necesita Mantenimiento':
        return Colors.red;
      case 'Nueva':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestión de Recursos'),
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
            onPressed: () => _showAddResourceDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Category Filter Chips
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                children: [
                  'Todos',
                  'Equipos',
                  'Seguridad',
                  'Transporte',
                ].map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
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

            // Resources Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${_filteredResources.length} recursos',
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

            // Resources List
            if (_filteredResources.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No se encontraron recursos',
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
                itemCount: _filteredResources.length,
                itemBuilder: (context, index) {
                  final resource = _filteredResources[index];
                  return _buildResourceCard(resource);
                },
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard(Map<String, dynamic> resource) {
    final statusColor = _getStatusColor(resource['status']);
    final conditionColor = _getConditionColor(resource['condition']);

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
          onTap: () => _showResourceDetail(resource),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF45B7D1).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(resource['category']),
                          color: const Color(0xFF45B7D1),
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resource['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${resource['category']} • ${resource['location']}',
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
                        horizontal: 10,
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
                        resource['status'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Status Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: conditionColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: conditionColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Estado: ${resource['condition']}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: conditionColor,
                        ),
                      ),
                    ),
                    Text(
                      'Valor: \$${resource['value']}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Additional Info
                Text(
                  resource['hours'] != null
                      ? 'Horas de uso: ${resource['hours']}'
                      : 'Cantidad: ${resource['quantity']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Equipos':
        return Icons.construction;
      case 'Seguridad':
        return Icons.security;
      case 'Transporte':
        return Icons.local_shipping;
      default:
        return Icons.inventory;
    }
  }

  void _showResourceDetail(Map<String, dynamic> resource) {
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
                  resource['name'] as String,
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
            Text('Categoría: ${resource['category']}'),
            Text('Estado: ${resource['status']}'),
            Text('Condición: ${resource['condition']}'),
            Text('Ubicación: ${resource['location']}'),
            Text('Valor: \$${resource['value']}'),
            if (resource['hours'] != null) Text('Horas de uso: ${resource['hours']}'),
            if (resource['quantity'] != null) Text('Cantidad: ${resource['quantity']}'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.edit),
                label: const Text('Editar Recurso'),
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

  void _showAddResourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Recurso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre del Recurso',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Valor',
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
                const SnackBar(content: Text('Recurso agregado exitosamente')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF45B7D1),
            ),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
