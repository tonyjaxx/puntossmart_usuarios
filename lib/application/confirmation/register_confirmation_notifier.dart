// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puntossmart/domain/handlers/api_result.dart';
import 'package:puntossmart/domain/iterface/auth.dart';
import 'package:puntossmart/infrastructure/services/app_connectivity.dart';
import 'package:puntossmart/infrastructure/services/app_helpers.dart';
import 'package:puntossmart/infrastructure/services/local_storage.dart';
import 'package:puntossmart/infrastructure/services/tr_keys.dart';
import '../../domain/iterface/user.dart';
import 'register_confirmation_state.dart';

class RegisterConfirmationNotifier
    extends StateNotifier<RegisterConfirmationState> {
  final AuthRepositoryFacade _authRepository;
  final UserRepositoryFacade _userRepositoryFacade;

  RegisterConfirmationNotifier(
    this._authRepository,
    this._userRepositoryFacade,
  ) : super(const RegisterConfirmationState());

  Timer? _timer;
  int _initialTime = 30;

  void setCode(String? code) {
    state = state.copyWith(
        confirmCode: code?.trim() ?? '',
        isCodeError: false,
        isConfirm: code.toString().length == 6);
  }

  //knjt 29-07-24
  Future<void> confirmCodeWithFirebase(
      {required BuildContext context,
      required String verificationId,
      VoidCallback? onSuccess}) async {
    final connected = await AppConnectivity.connectivity();
    if (connected) {
      state = state.copyWith(isLoading: true, isSuccess: false);
      // try {
      //   PhoneAuthCredential credential = PhoneAuthProvider.credential(
      //     verificationId: state.verificationCode.isNotEmpty
      //         ? state.verificationCode
      //         : verificationId,
      //     smsCode: state.confirmCode,
      //   );

      //   await FirebaseAuth.instance.signInWithCredential(credential);
      //   onSuccess?.call();
      //   state = state.copyWith(
      //       isLoading: false, isSuccess: onSuccess == null ? true : false);
      // } catch (e) {
      //   AppHelpers.showCheckTopSnackBar(
      //     context,
      //     AppHelpers.getTranslation((e as FirebaseAuthException).message ?? ""),
      //   );
      //   state = state.copyWith(
      //       isLoading: false, isCodeError: true, isSuccess: false);
      // }
      //mod pq se quedaba en un bucle y no mostraba el error :,v

      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: state.confirmCode,
        );

        // Autenticar al usuario con las credenciales
        try {
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
          print('karen User authenticated: ${userCredential.user}');
        } catch (e) {
          print('karen Failed to sign in: $e');
        }

        onSuccess?.call();
        state = state.copyWith(isLoading: false, isSuccess: true);
      } catch (e) {
        print('karen Error during Firebase sign-in: $e');
        if (e is FirebaseAuthException) {
          AppHelpers.showCheckTopSnackBar(
            context,
            AppHelpers.getTranslation(e.message ?? "An error occurred"),
          );
          print('karen Error during Firebase sign-in 2: $e');
        } else {
          AppHelpers.showCheckTopSnackBar(
            context,
            'An unexpected error occurred. Please try again.',
          );
          print('karen 3Error during Firebase sign-in: $e');
        }
        state = state.copyWith(
            isLoading: false, isCodeError: true, isSuccess: false);
      }
    } else {
      if (context.mounted) {
        AppHelpers.showCheckTopSnackBar(
          context,
          AppHelpers.getTranslation(TrKeys.checkYourNetworkConnection),
        );
      }
    }
  }

  Future<void> confirmCode(BuildContext context) async {
    final connected = await AppConnectivity.connectivity();
    if (connected) {
      state = state.copyWith(isLoading: true, isSuccess: false);
      final response = await _authRepository.verifyEmail(
        verifyCode: state.confirmCode.trim(),
      );
      response.when(
        success: (data) async {
          state = state.copyWith(isLoading: false, isSuccess: true);
          _timer?.cancel();
        },
        failure: (failure, status) {
          state = state.copyWith(
              isLoading: false, isCodeError: true, isSuccess: false);
          AppHelpers.showCheckTopSnackBar(
            context,
            failure,
          );
          debugPrint('==> confirm code failure: $failure');
        },
      );
    } else {
      if (context.mounted) {
        AppHelpers.showCheckTopSnackBar(
          context,
          AppHelpers.getTranslation(TrKeys.checkYourNetworkConnection),
        );
      }
    }
  }

//knjt
  Future<void> confirmCodeResetPassword(
      BuildContext context, String email) async {
    final connected = await AppConnectivity.connectivity();
    if (connected) {
      state = state.copyWith(isLoading: true, isResetPasswordSuccess: false);
      final response = await _authRepository.forgotPasswordConfirm(
          verifyCode: state.confirmCode.trim(), email: email);
      response.when(
        success: (data) async {
          await LocalStorage.setToken(data.token);
          String? fcmToken = await FirebaseMessaging.instance.getToken();
          _userRepositoryFacade.updateFirebaseToken(fcmToken);
          state =
              state.copyWith(isLoading: false, isResetPasswordSuccess: true);
        },
        failure: (failure, status) {
          state = state.copyWith(isLoading: false, isCodeError: true);
          AppHelpers.showCheckTopSnackBar(
            context,
            AppHelpers.getTranslation(status.toString()),
          );
          debugPrint('==> confirm reset code failure: $failure');
        },
      );
    } else {
      if (context.mounted) {
        AppHelpers.showCheckTopSnackBar(
          context,
          AppHelpers.getTranslation(TrKeys.checkYourNetworkConnection),
        );
      }
    }
  }

