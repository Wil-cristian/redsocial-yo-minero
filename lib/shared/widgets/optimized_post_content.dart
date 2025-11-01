import 'package:flutter/material.dart';
import '../models/post.dart';
import '../../core/theme/dashboard_colors.dart';

/// Widget optimizado y adaptable que maneja TODOS los tipos de contenido de posts
/// Reemplaza: _buildProductCard, _buildNewsCard, _buildServiceCard, _buildQuestionCard, _buildOfferCard, _buildPollCard
class OptimizedPostContent extends StatelessWidget {
  final Post post;
  final Function(int)? onPollVote;
  final VoidCallback? onAddToCart;
  final VoidCallback? onViewDetails;

  const OptimizedPostContent({
    super.key,
    required this.post,
    this.onPollVote,
    this.onAddToCart,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasSpecialContent()) _buildSpecialContent(context),
        ],
      ),
    );
  }

  bool _hasSpecialContent() => post.type != PostType.community;

  Widget _buildSpecialContent(BuildContext context) {
    switch (post.type) {
      case PostType.product:
        return _buildProductContent();
      case PostType.news:
        return _buildNewsContent();
      case PostType.service:
        return _buildServiceContent();
      case PostType.request:
        return _buildRequestContent();
      case PostType.offer:
        return _buildOfferContent();
      case PostType.poll:
        return _buildPollContent();
      default:
        return const SizedBox.shrink();
    }
  }

  // === PRODUCT ===
  Widget _buildProductContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFAF0),
            Color(0xFFFFFFFF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            width: 2,
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              width: 1,
              color: const Color(0xFFE8E8E8),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Premium con Precio
              if (post.productPrice != null)
                Row(
                  children: [
                    // Precio con efecto oro
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFD700), // Oro
                            Color(0xFFFFA500), // Naranja dorado
                            Color(0xFFFFE55C), // Oro claro
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.diamond,
                            color: Colors.white,
                            size: 24,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${post.productPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Botón Ver detalles premium
                    if (onViewDetails != null)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              DashboardColors.cardBlue,
                              DashboardColors.cardBlue.withValues(alpha: 0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: DashboardColors.cardBlue.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onViewDetails,
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.shopping_bag, size: 20, color: Colors.white),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Ver detalles',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              
              // Carrusel de imágenes PREMIUM
              if (post.productImages != null && post.productImages!.isNotEmpty) ...[
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: post.productImages!.length,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Imagen con bordes premium
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                width: 3,
                                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(
                                  width: 1,
                                  color: const Color(0xFFE8E8E8),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  post.productImages![index],
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          // Badge de número de imagen
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.7),
                                    Colors.black.withValues(alpha: 0.5),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${index + 1}/${post.productImages!.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              
              // Stock premium
              if (post.productStock != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        post.productStock! > 5
                            ? const Color(0xFF50C878).withValues(alpha: 0.15)
                            : const Color(0xFFE0115F).withValues(alpha: 0.15),
                        post.productStock! > 5
                            ? const Color(0xFF00A86B).withValues(alpha: 0.1)
                            : const Color(0xFF9B111E).withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: post.productStock! > 5
                          ? const Color(0xFF50C878).withValues(alpha: 0.5)
                          : const Color(0xFFE0115F).withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        post.productStock! > 5 ? Icons.inventory : Icons.warning,
                        color: post.productStock! > 5
                            ? const Color(0xFF50C878)
                            : const Color(0xFFE0115F),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        post.productStock! > 5
                            ? 'Stock disponible: ${post.productStock}'
                            : '¡Últimas ${post.productStock} unidades!',
                        style: TextStyle(
                          color: post.productStock! > 5
                              ? const Color(0xFF50C878)
                              : const Color(0xFFE0115F),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // === NEWS ===
  Widget _buildNewsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.newsSource != null || post.newsAuthor != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: DashboardColors.cardPurple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.article, color: DashboardColors.cardPurple, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.newsSource != null) Text(post.newsSource!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      if (post.newsAuthor != null) Text('Por ${post.newsAuthor}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (post.newsCoverImage != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(post.newsCoverImage!, width: double.infinity, height: 180, fit: BoxFit.cover),
          ),
        ],
      ],
    );
  }

  // === SERVICE ===
  Widget _buildServiceContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF9F5FF), // Tono violeta muy suave
            Color(0xFFFFFFFF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9966CC).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            width: 2,
            color: const Color(0xFF9966CC).withValues(alpha: 0.3),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              width: 1,
              color: const Color(0xFFE8E8E8),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Premium con icono
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF9966CC), // Amatista
                          Color(0xFF6A0DAD), // Púrpura
                          Color(0xFFDA70D6), // Orquídea
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9966CC).withValues(alpha: 0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: const Color(0xFF9966CC).withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.handyman,
                      color: Colors.white,
                      size: 32,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Servicio Profesional',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A0DAD),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Chips Premium con gradientes
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (post.pricingFrom != null)
                    _buildPremiumServiceChip(
                      'Desde \$${post.pricingFrom!.toInt()}',
                      Icons.attach_money,
                      const LinearGradient(
                        colors: [Color(0xFF50C878), Color(0xFF00A86B)],
                      ),
                    ),
                  if (post.pricingTo != null)
                    _buildPremiumServiceChip(
                      'Hasta \$${post.pricingTo!.toInt()}',
                      Icons.price_change,
                      const LinearGradient(
                        colors: [Color(0xFF0F52BA), Color(0xFF082567)],
                      ),
                    ),
                  if (post.availability != null)
                    _buildPremiumServiceChip(
                      post.availability!,
                      Icons.access_time,
                      const LinearGradient(
                        colors: [Color(0xFF9966CC), Color(0xFF6A0DAD)],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumServiceChip(String text, IconData icon, LinearGradient gradient) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
            shadows: const [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === REQUEST (Pregunta) ===
  Widget _buildRequestContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashboardColors.cardYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DashboardColors.cardYellow.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          if (post.budgetAmount != null) ...[
            const Icon(Icons.attach_money, size: 18, color: DashboardColors.cardYellow),
            const SizedBox(width: 4),
            Text('Presupuesto: \$${post.budgetAmount!.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
          ],
          if (post.deadline != null) ...[
            const Icon(Icons.event, size: 18, color: DashboardColors.cardYellow),
            const SizedBox(width: 4),
            Text('Hasta: ${_formatDate(post.deadline!)}', style: const TextStyle(fontSize: 13)),
          ],
        ],
      ),
    );
  }

  // === OFFER ===
  Widget _buildOfferContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [DashboardColors.cardPink.withValues(alpha: 0.2), DashboardColors.cardPink.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardColors.cardPink.withValues(alpha: 0.4), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, color: DashboardColors.cardPink, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Oferta Especial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: DashboardColors.cardPink)),
                if (post.serviceName != null) Text(post.serviceName!, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === POLL (Encuesta) ===
  Widget _buildPollContent() {
    if (post.pollOptions == null || post.pollOptions!.isEmpty) return const SizedBox.shrink();

    final pollVotes = post.pollVotes ?? {};
    final totalVotes = pollVotes.values.fold<int>(0, (sum, votes) => sum + votes);
    final pollEnded = post.pollEndsAt != null && DateTime.now().isAfter(post.pollEndsAt!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.pollEndsAt != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: pollEnded ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(pollEnded ? Icons.lock : Icons.access_time, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(pollEnded ? 'Finalizada' : _getTimeRemaining(post.pollEndsAt!), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        const SizedBox(height: 12),
        ...List.generate(post.pollOptions!.length, (index) {
          final option = post.pollOptions![index];
          final votes = pollVotes[option] ?? 0;
          final percentage = totalVotes > 0 ? (votes / totalVotes * 100).round() : 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: pollEnded || onPollVote == null ? null : () => onPollVote!(index),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DashboardColors.cardOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: DashboardColors.cardOrange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(option, style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(value: percentage / 100, backgroundColor: Colors.grey.shade200, color: DashboardColors.cardOrange),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('$percentage%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('$totalVotes votos totales', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ),
      ],
    );
  }

  // === HELPERS ===
  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _getTimeRemaining(DateTime endDate) {
    final diff = endDate.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays}d restantes';
    if (diff.inHours > 0) return '${diff.inHours}h restantes';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m restantes';
    return 'Finalizando';
  }
}
