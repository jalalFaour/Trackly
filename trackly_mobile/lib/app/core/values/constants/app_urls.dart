abstract class AppUrls {
  // static const baseUrl = 'https://jalalfaour.alwaysdata.net';
  static const baseUrl = 'https://trackly.alwaysdata.net';
  // static const baseUrl = 'http://192.168.1.236:3000';

  static const apiUrl = '$baseUrl/api/';

  ///region Auth

  static const register = 'mobile/auth/signup';
  static const login = 'mobile/auth/login';
  static const refresh = 'mobile/auth/refresh';
  static const profile = 'mobile/profile';

  ///endregion Auth

  ///region Todos

  static const todosUpsert = 'todos/upsert';

  static String todosDelete({required int id}) => 'todos/delete?id=$id';

  static String todosGet({required int id}) => 'todos/get?id=$id';

  static String todosGetAll({
    required int pageSize,
    required int pageNumber,
    required bool withPaging,
    required String? search,
  }) =>
      'todos/getAll?'
      'pageSize=$pageSize'
      '&pageNumber=$pageNumber'
      '&withPaging=$withPaging'
      '${search == null ? '' : '&search=$search'}';

  ///endregion Todos

  ///region Donations

  static const donationsMine = 'donations/mine';
  static const donations = 'donations';
  static String donationDetails({
    required String id,
  }) => 'donations/$id';

  static const routes = 'mobile/routes';
  static const routeStopEta = 'mobile/routes/stop-eta';

  static const walletBalance = 'mobile/wallet/balance';
  static const walletAddBalance = 'mobile/wallet/add-credit';
  static const walletDeduct = 'mobile/wallet/deduct';
  static const walletDeductBalance = 'mobile/wallet/deduct-price';

  static const nearestBusStream = 'mobile/nearest-bus/stream';

  static const requests = 'requests/mine';

  static String requestDonation({
    required String id,
  }) => 'donations/$id/request';

  static String requestMarkDelivered({
    required String id,
  }) => 'requests/$id/delivered';

  static String requestMarkNotDelivered({
    required String id,
  }) => 'requests/$id/not_delivered';

  ///endregion Donations
}
