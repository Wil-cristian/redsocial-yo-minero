import 'package:yominero/shared/models/service.dart';
import '../../services/domain/service_repository.dart';

class InMemoryServiceRepository implements ServiceRepository {
  final List<Service> _services = [
    Service(
      id: 's1',
      name: 'Topografía y mapeo',
      description: 'Servicio de topografía y mapeo para estudios y planificación.',
      rate: 120.0,
      authorId: 'user8',
      authorName: 'Carmen Ruiz',
      authorDisplayName: 'Carmen Ruiz',
      authorAccountType: 'individual',
      authorRating: 4.7,
      authorReviewCount: 34,
      tags: ['topografia', 'mapeo', 'geologia'],
      category: 'Estudios Técnicos',
      location: 'Medellín, Colombia',
    ),
    Service(
      id: 's2',
      name: 'Mantenimiento de maquinaria',
      description: 'Revisión y reparación de equipos pesados de minería.',
      rate: 200.0,
      authorId: 'user9',
      authorName: 'Técnicos Unidos',
      authorDisplayName: 'Cuadrilla Técnicos Unidos',
      authorAccountType: 'group',
      authorRating: 4.8,
      authorReviewCount: 67,
      tags: ['mantenimiento', 'maquinaria', 'reparacion'],
      category: 'Mantenimiento Industrial',
      location: 'Bogotá, Colombia',
    ),
    Service(
      id: 's3',
      name: 'Asesoría legal minera',
      description: 'Consultoría en normas y licencias de minería.',
      rate: 150.0,
      authorId: 'user10',
      authorName: 'Dr. Alejandro Vargas',
      authorDisplayName: 'Consultores Legales Mineros S.A.S.',
      authorAccountType: 'company',
      authorRating: 4.9,
      authorReviewCount: 123,
      tags: ['legal', 'licencias', 'consultoria'],
      category: 'Servicios Legales',
      location: 'Cali, Colombia',
    ),
  ];

  @override
  Future<List<Service>> getAll() async => List.unmodifiable(_services);

  @override
  Service? getById(String id) {
    try {
      return _services.firstWhere((s) => s.id == id);
    } catch (e) {
      return null; // Mejor devolver null cuando no se encuentra
    }
  }
}
