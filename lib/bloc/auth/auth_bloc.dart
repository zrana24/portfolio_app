import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../services/auth_service.dart';
import '../../services/token_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = AuthService();

  AuthBloc() : super(AuthInitial()) {

    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authService.login(
          email: event.email,
          password: event.password,
        );

        final String token = result['token'];
        await TokenService.saveToken(token);

        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<RegisterSubmitted>((event, emit) async {
      if (event.password != event.confirmPassword) {
        emit(AuthFailure("Şifreler birbiriyle eşleşmiyor!"));
        return;
      }

      emit(AuthLoading());
      try {
        final result = await _authService.register(
          name: event.name,
          email: event.email,
          phone: event.phone,
          password: event.password,
          confirmPassword: event.confirmPassword,
        );

        if (result.containsKey('token')) {
          await TokenService.saveToken(result['token']);
        }

        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}