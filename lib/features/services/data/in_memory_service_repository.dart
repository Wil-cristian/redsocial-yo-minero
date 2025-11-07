import 'package:yominero/shared/models/service.dart';
import 'package:yominero/features/services/domain/service_repository.dart';

class InMemoryServiceRepository implements ServiceRepository {
  final List<Service> _services = [
    Service(
      id: 's1',
      providerId: 'user8',
      name: 'Topografía y mapeo de terrenos',
      description: 'Servicios profesionales de topografía para proyectos mineros. Incluye levantamiento, medición y mapeo digital 3D.',
      category: 'Topografía',
      tags: ['topografia', 'mapeo', '3D', 'profesional'],
      pricingFrom: 500.0,
      pricingTo: 2000.0,
      pricingUnit: 'proyecto',
      isAvailable: true,
      createdAt: DateTime.now().subtract(Duration(days: 15)),
      providerName: 'Ing. Carlos Mendoza',
      providerAccountType: 'individual',
    ),
    Service(
      id: 's2',
      providerId: 'user9',
      name: 'Mantenimiento de Maquinaria Pesada',
      description: 'Servicio especializado de mantenimiento preventivo y correctivo para equipos mineros pesados.',
      category: 'Mantenimiento',
      tags: ['mantenimiento', 'maquinaria', 'reparacion'],
      pricingFrom: 800.0,
      pricingTo: 3000.0,
      pricingUnit: 'servicio',
      isAvailable: true,
      createdAt: DateTime.now().subtract(Duration(days: 20)),
      providerName: 'Técnicos Unidos',
      providerAccountType: 'company',
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
      providerName: 'Dr. Alejandro Vargas',
      providerAccountType: 'individual',
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
