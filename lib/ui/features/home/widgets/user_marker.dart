import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_im_at/domain/models/user_info_and_location.dart';
import 'package:where_im_at/ui/features/home/home_screen_cubit.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';

class UserMarker extends StatefulWidget {
  const UserMarker({required this.userId, super.key});

  final String userId;

  @override
  State createState() => _UserMarkerState();
}

class _UserMarkerState extends State<UserMarker> {
  UserInfoAndLocation? userInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final info = await context
          .read<HomeScreenCubit>()
          .getUserInfoAndLocation(widget.userId);
      if (mounted) setState(() => userInfo = info);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: userInfo == null
          ? const SizedBox.shrink()
          : Transform.translate(
              offset: const Offset(0, -30),
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
                          backgroundColor: context.colorScheme.surface,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: userInfo!.info.photoUrl,
                              width: 28,
                              height: 28,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Icon(
                                Icons.person_outline_rounded,
                                size: 20,
                                color:
                                    context.colorScheme.primary.withAlpha(120),
                              ),
                              errorWidget: (context, _, __) => Icon(
                                Icons.person_outline_rounded,
                                size: 20,
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Text(
                            userInfo!.info.username,
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
    path.moveTo(size.width / 2, size.height);
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
