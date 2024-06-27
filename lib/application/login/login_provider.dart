import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puntossmart/domain/di/dependency_manager.dart';

import 'login_notifier.dart';
import 'login_state.dart';

final loginProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(authRepository, settingsRepository, userRepository),
);
