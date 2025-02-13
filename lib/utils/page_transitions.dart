import 'package:flutter/material.dart';

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlidePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

class FabSlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Offset startOffset;

  FabSlideRoute({required this.page, required this.startOffset})
      : super(
          opaque: false,
          barrierColor: Colors.black54,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart,
              reverseCurve: Curves.easeInQuart,
            );

            return Stack(
              children: [
                FadeTransition(
                  opacity: curvedAnimation,
                  child: ScaleTransition(
                    alignment: Alignment(
                      (startOffset.dx / MediaQuery.of(context).size.width) * 2 -
                          1,
                      (startOffset.dy / MediaQuery.of(context).size.height) *
                              2 -
                          1,
                    ),
                    scale: Tween<double>(begin: 0, end: 1)
                        .animate(curvedAnimation),
                    child: child,
                  ),
                ),
              ],
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}

class ButtonSlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Offset startOffset;

  ButtonSlideRoute({required this.page, required this.startOffset})
      : super(
          opaque: false,
          barrierColor: Colors.black54,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return Stack(
              children: [
                FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    alignment: Alignment(
                      (startOffset.dx / (startOffset.dx.abs() + 1)) * 2 - 1,
                      (startOffset.dy / (startOffset.dy.abs() + 1)) * 2 - 1,
                    ),
                    scale: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutQuart,
                      ),
                    ),
                    child: child,
                  ),
                ),
              ],
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}
