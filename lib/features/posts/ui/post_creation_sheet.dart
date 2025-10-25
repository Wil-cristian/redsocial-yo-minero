import 'package:flutter/material.dart';
import 'package:yominero/shared/models/post.dart';
import 'package:yominero/core/posts/post_validation.dart';

typedef PostCreatedCallback = void Function(Post post);

class PostCreationSheet extends StatefulWidget {
  final Future<Post> Function({
    String? author,
    required String title,
    required String content,
    PostType type,
    List<String> tags,
    List<String> categories,
    List<String>? requiredTags,
    double? budgetAmount,
    String? budgetCurrency,
    DateTime? deadline,
    String? serviceName,
    List<String>? serviceTags,
    double? pricingFrom,
    double? pricingTo,
    String? pricingUnit,
    String? availability,
  }) create;
  final String authorName;
  final PostCreatedCallback onCreated;
  const PostCreationSheet({
    super.key,
    required this.create,
    required this.authorName,
    required this.onCreated,
  });

  @override
  State<PostCreationSheet> createState() => _PostCreationSheetState();
}

class _PostCreationSheetState extends State<PostCreationSheet> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _pricingFromCtrl = TextEditingController();
  final _pricingToCtrl = TextEditingController();
  final _productPriceCtrl = TextEditingController();
  final _productStockCtrl = TextEditingController();
  final _newsSourceCtrl = TextEditingController();
  final _newsAuthorCtrl = TextEditingController();
  PostType _type = PostType.community;
  String _productCondition = 'nuevo';
  bool _submitting = false;
  
  // Poll fields
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  bool _pollAllowMultiple = false;
  int _pollDurationDays = 7;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagsCtrl.dispose();
    _budgetCtrl.dispose();
    _pricingFromCtrl.dispose();
    _pricingToCtrl.dispose();
    _productPriceCtrl.dispose();
    _productStockCtrl.dispose();
    _newsSourceCtrl.dispose();
    _newsAuthorCtrl.dispose();
    for (var ctrl in _pollOptionControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) {
      _show('Completa título y contenido.');
      return;
    }
    if (_type == PostType.request) {
      final err = PostCreationValidator.validateRequestBudget(_budgetCtrl.text);
      if (err != null) {
        _show(err);
        return;
      }
    }
    if (_type == PostType.offer) {
      final err = PostCreationValidator.validateOfferPricing(
          _pricingFromCtrl.text, _pricingToCtrl.text);
      if (err != null) {
        _show(err);
        return;
      }
    }
    final tags = _tagsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    setState(() => _submitting = true);
    try {
      final post = await widget.create(
        title: title,
        content: content,
        type: _type,
        tags: tags,
        categories: const [],
        requiredTags: _type == PostType.request ? tags : null,
        budgetAmount: _type == PostType.request
            ? double.tryParse(_budgetCtrl.text)
            : null,
        budgetCurrency: _type == PostType.request ? 'USD' : null,
        serviceName: _type == PostType.offer ? title : null,
        serviceTags: _type == PostType.offer ? tags : null,
        pricingFrom: _type == PostType.offer
            ? double.tryParse(_pricingFromCtrl.text)
            : null,
        pricingTo: _type == PostType.offer
            ? double.tryParse(_pricingToCtrl.text)
            : null,
        pricingUnit: _type == PostType.offer ? 'unidad' : null,
        availability: _type == PostType.offer ? 'Horario flexible' : null,
      );
      widget.onCreated(post);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Nueva publicación',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Selector de tipo de post
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.article, size: 16), SizedBox(width: 4), Text('Post')]),
                  selected: _type == PostType.community,
                  onSelected: (_) => setState(() => _type = PostType.community),
                ),
                ChoiceChip(
                  label: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.help, size: 16), SizedBox(width: 4), Text('Pregunta')]),
                  selected: _type == PostType.request,
                  onSelected: (_) => setState(() => _type = PostType.request),
                ),
                ChoiceChip(
                  label: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.local_offer, size: 16), SizedBox(width: 4), Text('Oferta')]),
                  selected: _type == PostType.offer,
                  onSelected: (_) => setState(() => _type = PostType.offer),
                ),
                ChoiceChip(
                  label: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.shopping_bag, size: 16), SizedBox(width: 4), Text('Producto')]),
                  selected: _type == PostType.product,
                  onSelected: (_) => setState(() => _type = PostType.product),
                ),
                ChoiceChip(
                  label: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.work, size: 16), SizedBox(width: 4), Text('Servicio')]),
                  selected: _type == PostType.service,
                  onSelected: (_) => setState(() => _type = PostType.service),
                ),
                ChoiceChip(
                  label: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.newspaper, size: 16), SizedBox(width: 4), Text('Noticia')]),
                  selected: _type == PostType.news,
                  onSelected: (_) => setState(() => _type = PostType.news),
                ),
                ChoiceChip(
                  label: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.poll, size: 16), SizedBox(width: 4), Text('Encuesta')]),
                  selected: _type == PostType.poll,
                  onSelected: (_) => setState(() => _type = PostType.poll),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                  labelText: 'Título', border: OutlineInputBorder()),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentCtrl,
              decoration: const InputDecoration(
                  labelText: 'Contenido', border: OutlineInputBorder()),
              minLines: 4,
              maxLines: 6,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagsCtrl,
              decoration: const InputDecoration(
                  labelText: 'Tags (separados por coma)',
                  border: OutlineInputBorder()),
            ),
            
            // Campos específicos por tipo
            if (_type == PostType.request) ...[
              const SizedBox(height: 16),
              const Text('💰 Detalles de la solicitud', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _budgetCtrl,
                decoration: const InputDecoration(
                    labelText: 'Presupuesto máximo (USD)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money)),
                keyboardType: TextInputType.number,
              ),
            ],
            
            if (_type == PostType.offer || _type == PostType.service) ...[
              const SizedBox(height: 16),
              Text(_type == PostType.service ? '🔧 Detalles del servicio' : '💼 Detalles de la oferta', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextField(
                  controller: _pricingFromCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Precio desde',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money)),
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: TextField(
                  controller: _pricingToCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Precio hasta',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money)),
                  keyboardType: TextInputType.number,
                )),
              ]),
            ],
            
            if (_type == PostType.product) ...[
              const SizedBox(height: 16),
              const Text('🛍️ Detalles del producto', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(flex: 2, child: TextField(
                  controller: _productPriceCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Precio',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money)),
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 12),
                Expanded(child: TextField(
                  controller: _productStockCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Stock',
                      border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                )),
              ]),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _productCondition,
                decoration: const InputDecoration(
                  labelText: 'Condición',
                  border: OutlineInputBorder(),
                ),
                items: ['nuevo', 'usado - como nuevo', 'usado - buen estado', 'usado - regular']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _productCondition = val ?? 'nuevo'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Abrir selector de imágenes
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximamente: agregar imágenes del producto')),
                  );
                },
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Agregar fotos del producto'),
              ),
            ],
            
            if (_type == PostType.news) ...[
              const SizedBox(height: 16),
              const Text('📰 Detalles de la noticia', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _newsSourceCtrl,
                decoration: const InputDecoration(
                    labelText: 'Fuente',
                    border: OutlineInputBorder(),
                    hintText: 'Ej: MineroNews, El Tiempo'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newsAuthorCtrl,
                decoration: const InputDecoration(
                    labelText: 'Autor',
                    border: OutlineInputBorder(),
                    hintText: 'Nombre del autor o periodista'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Abrir selector de imagen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximamente: agregar imagen de portada')),
                  );
                },
                icon: const Icon(Icons.image),
                label: const Text('Agregar imagen de portada'),
              ),
            ],
            
            if (_type == PostType.poll) ...[
              const SizedBox(height: 16),
              const Text('📊 Opciones de la encuesta', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...List.generate(_pollOptionControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pollOptionControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Opción ${index + 1}',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.radio_button_unchecked),
                          ),
                        ),
                      ),
                      if (_pollOptionControllers.length > 2)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _pollOptionControllers[index].dispose();
                              _pollOptionControllers.removeAt(index);
                            });
                          },
                        ),
                    ],
                  ),
                );
              }),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _pollOptionControllers.add(TextEditingController());
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar opción'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Permitir selección múltiple'),
                subtitle: const Text('Los usuarios pueden elegir más de una opción'),
                value: _pollAllowMultiple,
                onChanged: (val) => setState(() => _pollAllowMultiple = val),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _pollDurationDays,
                decoration: const InputDecoration(
                  labelText: 'Duración de la encuesta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                items: [1, 3, 7, 14, 30].map((days) => DropdownMenuItem(
                  value: days,
                  child: Text('$days ${days == 1 ? 'día' : 'días'}'),
                )).toList(),
                onChanged: (val) => setState(() => _pollDurationDays = val ?? 7),
              ),
            ],
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                label: Text(_submitting ? 'Publicando...' : 'Publicar'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
