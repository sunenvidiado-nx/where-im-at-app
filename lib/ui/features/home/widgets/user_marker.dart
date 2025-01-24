import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:where_im_at/app/router/router_config.dart';
import 'package:where_im_at/domain/models/user_info.dart';
import 'package:where_im_at/ui/features/home/home_screen_cubit.dart';
import 'package:where_im_at/utils/constants/ui_constants.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';

class UserMarker extends StatefulWidget {
  const UserMarker({
    required this.userId,
    required this.isNavigatingToThisMarker,
    required this.currentUserIsNavigating,
    required this.animation,
    super.key,
  });

  final Animation<double> animation;

  final String userId;
  final bool isNavigatingToThisMarker;
  final bool currentUserIsNavigating;

  @override
  State createState() => _UserMarkerState();
}

class _UserMarkerState extends State<UserMarker> {
  late final _cubit = context.read<HomeScreenCubit>();
  UserInfo? _userInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _userInfo = await _cubit.getUserInfo(widget.userId);
      setState(() {});
    });
  }

  Future<void> _onTap() async {
    final result = await context.push(
      Routes.userInfo(
        widget.userId,
        widget.isNavigatingToThisMarker,
        widget.currentUserIsNavigating,
      ),
    );

    if (result == true) {
      _cubit.stopCurrentNavigation();
    }

    if (result is String) {
      _cubit.startNavigatingToUser(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _userInfo == null
        ? const SizedBox.shrink()
        : ScaleTransition(
            scale: widget.animation,
            child: InkWell(
              onTap: _onTap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.colorScheme.surface,
                      borderRadius:
                          BorderRadius.circular(UiConstants.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: context.colorScheme.shadow.withAlpha(60),
                          blurRadius: 4,
                          offset: const Offset(0, 1.5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              context.colorScheme.primary.withAlpha(20),
                          backgroundImage:
                              CachedNetworkImageProvider(_userInfo!.photoUrl),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _userInfo!.username,
                          style: Theme.of(context).textTheme.labelLarge,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  CustomPaint(
                    size: const Size(14, 7),
                    painter: _TrianglePainter(
                      color: context.colorScheme.surface,
                      shadowColor: context.colorScheme.shadow.withAlpha(60),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({
    required this.color,
    required this.shadowColor,
  });

  final Color color;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, size.height * 1.5);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();

    // Draw shadow
    canvas.drawPath(
      path.shift(const Offset(0, 1.5)),
      shadowPaint,
    );

    // Draw triangle
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) =>
      color != oldDelegate.color || shadowColor != oldDelegate.shadowColor;
}
