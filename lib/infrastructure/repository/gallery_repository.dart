import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:puntossmart/domain/di/injection.dart';
import 'package:puntossmart/domain/handlers/http_service.dart';
import 'package:puntossmart/domain/iterface/gallery.dart';
import 'package:puntossmart/infrastructure/models/models.dart';
import 'package:puntossmart/infrastructure/services/app_constants.dart';
import '../../../domain/handlers/handlers.dart';

class GalleryRepository implements GalleryRepositoryFacade {
  @override
  Future<ApiResult<GalleryUploadResponse>> uploadImage(
    String file,
    UploadType uploadType,
  ) async {
    String type = '';
    switch (uploadType) {
      case UploadType.brands:
        type = 'brands';
        break;
      case UploadType.extras:
        type = 'extras';
        break;
      case UploadType.categories:
        type = 'categories';
        break;
      case UploadType.shopsLogo:
        type = 'shops/logo';
        break;
      case UploadType.shopsBack:
        type = 'shops/background';
        break;
      case UploadType.products:
        type = 'products';
        break;
      case UploadType.reviews:
        type = 'reviews';
        break;
      case UploadType.users:
        type = 'users';
        break;
      default:
        type = 'extras';
        break;
    }
    final data = FormData.fromMap(
      {
        'image': await MultipartFile.fromFile(file),
        'type': type,
      },
    );
    try {
      final client = inject<HttpService>().client(requireAuth: true);
      final response = await client.post(
        '/api/v1/dashboard/galleries',
        data: data,
      );
      return ApiResult.success(
        data: GalleryUploadResponse.fromJson(response.data),
      );
    } catch (e) {
      debugPrint('==> upload image failure: $e');
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data.toString().substring(
                      (e.response?.data.toString().indexOf("<title>") ?? 0) + 7,
                      e.response?.data.toString().indexOf("</title") ?? 0))
                  .toString()
              : e.toString(),
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }
}
