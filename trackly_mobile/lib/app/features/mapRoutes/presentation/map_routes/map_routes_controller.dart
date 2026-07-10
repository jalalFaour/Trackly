import 'package:trackly/app/core/network/api_caller_provider.dart';
import 'package:trackly/app/core/network_response/network_response.dart';
import 'package:trackly/app/core/ui/base_controller.dart';
import 'package:trackly/app/core/values/constants/app_urls.dart';
import 'package:trackly/app/features/auth/providers/auth_service_provider.dart';

import '../../domain/entities/map_route.dart';
import 'ui/map_routes_ui_state.dart';

class MapRoutesController extends BaseController<MapRoutesUiState> {
  @override
  MapRoutesUiState onInit() => MapRoutesUiState.defaultObj();

  void afterViewReady() {
    getroutes();
  }

  Future<void> getroutes() async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
    );

    final apiCaller = ref.read(
      apiCallerProvider,
    );

    final authService = ref.read(
      authServiceProvider,
    );

    await apiCaller.get(
      token: await authService.accessToken,
      url: AppUrls.routes,
      onSuccess:
          (
            dynamic data,
          ) async {
            print(data.toString());
            final response = NetworkResponse.fromJson<MapRoute>(
              data,
              MapRoute.fromJson,
            );

            if (!response.isSuccess) {
              state = state.copyWith(
                isLoading: false,
                errorMessage: 'تعذر قراءة بيانات التبرعات',
              );
              return;
            }

            state = state.copyWith(
              isLoading: false,
              mapRoutes: response.dataList ?? <MapRoute>[],
              clearErrorMessage: true,
            );
          },
      onError:
          (
            String? key,
            String errorMessage,
          ) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: errorMessage.isEmpty
                  ? 'حدث خطأ أثناء جلب بيانات التبرعات'
                  : errorMessage,
            );
          },
    );
  }
}
