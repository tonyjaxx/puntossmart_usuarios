import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:puntossmart/domain/di/injection.dart';
import 'package:puntossmart/domain/handlers/http_service.dart';
import 'package:puntossmart/domain/iterface/settings.dart';
import 'package:puntossmart/infrastructure/models/data/generate_image_model.dart';
import 'package:puntossmart/infrastructure/models/data/help_data.dart';
import 'package:puntossmart/infrastructure/models/data/notification_list_data.dart';
import 'package:puntossmart/infrastructure/models/models.dart';
import 'package:puntossmart/infrastructure/services/local_storage.dart';
import '../../../domain/handlers/handlers.dart';

class SettingsRepository implements SettingsRepositoryFacade {
  @override
  Future<ApiResult<GlobalSettingsResponse>> getGlobalSettings() async {
    try {
      final client = inject<HttpService>().client(requireAuth: false);
      final response = await client.get('/api/v1/rest/settings');
      return ApiResult.success(
        data: GlobalSettingsResponse.fromJson(response.data),
      );
    } catch (e) {
      debugPrint('==> get settings failure: $e');
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }

  @override
  Future<ApiResult<MobileTranslationsResponse>> getMobileTranslations() async {
    final data = {'lang': LocalStorage.getLanguage()?.locale ?? 'en'};
    try {
      final client = inject<HttpService>().client(requireAuth: false);
      final response = await client.get(
        '/api/v1/rest/translations/paginate',
        queryParameters: data,
      );
      return ApiResult.success(
        data: MobileTranslationsResponse.fromJson(response.data),
      );
    } catch (e) {
      debugPrint('==> get translations failure: $e');
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }

  @override
  Future<ApiResult<LanguagesResponse>> getLanguages() async {
    try {
      final client = inject<HttpService>().client(requireAuth: false);
      final response = await client.get('/api/v1/rest/languages/active');
      if (LocalStorage.getLanguage() == null ||
          !(LanguagesResponse.fromJson(response.data)
                  .data
                  ?.map((e) => e.id)
                  .contains(LocalStorage.getLanguage()?.id) ??
              true)) {
        LanguagesResponse.fromJson(response.data).data?.forEach((element) {
          if (element.isDefault ?? false) {
            LocalStorage.setLanguageData(element);
          }
        });
      }
      return ApiResult.success(
        data: LanguagesResponse.fromJson(response.data),
      );
    } catch (e) {
      debugPrint('==> get languages failure: $e');
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }

  @override
  Future<ApiResult<HelpModel>> getFaq() async {
    try {
      final client = inject<HttpService>().client(requireAuth: true);
      final response = await client.get('/api/v1/rest/faqs/paginate');
      return ApiResult.success(
        data: HelpModel.fromJson(response.data),
      );
    } catch (e) {
      debugPrint('==> get faq failure: $e');
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }

  @override
  Future<ApiResult<NotificationsListModel>> getNotificationList() async {
    try {
      final client = inject<HttpService>().client(requireAuth: true);
      final response = await client.get('/api/v1/dashboard/user/notifications');
      return ApiResult.success(
        data: notificationsListModelFromJson(response.data) ??
            NotificationsListModel(),
      );
    } catch (e) {
      debugPrint('==> get languages failure: $e');
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }

  @override
  Future<ApiResult> updateNotification(
      List<NotificationData>? notifications) async {
    try {
      final client = inject<HttpService>().client(requireAuth: true);
      final data = {
        for (int i = 0; i < notifications!.length; i++)
          "notifications[$i][notification_id]": notifications[i].id,
        for (int i = 0; i < notifications.length; i++)
          "notifications[$i][active]": notifications[i].active! ? 1 : 0,
      };
      await client.post('/api/v1/dashboard/user/update/notifications',
          queryParameters: data);
      return const ApiResult.success(
        data: null,
      );
    } catch (e) {
      debugPrint('==> get languages failure: $e');
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }

  @override
  Future<ApiResult<GenerateImageModel>> getGenerateImage(String name) async {
    try {
      final client =
          inject<HttpService>().client(chatGpt: true, requireAuth: true);
      final response = await client.post('/v1/images/generations',
          data: {"prompt": name, "n": 10, "size": "512x512"});
      return ApiResult.success(
        data: GenerateImageModel.fromJson(response.data),
      );
    } catch (e) {
      debugPrint('==> get GenerateImage failure: $e');
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }
}
