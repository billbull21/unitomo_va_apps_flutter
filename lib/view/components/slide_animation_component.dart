import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SlideAnimationComponent extends HookWidget {

  final Offset? begin;
  final Offset? end;
  final Widget child;

  const SlideAnimationComponent({
    Key? key,
    this.begin,
    this.end,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(seconds: 1),
    );
    final offsetAnimation = useMemoized(() => Tween<Offset>(
      begin: begin ?? const Offset(200, 0),
      end: end ?? Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    )));
    final opacityAnimation = useMemoized(() => Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    )));
    controller.forward();
    return FadeTransition(
      opacity: opacityAnimation,
      child: SlideTransition(
        position: offsetAnimation,
        child: child,
      ),
    );
  }

}
