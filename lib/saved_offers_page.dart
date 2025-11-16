import 'package:flutter/material.dart';
import 'package:yominero/core/theme/app_colors_unified.dart';
import 'package:yominero/core/auth/supabase_auth_service.dart';
import 'package:yominero/core/supabase/supabase_service.dart';
import 'package:yominero/features/bookings/ui/book_service_page.dart';
import 'package:yominero/shared/models/service.dart';

class SavedOffersPage extends StatefulWidget {
  const SavedOffersPage({super.key});

  @override
  State<SavedOffersPage> createState() => _SavedOffersPageState();
}

class _SavedOffersPageState extends State<SavedOffersPage> {
  final _supabase = SupabaseService.instance.client;
  List<Map<String, dynamic>> _savedOffers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedOffers();
  }

  Future<void> _loadSavedOffers() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) return;

      final response = await _supabase
          .rpc('get_saved_offers', params: {'user_id_param': currentUser.id});

      setState(() {
        _savedOffers = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error cargando ofertas guardadas: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeSavedOffer(String postId) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) return;

      await _supabase
          .from('saved_offers')
          .delete()
          .eq('user_id', currentUser.id)
          .eq('post_id', postId);

      _loadSavedOffers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oferta eliminada de guardados'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error eliminando oferta: $e');
    }
  }

  void _bookService(Map<String, dynamic> offer) async {
    // Verificar si tiene service_id
    String? serviceId = offer['service_id'];
    
    // Si no viene en la respuesta, obtenerlo de la BD
    if (serviceId == null) {
      try {
        final postData = await _supabase
            .from('posts')
            .select('service_id')
            .eq('id', offer['post_id'])
            .single();
        serviceId = postData['service_id'];
      } catch (e) {
        debugPrint('❌ Error obteniendo service_id: $e');
      }
    }

    if (serviceId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este servicio no tiene sistema de reservas configurado'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Cargar el servicio completo
    try {
      final serviceData = await _supabase
          .from('services')
          .select('*')
          .eq('id', serviceId)
          .single();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookServicePage(
              service: Service.fromJson(serviceData),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error cargando servicio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar el servicio'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatPrice(Map<String, dynamic> offer) {
    final from = offer['pricing_from'];
    final to = offer['pricing_to'];
    final unit = offer['pricing_unit'] ?? 'USD';

    if (from != null && to != null) {
      return '\$$from - \$$to $unit';
    } else if (from != null) {
      return 'Desde \$$from $unit';
    } else {
      return 'Precio a consultar';
    }
  }

  void _openChat(Map<String, dynamic> offer) async {
    final currentUser = SupabaseAuthService.instance.currentUser;
    if (currentUser == null) return;

    String? authorId = offer['author_id'];
    
    // Si no viene author_id en la respuesta, obtenerlo de la BD
    if (authorId == null) {
      try {
        final postData = await _supabase
            .from('posts')
            .select('author_id')
            .eq('id', offer['post_id'])
            .single();
        authorId = postData['author_id'];
      } catch (e) {
        debugPrint('❌ Error obteniendo author_id: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al abrir chat')),
          );
        }
        return;
      }
    }

    if (authorId == null) return;

    final conversation = {
      'otherUserId': authorId,
      'otherUserName': offer['author_name'] ?? 'Usuario',
      'type': 'individual',
    };

    if (mounted) {
      Navigator.pushNamed(
        context,
        '/chat-detail',
        arguments: conversation,
      );
    }
  }

  void _showOfferDetails(Map<String, dynamic> offer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOfferDetailsModal(offer),
    );
  }

  Widget _buildOfferDetailsModal(Map<String, dynamic> offer) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColorsUnified.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColorsUnified.companyBlue,
                  AppColorsUnified.companyBlue.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_offer_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer['service_name'] ?? 'Oferta especial',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: offer['availability']?.toLowerCase().contains('disponible') == true
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.orange.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          offer['availability'] ?? 'Consultar',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Precio
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColorsUnified.companyBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColorsUnified.companyBlue.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_money_rounded,
                          color: AppColorsUnified.companyBlue,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatPrice(offer),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColorsUnified.companyBlue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Título y descripción
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColorsUnified.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    offer['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColorsUnified.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    offer['content'] ?? 'Sin descripción disponible',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColorsUnified.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Información del proveedor
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColorsUnified.grey100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColorsUnified.orange,
                          child: Text(
                            (offer['author_name'] ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ofrecido por',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColorsUnified.textSecondary,
                                ),
                              ),
                              Text(
                                offer['author_name'] ?? 'Usuario',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColorsUnified.textPrimary,
                                ),
                              ),
                              if (offer['author_username'] != null)
                                Text(
                                  '@${offer['author_username']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColorsUnified.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.star,
                          color: AppColorsUnified.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${offer['likes_count'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColorsUnified.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer con botones
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _bookService(offer);
                    },
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                    label: const Text(
                      'Agendar Cita',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsUnified.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openChat(offer);
                    },
                    icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                    label: const Text(
                      'Contactar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColorsUnified.companyBlue,
                      side: const BorderSide(
                        color: AppColorsUnified.companyBlue,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsUnified.background,
      appBar: AppBar(
        title: const Text(
          'Ofertas Guardadas',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColorsUnified.textPrimary,
          ),
        ),
        backgroundColor: AppColorsUnified.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColorsUnified.textPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedOffers.isEmpty
              ? _buildEmptyState()
              : _buildOffersList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: AppColorsUnified.grey400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No tienes ofertas guardadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColorsUnified.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Guarda ofertas para verlas aquí',
            style: TextStyle(
              fontSize: 14,
              color: AppColorsUnified.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedOffers.length,
      itemBuilder: (context, index) {
        final offer = _savedOffers[index];
        return _buildOfferCard(offer);
      },
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColorsUnified.companyBlue.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColorsUnified.companyBlue.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColorsUnified.companyBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_offer_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer['service_name'] ?? 'Oferta especial',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColorsUnified.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Por ${offer['author_name'] ?? 'Usuario'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColorsUnified.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _removeSavedOffer(offer['post_id']),
                  icon: const Icon(
                    Icons.bookmark,
                    color: AppColorsUnified.companyBlue,
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColorsUnified.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money_rounded,
                      color: AppColorsUnified.companyBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatPrice(offer),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColorsUnified.companyBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _bookService(offer),
                        icon: const Icon(Icons.calendar_today_rounded, size: 16),
                        label: const Text(
                          'Agendar',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorsUnified.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openChat(offer),
                        icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                        label: const Text(
                          'Chat',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColorsUnified.companyBlue,
                          side: const BorderSide(
                            color: AppColorsUnified.companyBlue,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showOfferDetails(offer),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColorsUnified.companyBlue,
                          side: const BorderSide(
                            color: AppColorsUnified.companyBlue,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Detalles',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
