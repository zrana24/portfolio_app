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
        if (token == null) {
          emit(ProfileFailure('Token bulunamadı.'));
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
        emit(ProfileFailure(e.toString()));
      }
    });

    on<UpdateUserProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final token = await TokenService.getToken();
        if (token == null) {
          emit(ProfileFailure('Token bulunamadı.'));
          return;
        }

        await _profileService.updateProfile(
          token: token,
          name: event.name,
          phone: event.phone,
        );

        emit(ProfileUpdateSuccess('Profil başarıyla güncellendi.'));

        add(LoadUserProfile());
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });

    on<ChangePassword>((event, emit) async {
      if (event.newPassword != event.confirmPassword) {
        emit(ProfileFailure('Yeni şifreler eşleşmiyor!'));
        return;
      }

      emit(ProfileLoading());
      try {
        final token = await TokenService.getToken();
        if (token == null) {
          emit(ProfileFailure('Token bulunamadı.'));
          return;
        }

        await _profileService.changePassword(
          token: token,
          currentPassword: event.currentPassword,
          newPassword: event.newPassword,
          confirmPassword: event.confirmPassword,
        );

        emit(PasswordChangeSuccess('Şifre başarıyla değiştirildi.'));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      try {
        final token = await TokenService.getToken();
        if (token != null) {
          await _authService.logout(token);
        }
        await TokenService.removeToken();
        emit(LogoutSuccess());
      }
      catch (e) {
        await TokenService.removeToken();
        emit(LogoutSuccess());
      }
    });
  }
}