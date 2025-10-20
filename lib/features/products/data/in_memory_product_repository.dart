import 'package:yominero/shared/models/product.dart';
import '../../products/domain/product_repository.dart';

class InMemoryProductRepository implements ProductRepository {
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Casco de seguridad',
      description: 'Casco resistente para protección en minas',
      price: 50.0,
      authorId: 'user1',
      authorName: 'Carlos Mendoza',
      authorDisplayName: 'Carlos Mendoza',
      authorAccountType: 'individual',
      authorRating: 4.8,
      authorReviewCount: 23,
    ),
    Product(
      id: '2',
      name: 'Linterna LED',
      description: 'Linterna recargable de alta potencia',
      price: 30.0,
      authorId: 'user2',
      authorName: 'Ana García',
      authorDisplayName: 'Equipos Mineros S.A.',
      authorAccountType: 'company',
      authorRating: 4.6,
      authorReviewCount: 45,
    ),
    Product(
      id: '3',
      name: 'Guantes de trabajo',
      description: 'Guantes de cuero para manipulación y carga',
      price: 20.0,
      authorId: 'user3',
      authorName: 'Pedro Silva',
      authorDisplayName: 'Cuadrilla Los Mineros',
      authorAccountType: 'group',
      authorRating: 4.3,
      authorReviewCount: 12,
    ),
    Product(
      id: '4',
      name: 'Botas de seguridad',
      description: 'Botas con puntera de acero',
      price: 75.0,
      authorId: 'user4',
      authorName: 'María López',
      authorDisplayName: 'María López',
      authorAccountType: 'individual',
      authorRating: 4.9,
      authorReviewCount: 67,
    ),
    Product(
      id: '5',
      name: 'Chaleco reflectivo',
      description: 'Chaleco de alta visibilidad',
      price: 25.0,
      authorId: 'user2',
      authorName: 'Ana García',
      authorDisplayName: 'Equipos Mineros S.A.',
      authorAccountType: 'company',
      authorRating: 4.6,
      authorReviewCount: 45,
    ),
    Product(
      id: '6',
      name: 'Detector de gases',
      description: 'Detector portátil multigas',
      price: 350.0,
      authorId: 'user5',
      authorName: 'Javier Restrepo',
      authorDisplayName: 'Seguridad Minera Ltda.',
      authorAccountType: 'company',
      authorRating: 4.7,
      authorReviewCount: 89,
    ),
    Product(
      id: '7',
      name: 'Cuerda de seguridad',
      description: 'Cuerda dinámica 50m',
      price: 120.0,
      authorId: 'user6',
      authorName: 'Roberto Vásquez',
      authorDisplayName: 'Roberto Vásquez',
      authorAccountType: 'individual',
      authorRating: 4.5,
      authorReviewCount: 18,
    ),
    Product(
      id: '8',
      name: 'Martillo neumático',
      description: 'Herramienta de perforación',
      price: 890.0,
      authorId: 'user7',
      authorName: 'Luis Hernández',
      authorDisplayName: 'Herramientas Industriales Corp.',
      authorAccountType: 'company',
      authorRating: 4.8,
      authorReviewCount: 156,
    ),
  ];

  @override
  @override
  Future<List<Product>> getAll() async => List.unmodifiable(_products);

  @override
  Future<Product?> getById(String id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null; // Mejor devolver null cuando no se encuentra
    }
  }
}
