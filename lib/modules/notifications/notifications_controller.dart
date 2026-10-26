import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../data/models/notification_model.dart';
import '../../shared/widgets/state_view.dart';

class NotificationsController extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;

  final Rx<ViewState> viewState = ViewState.loading.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxString selectedCategory = 'All'.obs;
  final List<String> categories = ['All', 'Transactions', 'Offers'];

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    viewState.value = ViewState.loading;
    try {
      final res = await _apiClient.get<List<NotificationModel>>(
        ApiEndpoints.notificationsList,
        fromJson: (json) => (json as List<dynamic>)
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      if (res.success && res.data != null) {
        notifications.assignAll(res.data!);
        viewState.value = ViewState.success;
      } else {
        viewState.value = ViewState.error;
      }
    } catch (_) {
      viewState.value = ViewState.error;
    }
  }

  void onCategorySelected(String cat) {
    selectedCategory.value = cat;
  }

  List<NotificationModel> get filteredList {
    if (selectedCategory.value == 'All') return notifications;
    if (selectedCategory.value == 'Transactions') {
      return notifications.where((n) => n.category == 'transaction').toList();
    }
    return notifications.where((n) => n.category == 'offer').toList();
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> markAllAsRead() async {
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    await _apiClient.post(ApiEndpoints.notificationsReadAll);
  }

  void dismissNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
  }
}
