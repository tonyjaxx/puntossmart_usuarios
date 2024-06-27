import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puntossmart/domain/di/dependency_manager.dart';
import 'register_confirmation_notifier.dart';
import 'register_confirmation_state.dart';

final registerConfirmationProvider = StateNotifierProvider.autoDispose<
    RegisterConfirmationNotifier, RegisterConfirmationState>(
  (ref) => RegisterConfirmationNotifier(authRepository, userRepository),
);
