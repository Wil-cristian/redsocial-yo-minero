import 'package:flutter/material.dart';
import 'package:yominero/shared/models/service.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'package:yominero/features/bookings/ui/book_service_page.dart';

class ServiceCardWidget extends StatelessWidget {
  final Service service;
  final VoidCallback onContact;
  final IconData Function(String) getServiceIcon;

  const ServiceCardWidget({
    super.key,
    required this.service,
    required this.onContact,
    required this.getServiceIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColorsUnified.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColorsUnified.grey300, width: 1),
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
          // HEADER (ícono + título + precio)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColorsUnified.goldGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColorsUnified.fade(AppColorsUnified.gold, 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    getServiceIcon(service.name),
                    color: AppColorsUnified.textPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColorsUnified.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColorsUnified.gold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColorsUnified.goldGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColorsUnified.fade(AppColorsUnified.gold, 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    service.priceDisplay,
                    style: const TextStyle(
                      color: AppColorsUnified.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // CONTENIDO AL MISMO NIVEL (sin InkWell)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Descripción
                Text(
                  service.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColorsUnified.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                // Tags
                if (service.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: service.tags.take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColorsUnified.grey200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColorsUnified.grey300, width: 1),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: AppColorsUnified.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )).toList(),
                  ),
                ],

                const SizedBox(height: 16),

                // Info del proveedor
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColorsUnified.goldGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColorsUnified.fade(AppColorsUnified.gold, 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: service.providerAvatarUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              service.providerAvatarUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.engineering,
                            size: 24,
                            color: AppColorsUnified.textPrimary,
                          ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.providerName ?? "Proveedor",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColorsUnified.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: AppColorsUnified.warning),
                              const SizedBox(width: 2),
                              Text(
                                '${0.0.toStringAsFixed(1)} (${0})',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColorsUnified.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // BOTONES (Reservar + Contactar)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookServicePage(service: service),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: const Text('Reservar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorsUnified.gold,
                          foregroundColor: AppColorsUnified.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onContact,
                        icon: const Icon(Icons.chat, size: 16),
                        label: const Text('Contactar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColorsUnified.textPrimary,
                          side: BorderSide(color: AppColorsUnified.grey300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
