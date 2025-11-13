import 'package:get_it/get_it.dart';
import 'package:yominero/core/groups/supabase_group_repository.dart';
import 'package:yominero/core/groups/group_repository.dart';
import 'package:yominero/features/connections/data/supabase_connection_repository.dart';
import 'package:yominero/features/favorites/data/supabase_favorite_repository.dart';
import 'package:yominero/features/messaging/data/supabase_messaging_repository.dart';
import 'package:yominero/features/metrics/data/supabase_metrics_repository.dart';
import 'package:yominero/features/notifications/data/supabase_notifications_repository.dart';
import 'package:yominero/features/posts/data/supabase_post_repository.dart';
import 'package:yominero/features/posts/domain/post_repository.dart';
import 'package:yominero/features/products/data/supabase_product_repository.dart';
import 'package:yominero/features/products/domain/product_repository.dart';
import 'package:yominero/features/services/data/supabase_service_repository.dart';
import 'package:yominero/features/services/domain/service_repository.dart';

final sl = GetIt.instance;

void setupLocator() {
  if (sl.isRegistered<PostRepository>()) return; // idempotent
  // Usar Supabase para todos los repositorios
  sl.registerLazySingleton<PostRepository>(() => SupabasePostRepository());
  sl.registerLazySingleton<ProductRepository>(
      () => SupabaseProductRepository());
  sl.registerLazySingleton<ServiceRepository>(
      () => SupabaseServiceRepository());
  sl.registerLazySingleton<GroupRepository>(() => SupabaseGroupRepository());
  sl.registerLazySingleton<FavoriteRepository>(
      () => SupabaseFavoriteRepository());
  sl.registerLazySingleton<MetricsRepository>(
      () => MetricsRepository());
  sl.registerLazySingleton<MessagingRepository>(
      () => MessagingRepository());
  sl.registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepository());
  sl.registerLazySingleton<ConnectionRepository>(
      () => SupabaseConnectionRepository());
}
