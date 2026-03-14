import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../services/profile_service.dart';
import '../../services/auth_service.dart';
import '../../services/token_service.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();

  ProfileBloc() : super(ProfileInitial()) {
    on<LoadUserProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final token = await TokenService.getToken();
        if (token == null || token.isEmpty) {
          emit(ProfileUnauthenticated());
          return;
        }
        final result = await _profileService.getProfile(token);
        final user = result['user'] ?? result['data'];
        emit(ProfileLoaded(
          name: user['name'] ?? '',
          email: user['email'] ?? '',
          phone: user['phone'] ?? '',
        ));
      } catch (e) {
        emit(ProfileUnauthenticated());
      }
    });

    on<UpdateUserProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final token = await TokenService.getToken();
        if (token == null) { emit(ProfileUnauthenticated()); return; }
        await _profileService.updateProfile(token: token, name: event.name, phone: event.phone);
        emit(ProfileUpdateSuccess('Profil başarıyla güncellendi.'));
        add(LoadUserProfile());
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });

    on<ChangePassword>((event, emit) async {
      emit(ProfileLoading());
      try {
        final token = await TokenService.getToken();
        if (token == null) { emit(ProfileUnauthenticated()); return; }
        await _profileService.changePassword(
          token: token,
          currentPassword: event.currentPassword,
          newPassword: event.newPassword,
          confirmPassword: event.confirmPassword,
        );
        emit(PasswordChangeSuccess('Şifre başarıyla güncellendi.'));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      try {
        final token = await TokenService.getToken();
        if (token != null) await _authService.logout(token);
      } finally {
        await TokenService.removeToken();
        emit(LogoutSuccess());
      }
    });

    on<DeleteAccountRequested>((event, emit) async {
      emit(ProfileLoading());
      try {
        final token = await TokenService.getToken();
        if (token == null) return;
        final result = await _profileService.deleteAccount(
          token: token,
          password: event.password,
          confirmation: event.confirmation,
        );
        await TokenService.removeToken();
        emit(AccountDeleteSuccess(result['message'] ?? 'Hesabınız silindi.'));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });
  }
}