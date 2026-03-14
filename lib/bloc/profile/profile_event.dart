abstract class ProfileEvent {}

class LoadUserProfile extends ProfileEvent {}

class UpdateUserProfile extends ProfileEvent {
  final String name;
  final String phone;
  UpdateUserProfile({required this.name, required this.phone});
}

class ChangePassword extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePassword({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });
}

class LogoutRequested extends ProfileEvent {}

class DeleteAccountRequested extends ProfileEvent {
  final String password;
  final String confirmation;
  DeleteAccountRequested({required this.password, required this.confirmation});
}