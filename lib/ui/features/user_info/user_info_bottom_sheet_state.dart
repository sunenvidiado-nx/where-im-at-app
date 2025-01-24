part of 'user_info_bottom_sheet_cubit.dart';

sealed class UserInfoBottomSheetState {
  const UserInfoBottomSheetState();
}

class UserInfoBottomSheetInitial extends UserInfoBottomSheetState {
  const UserInfoBottomSheetInitial();
}

class UserInfoBottomSheetLoading extends UserInfoBottomSheetState {
  const UserInfoBottomSheetLoading();
}

class UserInfoBottomSheetLoaded extends UserInfoBottomSheetState {
  const UserInfoBottomSheetLoaded({
    required this.isCurrentUser,
    required this.username,
    required this.photoUrl,
    required this.address,
  });

  final bool isCurrentUser;
  final String username;
  final String photoUrl;
  final String address;
}

class UserInfoBottomSheetError extends UserInfoBottomSheetState {
  const UserInfoBottomSheetError(this.errorMessage);

  final String errorMessage;
}
