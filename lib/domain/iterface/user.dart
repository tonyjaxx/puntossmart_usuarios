import 'package:puntossmart/infrastructure/models/data/address_new_data.dart';
import 'package:puntossmart/infrastructure/models/data/referral_data.dart';
import 'package:puntossmart/infrastructure/models/request/edit_profile.dart';
import '../../domain/handlers/handlers.dart';
import '../../infrastructure/models/models.dart';

abstract class UserRepositoryFacade {
  Future<ApiResult<ProfileResponse>> getProfileDetails();

  Future<ApiResult<ReferralModel>> getReferralDetails();

  Future<ApiResult<dynamic>> saveLocation({required AddressNewModel? address});

  Future<ApiResult<dynamic>> updateLocation(
      {required AddressNewModel? address, required int? addressId});

  Future<ApiResult<dynamic>> setActiveAddress({required int id});

  Future<ApiResult<dynamic>> deleteAddress({required int id});

  Future<ApiResult<dynamic>> deleteAccount();

  Future<ApiResult<dynamic>> logoutAccount({required String fcm});

  Future<ApiResult<ProfileResponse>> editProfile({required EditProfile? user});

  Future<ApiResult<ProfileResponse>> updateProfileImage({
    required String firstName,
    required String imageUrl,
  });

  Future<ApiResult<ProfileResponse>> updatePassword({
    required String password,
    required String passwordConfirmation,
  });

  Future<ApiResult<WalletHistoriesResponse>> getWalletHistories(int page);

  Future<ApiResult<void>> updateFirebaseToken(String? token);
}
