import 'package:yominero/shared/models/service.dart';

abstract class ServiceRepository {
  Future<List<Service>> getAll();
  Future<Service?> getById(String id);
}
