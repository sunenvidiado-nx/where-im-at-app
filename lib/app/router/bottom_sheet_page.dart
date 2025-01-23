import 'package:flutter/material.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';

class BottomSheetPage<T> extends Page<T> {
  const BottomSheetPage({
    required this.child,
    this.showDragHandle = false,
    this.useSafeArea = true,
    super.key,
  });

  final Widget child;
  final bool showDragHandle;
  final bool useSafeArea;

  @override
  Route<T> createRoute(BuildContext context) {
    return ModalBottomSheetRoute<T>(
      settings: this,
      isScrollControlled: true,
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea,
      backgroundColor: context.colorScheme.primary.withAlpha(80),
      builder: (context) {
        final bottomSheetPage =
            ModalRoute.of(context)!.settings as BottomSheetPage;
        return bottomSheetPage.child;
      },
    );
  }
}
