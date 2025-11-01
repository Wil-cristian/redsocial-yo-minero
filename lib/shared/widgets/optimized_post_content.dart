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
    // Determinar si es oro o plata basado en el índice del precio
    final isGold = (post.productPrice?.toInt() ?? 0) % 2 == 0;
    final accentColor = isGold ? const Color(0xFFD4AF37) : const Color(0xFFC0C0C0);
    final lightAccent = isGold ? const Color(0xFFF4E4C1) : const Color(0xFFE8E8E8);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header minimalista
          if (post.productPrice != null)
            Row(
              children: [
                // Precio con acento oro/plata
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [accentColor, lightAccent],
                    ),
                  ),
                  child: Text(
                    '\$${post.productPrice!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const Spacer(),
                // Botón Ver detalles minimalista
                if (onViewDetails != null)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: accentColor.withValues(alpha: 0.1),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onViewDetails,
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_forward, size: 18, color: accentColor),
                              const SizedBox(width: 8),
                              Text(
                                'Ver detalles',
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  letterSpacing: -0.2,
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
          
          // Carrusel de imágenes minimalista
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
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFFFAFAFA),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          post.productImages![index],
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Badge minimalista de número
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white.withValues(alpha: 0.9),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${index + 1}/${post.productImages!.length}',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              letterSpacing: 0.5,
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
          
          // Stock minimalista
          if (post.productStock != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: post.productStock! > 5 ? accentColor : const Color(0xFF999999),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  post.productStock! > 5
                      ? 'En stock'
                      : 'Últimas ${post.productStock} unidades',
                  style: TextStyle(
                    color: const Color(0xFF666666),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ],
        ],
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
    // Determinar si es oro o plata basado en el índice del precio
    final isGold = (post.pricingFrom?.toInt() ?? 0) % 2 == 0;
    final accentColor = isGold ? const Color(0xFFD4AF37) : const Color(0xFFC0C0C0);
    final lightAccent = isGold ? const Color(0xFFF4E4C1) : const Color(0xFFE8E8E8);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header minimalista
          if (post.pricingFrom != null)
            Row(
              children: [
                // Precio con acento oro/plata
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [accentColor, lightAccent],
                    ),
                  ),
                  child: Text(
                    '\$${post.pricingFrom!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const Spacer(),
                // Botón Ver detalles minimalista
                if (onViewDetails != null)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: accentColor.withValues(alpha: 0.1),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onViewDetails,
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_forward, size: 18, color: accentColor),
                              const SizedBox(width: 8),
                              Text(
                                'Ver detalles',
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  letterSpacing: -0.2,
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
          
          // Información adicional minimalista
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (post.pricingFrom != null)
                _buildMinimalChip(
                  'Desde \$${post.pricingFrom!.toInt()}',
                  Icons.attach_money,
                  accentColor,
                ),
              if (post.pricingTo != null)
                _buildMinimalChip(
                  'Hasta \$${post.pricingTo!.toInt()}',
                  Icons.price_change,
                  accentColor,
                ),
              if (post.availability != null)
                _buildMinimalChip(
                  post.availability!,
                  Icons.access_time,
                  accentColor,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalChip(String text, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: accentColor.withValues(alpha: 0.08),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accentColor, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: -0.1,
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
