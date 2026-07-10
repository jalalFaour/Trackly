part of 'app_router_routes.dart';

enum AppRouterEnum {
  // Splash
  splash(
    name: 'splash',
    path: '/',
  ),

  // Auth
  register(
    name: 'register',
    path: '/register',
  ),
  login(
    name: 'login',
    path: '/login',
  ),

  // Todos
  todos(
    name: 'todos',
    path: '/todos',
  ),
  todoUpsert(
    name: 'todoUpsert',
    path: '/todoUpsert',
  ),

  // Nav
  navRoot(
    name: 'navRoot',
    path: '/nav',
  ),
  nav(
    name: 'nav',
    path: '/nav/:${AppRouterKeys.subPage}',
  ),

  // Products
  products(
    name: 'products',
    path: '/products',
  ),
  productDetails(
    name: 'productDetails',
    path: '/:${AppRouterKeys.id}',
  ),
  productBills(
    name: 'productBills',
    path: '/bills',
  ),

  // Movies
  movies(
    name: 'movies',
    path: '/movies',
  ),
  movieDetails(
    name: 'movieDetails',
    path: '/movies/:${AppRouterKeys.id}',
  ),
  moviePay(
    name: 'moviePay',
    path: '/movies/:${AppRouterKeys.id}/pay',
  ),

  // Donation
  donationAdd(
    name: 'donationAdd',
    path: '/donations/add',
  ),

  donationDetails(
    name: 'donationDetails',
    path: '/donations/:${AppRouterKeys.donationId}',
  ),

  requests(
    name: 'requests',
    path: '/requests',
  );

  final String name;
  final String path;

  const AppRouterEnum({
    required this.name,
    required this.path,
  });
}
