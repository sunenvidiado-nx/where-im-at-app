import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:where_im_at/app/router/router_config.dart';
import 'package:where_im_at/domain/models/user_info.dart';
import 'package:where_im_at/ui/features/home/home_screen_cubit.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';
import 'package:where_im_at/utils/extensions/int_extensions.dart';

class UserMarker extends StatefulWidget {
  const UserMarker(this.userId, {super.key});

  final String userId;

  @override
  State createState() => _UserMarkerState();
}

class _UserMarkerState extends State<UserMarker> {
  UserInfo? userInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final info =
          await context.read<HomeScreenCubit>().getUserInfo(widget.userId);
      if (mounted) setState(() => userInfo = info);
    });
  }

  @override
  Widget build(BuildContext context) {
    return userInfo == null
        ? const SizedBox.shrink()
        : Transform.translate(
            offset: const Offset(0, -30),
            child: InkWell(
              onTap: () async {
                await Future.delayed(150.milliseconds);
                // ignore: use_build_context_synchronously
                context.push(Routes.userMarkerInfo(widget.userId));
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: context.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: context.colorScheme.shadow.withAlpha(25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              context.colorScheme.primary.withAlpha(30),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              fadeInDuration: 150.milliseconds,
                              fadeOutDuration: 150.milliseconds,
                              imageUrl: userInfo!.photoUrl,
                              width: 28,
                              height: 28,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Icon(
                                Icons.face_unlock_rounded,
                                size: 20,
                                color:
                                    context.colorScheme.primary.withAlpha(120),
                              ),
                              errorWidget: (context, _, __) => Icon(
                                Icons.face_unlock_rounded,
                                size: 20,
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 145),
                          child: Text(
                            userInfo!.username,
                            style: context.primaryTextTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomPaint(
                    size: const Size(14, 7),
                    painter: _TrianglePainter(
                      color: context.colorScheme.surface,
                      shadowColor: context.colorScheme.shadow.withAlpha(25),
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
      path.shift(const Offset(0, 1)),
      shadowPaint,
    );

    // Draw triangle
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) =>
      color != oldDelegate.color || shadowColor != oldDelegate.shadowColor;
}
