import 'package:get_it/get_it.dart';
import 'package:yominero/core/groups/supabase_group_repository.dart';
import 'package:yominero/core/groups/group_repository.dart';
import 'package:yominero/features/posts/data/supabase_post_repository.dart';
import 'package:yominero/features/posts/domain/post_repository.dart';
import 'package:yominero/features/products/data/in_memory_product_repository.dart';
import 'package:yominero/features/products/domain/product_repository.dart';
import 'package:yominero/features/services/data/supabase_service_repository.dart';
import 'package:yominero/features/services/domain/service_repository.dart';

final sl = GetIt.instance;

void setupLocator() {
  if (sl.isRegistered<PostRepository>()) return; // idempotent
  // Usar Supabase para posts, servicios y grupos, in-memory para productos
  sl.registerLazySingleton<PostRepository>(() => SupabasePostRepository());
  sl.registerLazySingleton<ProductRepository>(
      () => InMemoryProductRepository());
  sl.registerLazySingleton<ServiceRepository>(
      () => SupabaseServiceRepository());
  sl.registerLazySingleton<GroupRepository>(() => SupabaseGroupRepository());
}
