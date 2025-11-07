import 'package:yominero/shared/models/service.dart';
import '../../services/domain/service_repository.dart';

class InMemoryServiceRepository implements ServiceRepository {
  final List<Service> _services = [
    Service(
      id: 's1',
      providerId: 'user8',
      name: 'Topografía y mapeo',
      description: 'Servicio de topografía y mapeo para estudios y planificación.',
      category: 'Estudios Técnicos',
      tags: ['topografia', 'mapeo', 'geologia'],
      pricingFrom: 120.0,
      pricingUnit: 'hora',
      isAvailable: true,
      createdAt: DateTime.now().subtract(Duration(days: 30)),
      authorId: 'user8',
      authorName: 'Carmen Ruiz',
      authorDisplayName: 'Carmen Ruiz',
      authorAccountType: 'individual',
      authorRating: 4.7,
      authorReviewCount: 34,
      location: 'Medellín, Colombia',
    ),
    Service(
      id: 's2',
      providerId: 'user9',
      name: 'Mantenimiento de maquinaria',
      description: 'Revisión y reparación de equipos pesados de minería.',
      category: 'Mantenimiento Industrial',
      tags: ['mantenimiento', 'maquinaria', 'reparacion'],
      pricingFrom: 200.0,
      pricingUnit: 'servicio',
      isAvailable: true,
      createdAt: DateTime.now().subtract(Duration(days: 20)),
      authorId: 'user9',
      authorName: 'Técnicos Unidos',
      authorDisplayName: 'Cuadrilla Técnicos Unidos',
      authorAccountType: 'group',
      authorRating: 4.8,
      authorReviewCount: 67,
      location: 'Bogotá, Colombia',
    ),
    Service(
      id: 's3',
      providerId: 'user10',
      name: 'Asesoría legal minera',
      description: 'Consultoría en normas y licencias de minería.',
      category: 'Servicios Legales',
      tags: ['legal', 'licencias', 'consultoria'],
      pricingFrom: 150.0,
      pricingUnit: 'consulta',
      isAvailable: true,
      createdAt: DateTime.now().subtract(Duration(days: 10)),
      authorId: 'user10',
      authorName: 'Dr. Alejandro Vargas',
      authorDisplayName: 'Consultores Legales Mineros S.A.S.',
      authorAccountType: 'company',
      authorRating: 4.9,
      authorReviewCount: 123,
      location: 'Cali, Colombia',
    ),
  ];

  @override
  Future<List<Service>> getAll() async => List.unmodifiable(_services);

  @override
  Future<Service?> getById(String id) async {
    try {
      return _services.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}