//knjt 2 agregar el +51
  Future<void> confirmCodeResetPasswordWithPhone(
      BuildContext context, String phone, String verificationId) async {
    final connected = await AppConnectivity.connectivity();
    if (connected) {
      state = state.copyWith(isLoading: true, isResetPasswordSuccess: false);
      try {
        // PhoneAuthCredential credential = PhoneAuthProvider.credential(
        //   verificationId: state.verificationCode.isNotEmpty
        //       ? state.verificationCode
        //       : verificationId,
        //   smsCode: state.confirmCode,
        // );
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: state.confirmCode,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);

        final response = await _authRepository.forgotPasswordConfirmWithPhone(
            phone: '+51$phone');
        response.when(
          success: (data) async {
            await LocalStorage.setToken(data.token);
            String? fcmToken = await FirebaseMessaging.instance.getToken();
            _userRepositoryFacade.updateFirebaseToken(fcmToken);
            state =
                state.copyWith(isLoading: false, isResetPasswordSuccess: true);
          },
          failure: (failure, status) {
            state = state.copyWith(isLoading: false, isCodeError: true);
            AppHelpers.showCheckTopSnackBar(
              context,
              AppHelpers.getTranslation(status.toString()),
            );
            debugPrint('==> confirm reset code failure: $failure');
          },
        );
      } //catch (e) {
      //   AppHelpers.showCheckTopSnackBar(
      //     context,
      //     AppHelpers.getTranslation((e as FirebaseAuthException).message ?? ""),
      //   );
      //   state = state.copyWith(isLoading: false, isCodeError: true);
      // }
      catch (e) {
        if (e is FirebaseAuthException) {
          AppHelpers.showCheckTopSnackBar(
            context,
            AppHelpers.getTranslation(e.message ?? ""),
          );
        } else {
          AppHelpers.showCheckTopSnackBar(
            context,
            AppHelpers.getTranslation("An unexpected error occurred"),
          );
        }
        state = state.copyWith(isLoading: false, isCodeError: true);
      }
    } else {
      if (context.mounted) {
        AppHelpers.showCheckTopSnackBar(
          context,
          AppHelpers.getTranslation(TrKeys.checkYourNetworkConnection),
        );
      }
    }
  }

  Future<void> resendConfirmation(BuildContext context, String email,
      {bool isResetPassword = false}) async {
    debugPrint(
        '==> resendConfirmationresendConfirmationresendConfirmationresendConfirmationresendConfirmation');
    final connected = await AppConnectivity.connectivity();
    if (connected) {
      state = state.copyWith(isResending: true);
      late ApiResult response;
      if (isResetPassword) {
        response =
            await _authRepository.forgotPassword(email: '+51' + email.trim());
      } else {
        response = await _authRepository.sigUp(email: '+51' + email.trim());
      }

      response.when(
        success: (data) async {
          state = state.copyWith(isResending: false);
        },
        failure: (failure, status) {
          state = state.copyWith(isResending: false);
          AppHelpers.showCheckTopSnackBar(
            context,
            AppHelpers.getTranslation(status.toString()),
          );
          debugPrint('==> send otp failure: $failure');
        },
      );
    } else {
      if (context.mounted) {
        AppHelpers.showCheckTopSnackBar(
          context,
          AppHelpers.getTranslation(TrKeys.checkYourNetworkConnection),
        );
      }
    }
  }

  Future<void> sendCodeToNumber(
      BuildContext context, String phoneNumber) async {
    debugPrint(
        '==> sendCodeToNumbersendCodeToNumbersendCodeToNumbersendCodeToNumbersendCodeToNumber');
    final connected = await AppConnectivity.connectivity();
    if (connected) {
      state = state.copyWith(isResending: true);
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+51$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          AppHelpers.showCheckTopSnackBar(
            context,
            AppHelpers.getTranslation(
                AppHelpers.getTranslation(e.message ?? "")),
          );
          state = state.copyWith(isResending: false);
        },
        codeSent: (String verificationId, int? resendToken) {
          state = state.copyWith(
              isResending: false, verificationCode: verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } else {
      if (context.mounted) {
        AppHelpers.showNoConnectionSnackBar(context);
      }
    }
  }

  void disposeTimer() {
    _timer?.cancel();
  }

  void startTimer() {
    _timer?.cancel();
    _initialTime = 30;
    state = state.copyWith(
      confirmCode: '',
      isCodeError: false,
    );
    if (_timer != null) {
      _initialTime = 30;
      _timer?.cancel();
    }
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_initialTime < 1) {
          _timer?.cancel();
          state = state.copyWith(
            isTimeExpired: true,
          );
        } else {
          _initialTime--;
          state = state.copyWith(
            isTimeExpired: false,
            timerText: formatHHMMSS(_initialTime),
          );
        }
      },
    );
  }

  void cancelTimer() {
    _timer?.cancel();
  }

  String formatHHMMSS(int seconds) {
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return "$minutesStr:$secondsStr";
  }
}
