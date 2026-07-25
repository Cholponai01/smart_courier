abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  static const customerHome = '/customer/home';
  static const customerOrders = '/customer/orders';
  static const customerNewOrder = '/customer/new-order';
  static const customerProfile = '/customer/profile';

  static const courierAvailable = '/courier/available';
  static const courierActive = '/courier/active';
  static const courierEarnings = '/courier/earnings';
  static const courierProfile = '/courier/profile';

  static const adminDashboard = '/admin/dashboard';
  static const adminOrders = '/admin/orders';
  static const adminCouriers = '/admin/couriers';
  static const adminProfile = '/admin/profile';

  static const passwordResetQueryParam = 'passwordReset';
  static const highlightOrderQueryParam = 'highlight';

  static String loginAfterPasswordReset() =>
      '$login?$passwordResetQueryParam=1';

  static String customerOrdersWithHighlight(String orderId) =>
      '$customerOrders?$highlightOrderQueryParam=$orderId';
}
