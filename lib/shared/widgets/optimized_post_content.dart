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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.productPrice != null)
          Row(
            children: [
              Text(
                '\$${post.productPrice!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: DashboardColors.cardBlue),
              ),
              const Spacer(),
              if (onViewDetails != null)
                ElevatedButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.shopping_bag, size: 18),
                  label: const Text('Ver detalles'),
                  style: ElevatedButton.styleFrom(backgroundColor: DashboardColors.cardBlue, foregroundColor: Colors.white),
                ),
            ],
          ),
        if (post.productImages != null && post.productImages!.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: post.productImages!.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(post.productImages![index], width: 120, height: 120, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ],
        if (post.productStock != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Stock: ${post.productStock}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ),
      ],
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (post.pricingFrom != null)
          _chip('Desde \$${post.pricingFrom!.toInt()}', Icons.attach_money, DashboardColors.cardGreen),
        if (post.pricingTo != null)
          _chip('Hasta \$${post.pricingTo!.toInt()}', Icons.price_change, DashboardColors.cardGreen),
        if (post.availability != null)
          _chip(post.availability!, Icons.access_time, DashboardColors.cardGreen),
      ],
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
  Widget _chip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _getTimeRemaining(DateTime endDate) {
    final diff = endDate.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays}d restantes';
    if (diff.inHours > 0) return '${diff.inHours}h restantes';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m restantes';
    return 'Finalizando';
  }
}
