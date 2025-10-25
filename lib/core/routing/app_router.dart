import 'package:flutter/material.dart';
import '../../home_page.dart';
import '../../login_page.dart';
import '../../main_app.dart';
import '../../profile_page.dart';
import '../../community_feed_page.dart';
import '../../products_page.dart';
import '../../services_page.dart';
import '../../groups_page.dart';
import '../../group_detail_page.dart';
// import '../../profile_page.dart';
import '../../post_detail_page.dart';
import '../../product_detail_page.dart';
import '../../service_detail_page.dart';
import '../../manage_services_page.dart';
import '../../manage_products_page.dart';
import '../../company_employees_page.dart';
import '../../company_projects_page.dart';
import '../../company_metrics_page.dart';
import '../../company_resources_page.dart';
import '../../company_requested_services_page.dart';
import '../../company_requested_products_page.dart';
import '../auth/supabase_auth_service.dart';

/// Centralized route names
class AppRoutes {
  static const home = '/home';
  static const login = '/login';
  static const main = '/main';
  static const community = '/community';
  static const products = '/products';
  static const services = '/services';
  static const groups = '/groups';
  static const groupDetail = '/group';
  static const profile = '/profile';
  static const postDetail = '/post';
  static const productDetail = '/product';
  static const serviceDetail = '/service';
  static const manageServices = '/manage-services';
  static const manageProducts = '/manage-products';
  static const companyEmployees = '/company-employees';
  static const companyProjects = '/company-projects';
  static const companyMetrics = '/company-metrics';
  static const companyResources = '/company-resources';
  static const companyRequestedServices = '/company-requested-services';
  static const companyRequestedProducts = '/company-requested-products';
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => const HomePage());
    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginPage());
    case AppRoutes.main:
      return MaterialPageRoute(builder: (_) => const MainApp());
    case AppRoutes.community:
      return MaterialPageRoute(builder: (_) => const CommunityFeedPage(currentUser: null));
    case AppRoutes.products:
      return MaterialPageRoute(builder: (_) => const ProductsPage());
    case AppRoutes.services:
      return MaterialPageRoute(builder: (_) => const ServicesPage());
    case AppRoutes.groups:
      return MaterialPageRoute(builder: (_) => const GroupsPage());
    case AppRoutes.groupDetail:
      if (settings.arguments == null) {
        return _error('Grupo no proporcionado');
      }
      return MaterialPageRoute(
          builder: (_) =>
              GroupDetailPage(group: settings.arguments as dynamic));
    case AppRoutes.profile:
  final user = SupabaseAuthService.instance.currentUserProfile;
      if (user == null) {
        return MaterialPageRoute(builder: (_) => const HomePage());
      }
      return MaterialPageRoute(
          builder: (_) => ProfilePage(currentUser: user));
    case AppRoutes.postDetail:
      if (settings.arguments == null) {
        return _error('Post no proporcionado');
      }
      return MaterialPageRoute(
          builder: (_) => PostDetailPage(post: settings.arguments as dynamic));
    case AppRoutes.productDetail:
      if (settings.arguments == null) {
        return _error('Producto no proporcionado');
      }
      return MaterialPageRoute(
          builder: (_) =>
              ProductDetailPage(product: settings.arguments as dynamic));
    case AppRoutes.serviceDetail:
      if (settings.arguments == null) {
        return _error('Servicio no proporcionado');
      }
      return MaterialPageRoute(
          builder: (_) =>
              ServiceDetailPage(service: settings.arguments as dynamic));
    case AppRoutes.manageServices:
      return MaterialPageRoute(builder: (_) => const ManageServicesPage());
    case AppRoutes.manageProducts:
      return MaterialPageRoute(builder: (_) => const ManageProductsPage());
    case AppRoutes.companyEmployees:
      final user = SupabaseAuthService.instance.currentUserProfile;
      return MaterialPageRoute(
          builder: (_) => CompanyEmployeesPage(currentUser: user));
    case AppRoutes.companyProjects:
      final user = SupabaseAuthService.instance.currentUserProfile;
      return MaterialPageRoute(
          builder: (_) => CompanyProjectsPage(currentUser: user));
    case AppRoutes.companyMetrics:
      final user = SupabaseAuthService.instance.currentUserProfile;
      return MaterialPageRoute(
          builder: (_) => CompanyMetricsPage(currentUser: user));
    case AppRoutes.companyResources:
      final user = SupabaseAuthService.instance.currentUserProfile;
      return MaterialPageRoute(
          builder: (_) => CompanyResourcesPage(currentUser: user));
    case AppRoutes.companyRequestedServices:
      final user = SupabaseAuthService.instance.currentUserProfile;
      return MaterialPageRoute(
          builder: (_) => CompanyRequestedServicesPage(currentUser: user));
    case AppRoutes.companyRequestedProducts:
      final user = SupabaseAuthService.instance.currentUserProfile;
      return MaterialPageRoute(
          builder: (_) => CompanyRequestedProductsPage(currentUser: user));
    default:
      return null;
  }
}

Route<dynamic> _error(String message) => MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error de navegación')),
        body: Center(child: Text(message)),
      ),
    );
