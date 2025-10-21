import 'package:flutter/material.dart';
import 'core/theme/colors.dart';
import 'core/suggestions/intelligent_suggestion_engine.dart';
import 'shared/models/user.dart';
import 'shared/models/post.dart';

class SuggestionsPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const SuggestionsPage({super.key, this.currentUser});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String get _userType => widget.currentUser?['accountType'] ?? 'individual';

  // Datos simulados para demostración
  final List<Map<String, dynamic>> _smartComments = [];
  final List<Map<String, dynamic>> _smartOffers = [];
  final List<Map<String, dynamic>> _userSuggestions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _generateSmartSuggestions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getUserColor() {
    switch (_userType) {
      case 'individual':
        return AppColors.primary;
      case 'worker':
        return AppColors.secondary;
      case 'company':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  void _generateSmartSuggestions() {
    final userName = widget.currentUser?['name'] ?? 'Usuario';
    final userType = _userType;
    
    // Generar comentarios inteligentes basados en el perfil
    _smartComments.addAll([
      {
        'id': '1',
        'title': 'Comentario sobre Seguridad Minera',
        'content': 'Basado en tu perfil como $userType, podrías comentar sobre las nuevas normativas de seguridad en minas subterráneas. Tu experiencia sería valiosa para la comunidad.',
        'relevance': 'Alta',
        'category': 'Seguridad',
        'suggestedPost': 'Nueva normativa de seguridad OSHA 2025',
        'aiGenerated': true,
        'confidence': 0.92,
      },
      {
        'id': '2',
        'title': 'Compartir experiencia técnica',
        'content': 'Dado tu background, podrías compartir insights sobre el mantenimiento preventivo de equipos de perforación. Esto podría generar mucho engagement.',
        'relevance': 'Media',
        'category': 'Técnico',
        'suggestedPost': 'Mejores prácticas en mantenimiento de maquinaria',
        'aiGenerated': true,
        'confidence': 0.87,
      },
      {
        'id': '3',
        'title': 'Tendencias del mercado',
        'content': 'Tu perfil indica conocimiento en el sector. Podrías comentar sobre las fluctuaciones recientes en el precio de minerales y su impacto en las operaciones.',
        'relevance': 'Alta',
        'category': 'Mercado',
        'suggestedPost': 'Análisis de precios Q4 2025',
        'aiGenerated': true,
        'confidence': 0.89,
      },
    ]);

    // Generar ofertas inteligentes
    _smartOffers.addAll([
      {
        'id': '1',
        'title': 'Consultoría en Seguridad Industrial',
        'description': 'Basado en tu experiencia, podrías ofrecer servicios de consultoría en seguridad para empresas mineras pequeñas.',
        'suggestedPrice': '\$150-300/hora',
        'demand': 'Alta',
        'competition': 'Media',
        'category': 'Consultoría',
        'targetAudience': 'Empresas mineras pequeñas y medianas',
        'aiGenerated': true,
        'confidence': 0.94,
        'potentialEarnings': '\$3,000-8,000/mes',
      },
      {
        'id': '2',
        'title': 'Capacitación en Equipos Especializados',
        'description': 'Tu perfil sugiere que podrías crear cursos de capacitación para operadores de maquinaria pesada minera.',
        'suggestedPrice': '\$200-500/curso',
        'demand': 'Media',
        'competition': 'Baja',
        'category': 'Educación',
        'targetAudience': 'Operadores y técnicos',
        'aiGenerated': true,
        'confidence': 0.85,
        'potentialEarnings': '\$1,500-4,000/mes',
      },
      {
        'id': '3',
        'title': 'Inspección de Cumplimiento Normativo',
        'description': 'Podrías ofrecer servicios de inspección y auditoría de cumplimiento normativo para minas en desarrollo.',
        'suggestedPrice': '\$500-1,200/inspección',
        'demand': 'Alta',
        'competition': 'Alta',
        'category': 'Auditoría',
        'targetAudience': 'Minas en desarrollo y expansión',
        'aiGenerated': true,
        'confidence': 0.91,
        'potentialEarnings': '\$4,000-12,000/mes',
      },
    ]);

    // Generar sugerencias de usuarios para conectar
    _userSuggestions.addAll([
      {
        'id': '1',
        'name': 'María Elena Rodríguez',
        'title': 'Ingeniera de Seguridad Minera',
        'company': 'SafeMining Corp',
        'compatibility': 0.89,
        'reason': 'Especialización similar en seguridad, ubicación cercana (45km), experiencia complementaria',
        'avatar': 'M',
        'type': 'individual',
        'commonInterests': ['Seguridad Industrial', 'Normativas OSHA', 'Capacitación'],
        'potentialCollaboration': 'Desarrollo conjunto de protocolos de seguridad',
      },
      {
        'id': '2',
        'name': 'Carlos Mining Solutions',
        'title': 'Proveedor de Equipos',
        'company': 'Carlos Mining Solutions S.A.S',
        'compatibility': 0.76,
        'reason': 'Complemento perfecto: tú ofreces consultoría, ellos equipos especializados',
        'avatar': 'C',
        'type': 'company',
        'commonInterests': ['Equipos de Perforación', 'Innovación Tecnológica'],
        'potentialCollaboration': 'Partnership para ofrecer soluciones integrales',
      },
      {
        'id': '3',
        'name': 'Grupo Técnicos Antioquia',
        'title': 'Red de Profesionales',
        'company': 'Colectivo Independiente',
        'compatibility': 0.82,
        'reason': 'Red profesional en tu región con especialistas afines, ideal para networking',
        'avatar': 'G',
        'type': 'worker',
        'commonInterests': ['Networking', 'Capacitación Continua', 'Proyectos Colaborativos'],
        'potentialCollaboration': 'Participación en proyectos grupales y capacitaciones',
      },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final userColor = _getUserColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sugerencias Inteligentes'),
        backgroundColor: userColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshSuggestions(),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterOptions(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.comment),
              text: 'Comentarios',
            ),
            Tab(
              icon: Icon(Icons.local_offer),
              text: 'Ofertas',
            ),
            Tab(
              icon: Icon(Icons.people),
              text: 'Conexiones',
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              userColor.withOpacity(0.05),
              Colors.grey[50]!,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildCommentsTab(),
            _buildOffersTab(),
            _buildConnectionsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generateNewSuggestions(),
        backgroundColor: userColor,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text('Nueva IA', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCommentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _smartComments.length,
      itemBuilder: (context, index) {
        final comment = _smartComments[index];
        return _buildCommentSuggestionCard(comment);
      },
    );
  }

  Widget _buildOffersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _smartOffers.length,
      itemBuilder: (context, index) {
        final offer = _smartOffers[index];
        return _buildOfferSuggestionCard(offer);
      },
    );
  }

  Widget _buildConnectionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userSuggestions.length,
      itemBuilder: (context, index) {
        final user = _userSuggestions[index];
        return _buildUserSuggestionCard(user);
      },
    );
  }

  Widget _buildCommentSuggestionCard(Map<String, dynamic> comment) {
    final userColor = _getUserColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: userColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: userColor),
                      const SizedBox(width: 4),
                      Text(
                        'IA Generado',
                        style: TextStyle(
                          color: userColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRelevanceColor(comment['relevance']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    comment['relevance'],
                    style: TextStyle(
                      color: _getRelevanceColor(comment['relevance']),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              comment['title'],
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              comment['content'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.info, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Post sugerido: ${comment['suggestedPost']}',
                      style: TextStyle(
                        color: AppColors.info,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _previewComment(comment),
                    icon: const Icon(Icons.preview),
                    label: const Text('Vista Previa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: userColor,
                      side: BorderSide(color: userColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _publishComment(comment),
                    icon: const Icon(Icons.send),
                    label: const Text('Publicar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: userColor,
                      foregroundColor: Colors.white,
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

  Widget _buildOfferSuggestionCard(Map<String, dynamic> offer) {
    final userColor = _getUserColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up, size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        'Oportunidad',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Confianza: ${(offer['confidence'] * 100).toInt()}%',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              offer['title'],
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              offer['description'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOfferMetric('Precio Sugerido', offer['suggestedPrice']),
                ),
                Expanded(
                  child: _buildOfferMetric('Demanda', offer['demand']),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildOfferMetric('Competencia', offer['competition']),
                ),
                Expanded(
                  child: _buildOfferMetric('Ganancia Potencial', offer['potentialEarnings']),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: userColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: userColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.group, color: userColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Audiencia: ${offer['targetAudience']}',
                      style: TextStyle(
                        color: userColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _analyzeOffer(offer),
                    icon: const Icon(Icons.analytics),
                    label: const Text('Analizar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: userColor,
                      side: BorderSide(color: userColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _createOffer(offer),
                    icon: const Icon(Icons.add_business),
                    label: const Text('Crear Oferta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: userColor,
                      foregroundColor: Colors.white,
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

  Widget _buildUserSuggestionCard(Map<String, dynamic> user) {
    final userColor = _getUserColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: _getTypeColor(user['type']).withOpacity(0.2),
                  child: Text(
                    user['avatar'],
                    style: TextStyle(
                      color: _getTypeColor(user['type']),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        user['title'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (user['company'] != null)
                        Text(
                          user['company'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(user['compatibility'] * 100).toInt()}% match',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Razón de sugerencia:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user['reason'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: (user['commonInterests'] as List<String>).map((interest) => 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: userColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(
                      color: userColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ).toList(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.handshake, color: AppColors.info, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user['potentialCollaboration'],
                      style: TextStyle(
                        color: AppColors.info,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewProfile(user),
                    icon: const Icon(Icons.person),
                    label: const Text('Ver Perfil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: userColor,
                      side: BorderSide(color: userColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _connectWithUser(user),
                    icon: const Icon(Icons.connect_without_contact),
                    label: const Text('Conectar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: userColor,
                      foregroundColor: Colors.white,
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

  Widget _buildOfferMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getRelevanceColor(String relevance) {
    switch (relevance) {
      case 'Alta':
        return AppColors.success;
      case 'Media':
        return AppColors.warning;
      case 'Baja':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'individual':
        return AppColors.primary;
      case 'worker':
        return AppColors.secondary;
      case 'company':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  void _refreshSuggestions() {
    setState(() {
      _smartComments.clear();
      _smartOffers.clear();
      _userSuggestions.clear();
    });
    _generateSmartSuggestions();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sugerencias actualizadas')),
    );
  }

  void _generateNewSuggestions() {
    // Simular generación de nuevas sugerencias con IA
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Generando nuevas sugerencias...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      _refreshSuggestions();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Nuevas sugerencias generadas con IA!'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.filter_alt),
              title: const Text('Filtrar por relevancia'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('Ordenar por confianza'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Filtrar por categoría'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _previewComment(Map<String, dynamic> comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vista Previa del Comentario'),
        content: Text(comment['content']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _publishComment(comment);
            },
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
  }

  void _publishComment(Map<String, dynamic> comment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comentario "${comment['title']}" publicado exitosamente'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _analyzeOffer(Map<String, dynamic> offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Análisis de Oportunidad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Título: ${offer['title']}'),
            const SizedBox(height: 8),
            Text('Demanda del mercado: ${offer['demand']}'),
            Text('Nivel de competencia: ${offer['competition']}'),
            Text('Confianza de IA: ${(offer['confidence'] * 100).toInt()}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _createOffer(Map<String, dynamic> offer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Creando oferta: "${offer['title']}"'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _viewProfile(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo perfil de ${user['name']}'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _connectWithUser(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Solicitud de conexión enviada a ${user['name']}'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}