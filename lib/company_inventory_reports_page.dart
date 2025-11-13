import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'core/theme/app_colors_unified.dart';
import 'shared/models/inventory_item.dart';

/// Página de reportes y gráficos del inventario
/// Incluye: distribución por categoría, valor total, alertas, tendencias
class CompanyInventoryReportsPage extends StatefulWidget {
  final List<InventoryItem> items;

  const CompanyInventoryReportsPage({
    super.key,
    required this.items,
  });

  @override
  State<CompanyInventoryReportsPage> createState() => _CompanyInventoryReportsPageState();
}

class _CompanyInventoryReportsPageState extends State<CompanyInventoryReportsPage> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.background,
      appBar: AppBar(
        title: const Text('Reportes de Inventario'),
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
              icon: Icon(Icons.download, color: AppColorsUnified.textPrimary),
              onPressed: _exportReport,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            const SizedBox(height: 24),
            _buildDistributionByCategory(),
            const SizedBox(height: 24),
            _buildValueByCategory(),
            const SizedBox(height: 24),
            _buildStockStatusChart(),
            const SizedBox(height: 24),
            _buildLocationDistribution(),
            const SizedBox(height: 24),
            _buildTopValueItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalItems = widget.items.length;
    final totalValue = widget.items.fold<double>(0, (sum, item) => sum + item.totalValue);
    final criticalItems = widget.items.where((item) => item.needsRestock).length;
    final avgStockLevel = widget.items.isEmpty 
        ? 0.0 
        : widget.items.fold<double>(0, (sum, item) => sum + item.stockPercentage) / widget.items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen General',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColorsUnified.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Items',
                '$totalItems',
                'items registrados',
                Icons.inventory,
                AppColorsUnified.companyBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Valor Total',
                '\$${_formatNumber(totalValue)}',
                'en inventario',
                Icons.attach_money,
                AppColorsUnified.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Alertas',
                '$criticalItems',
                'items críticos',
                Icons.warning_amber,
                AppColorsUnified.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Nivel Promedio',
                '${avgStockLevel.toStringAsFixed(0)}%',
                'del stock mínimo',
                Icons.trending_up,
                AppColorsUnified.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsUnified.grey300),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColorsUnified.fade(color, 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColorsUnified.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColorsUnified.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppColorsUnified.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionByCategory() {
    final categoryData = _getCategoryDistribution();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsUnified.grey300),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColorsUnified.goldGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.pie_chart, color: AppColorsUnified.textPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Distribución por Categoría',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _getPieSections(categoryData),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categoryData.entries.map((entry) {
                      final color = _getCategoryColor(entry.key);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${entry.key.label}: ${entry.value}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColorsUnified.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueByCategory() {
    final valueData = _getValueByCategory();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsUnified.grey300),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColorsUnified.goldGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.bar_chart, color: AppColorsUnified.textPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Valor por Categoría',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: valueData.values.reduce(math.max) * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppColorsUnified.grey200,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '\$${_formatNumber(rod.toY)}',
                        TextStyle(
                          color: AppColorsUnified.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final categories = valueData.keys.toList();
                        if (value.toInt() >= 0 && value.toInt() < categories.length) {
                          final category = categories[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _getCategoryShortName(category),
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColorsUnified.textSecondary,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${_formatNumber(value)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColorsUnified.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: valueData.values.reduce(math.max) / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColorsUnified.grey300,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: _getBarGroups(valueData),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockStatusChart() {
    final statusData = _getStatusDistribution();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsUnified.grey300),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColorsUnified.goldGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.analytics, color: AppColorsUnified.textPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Estado del Stock',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...statusData.entries.map((entry) {
            final total = statusData.values.reduce((a, b) => a + b);
            final percentage = (entry.value / total * 100).toStringAsFixed(1);
            final color = _getStatusColor(entry.key);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.key.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColorsUnified.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${entry.value} items ($percentage%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColorsUnified.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: entry.value / total,
                      minHeight: 8,
                      backgroundColor: AppColorsUnified.grey200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLocationDistribution() {
    final locationData = _getLocationDistribution();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsUnified.grey300),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColorsUnified.goldGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.location_on, color: AppColorsUnified.textPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Distribución por Ubicación',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...locationData.entries.map((entry) {
            final color = AppColorsUnified.companyBlue;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColorsUnified.grey200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.place, color: color, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColorsUnified.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColorsUnified.fade(color, 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color),
                      ),
                      child: Text(
                        '${entry.value} items',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopValueItems() {
    final sortedItems = List<InventoryItem>.from(widget.items)
      ..sort((a, b) => b.totalValue.compareTo(a.totalValue));
    final topItems = sortedItems.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsUnified.grey300),
        boxShadow: [
          BoxShadow(
            color: AppColorsUnified.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColorsUnified.goldGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.star, color: AppColorsUnified.textPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Top 5 Items por Valor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColorsUnified.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...topItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: index < 3 
                          ? AppColorsUnified.goldGradient 
                          : LinearGradient(colors: [AppColorsUnified.grey400, AppColorsUnified.grey400]),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppColorsUnified.textPrimary,
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
                          item.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColorsUnified.textPrimary,
                          ),
                        ),
                        Text(
                          '${item.quantity} ${item.unit}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColorsUnified.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${_formatNumber(item.totalValue)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColorsUnified.success,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Map<InventoryCategory, int> _getCategoryDistribution() {
    final distribution = <InventoryCategory, int>{};
    for (final item in widget.items) {
      distribution[item.category] = (distribution[item.category] ?? 0) + 1;
    }
    return distribution;
  }

  Map<InventoryCategory, double> _getValueByCategory() {
    final values = <InventoryCategory, double>{};
    for (final item in widget.items) {
      values[item.category] = (values[item.category] ?? 0) + item.totalValue;
    }
    return values;
  }

  Map<InventoryStatus, int> _getStatusDistribution() {
    final distribution = <InventoryStatus, int>{};
    for (final item in widget.items) {
      final status = item.calculatedStatus;
      distribution[status] = (distribution[status] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, int> _getLocationDistribution() {
    final distribution = <String, int>{};
    for (final item in widget.items) {
      distribution[item.location] = (distribution[item.location] ?? 0) + 1;
    }
    return distribution;
  }

  List<PieChartSectionData> _getPieSections(Map<InventoryCategory, int> data) {
    if (data.isEmpty) return [];
    
    final total = data.values.reduce((a, b) => a + b);
    var index = 0;
    
    return data.entries.map((entry) {
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 110.0 : 100.0;
      final fontSize = isTouched ? 16.0 : 12.0;
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      
      final section = PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value.toDouble(),
        title: isTouched ? '$percentage%' : entry.value.toString(),
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColorsUnified.pureWhite,
        ),
      );
      index++;
      return section;
    }).toList();
  }

  List<BarChartGroupData> _getBarGroups(Map<InventoryCategory, double> data) {
    var index = 0;
    return data.entries.map((entry) {
      final group = BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            gradient: LinearGradient(
              colors: [
                _getCategoryColor(entry.key),
                AppColorsUnified.darken(_getCategoryColor(entry.key), 0.2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            width: 32,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ],
      );
      index++;
      return group;
    }).toList();
  }

  Color _getCategoryColor(InventoryCategory category) {
    switch (category) {
      case InventoryCategory.herramienta:
        return const Color(0xFF2196F3); // Blue
      case InventoryCategory.equipo:
        return const Color(0xFF9C27B0); // Purple
      case InventoryCategory.material:
        return const Color(0xFF4CAF50); // Green
      case InventoryCategory.repuesto:
        return const Color(0xFFFF9800); // Orange
      case InventoryCategory.consumible:
        return const Color(0xFFF44336); // Red
      case InventoryCategory.seguridad:
        return const Color(0xFF00BCD4); // Cyan
    }
  }

  Color _getStatusColor(InventoryStatus status) {
    switch (status) {
      case InventoryStatus.disponible:
        return AppColorsUnified.success;
      case InventoryStatus.bajo:
        return AppColorsUnified.warning;
      case InventoryStatus.critico:
        return AppColorsUnified.error;
      case InventoryStatus.agotado:
        return AppColorsUnified.error;
    }
  }

  String _getCategoryShortName(InventoryCategory category) {
    switch (category) {
      case InventoryCategory.herramienta:
        return 'Herr.';
      case InventoryCategory.equipo:
        return 'Equip.';
      case InventoryCategory.material:
        return 'Mat.';
      case InventoryCategory.repuesto:
        return 'Rep.';
      case InventoryCategory.consumible:
        return 'Cons.';
      case InventoryCategory.seguridad:
        return 'Seg.';
    }
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  void _exportReport() {
    // Implementar exportación a PDF/CSV
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exportando reporte...'),
        backgroundColor: AppColorsUnified.success,
      ),
    );
  }
}
