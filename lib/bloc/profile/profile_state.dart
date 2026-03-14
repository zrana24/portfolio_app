abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

// Kullanıcı giriş yapmamışsa bu state kullanılacak
class ProfileUnauthenticated extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String name;
  final String email;
  final String phone;

  const ProfileLoaded({
    required this.name,
    required this.email,
    required this.phone,
  });
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  ProfileUpdateSuccess(this.message);
}

class PasswordChangeSuccess extends ProfileState {
  final String message;
  PasswordChangeSuccess(this.message);
}

class ProfileFailure extends ProfileState {
  final String message;
  ProfileFailure(this.message);
}

class LogoutSuccess extends ProfileState {}

class AccountDeleteSuccess extends ProfileState {
  final String message;
  AccountDeleteSuccess(this.message);
}