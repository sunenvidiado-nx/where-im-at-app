part of 'user_marker_info_bottom_sheet_cubit.dart';

sealed class UserMarkerInfoBottomSheetState {
  const UserMarkerInfoBottomSheetState();
}

class UserMarkerInfoBottomSheetInitial extends UserMarkerInfoBottomSheetState {
  const UserMarkerInfoBottomSheetInitial();
}

class UserMarkerInfoBottomSheetLoading extends UserMarkerInfoBottomSheetState {
  const UserMarkerInfoBottomSheetLoading();
}

class UserMarkerInfoBottomSheetLoaded extends UserMarkerInfoBottomSheetState {
  const UserMarkerInfoBottomSheetLoaded({
    required this.isCurrentUser,
    required this.username,
    required this.photoUrl,
    required this.approximateLocation,
    required this.city,
  });

  final bool isCurrentUser;
  final String username;
  final String photoUrl;
  final String approximateLocation;
  final String city;
}

class UserMarkerInfoBottomSheetError extends UserMarkerInfoBottomSheetState {
  const UserMarkerInfoBottomSheetError(this.errorMessage);

  final String errorMessage;
}
