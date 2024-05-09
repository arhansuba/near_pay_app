// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:near_pay_app/presantation/ui/util/routes.dart';




//  Replace all usage with the class in sheet_util.dart
class AppSheets {
  //App Ninty Height Sheet
  static Future<T?> showAppHeightNineSheet<T>(
      {required BuildContext context,
      required WidgetBuilder builder,
      required Color color,
      double radius = 30.0,
      required Color barrier,
      int animationDurationMs = 250,
      bool removeUntilHome = false,
      bool closeOnTap = false,
      required Function onDisposed}) {
    assert(radius > 0.0);
    var route = _AppHeightNineModalRoute<T>(
        builder: builder,
        color: color,
        radius: radius,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrier: barrier,
        animationDurationMs: animationDurationMs,
        closeOnTap: closeOnTap,
        onDisposed: onDisposed, settings: null);
    if (removeUntilHome) {
      return Navigator.pushAndRemoveUntil<T>(
          context, route, RouteUtils.withNameLike('/home'));
    }
    return Navigator.push<T>(context, route);
  }

  //App Height Eigth Sheet
  static Future<T?> showAppHeightEightSheet<T>(
      {required BuildContext context,
      required WidgetBuilder builder,
      required Color color,
      double radius = 30.0,
      required Color barrier,
      int animationDurationMs = 225}) {
    assert(radius > 0.0);
    return Navigator.push<T>(
        context,
        _AppHeightEightModalRoute<T>(
            builder: builder,
            color: color,
            radius: radius,
            barrierLabel:
                MaterialLocalizations.of(context).modalBarrierDismissLabel,
            barrier: barrier,
            animationDurationMs: animationDurationMs, settings: null));
  }
}

class _AppHeightNineSheetLayout extends SingleChildLayoutDelegate {
  _AppHeightNineSheetLayout(this.progress);

  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    if (constraints.maxHeight < 667) {
      return BoxConstraints(
          minWidth: constraints.maxWidth,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight * 0.95);
    }
    if ((constraints.maxHeight / constraints.maxWidth > 2.1 &&
            Platform.isAndroid) ||
        constraints.maxHeight > 812) {
      return BoxConstraints(
          minWidth: constraints.maxWidth,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight * 0.8);
    } else {
      return BoxConstraints(
          minWidth: constraints.maxWidth,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight * 0.9);
    }
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_AppHeightNineSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _AppHeightNineModalRoute<T> extends PopupRoute<T> {
  _AppHeightNineModalRoute(
      {required this.builder,
      required this.barrierLabel,
      required this.color,
      required this.radius,
      required RouteSettings settings,
      required this.barrier,
      required this.animationDurationMs,
      required this.closeOnTap,
      required this.onDisposed})
      : super(settings: settings);

  final WidgetBuilder builder;
  final double radius;
  final Color color;
  final Color barrier;
  final int animationDurationMs;
  final bool closeOnTap;
  final Function onDisposed;

  @override
  Color get barrierColor => barrier;

  @override
  bool get barrierDismissible => true;

  @override
  String barrierLabel;

  @override
  void didComplete(T result) {
    onDisposed();
      super.didComplete(result);
  }

  AnimationController _animationController;
  CurvedAnimation appSheetAnimation;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator!.overlay as TickerProvider);
    _animationController.duration = Duration(milliseconds: animationDurationMs);
    this.appSheetAnimation = CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
        reverseCurve: Curves.linear)
      ..addStatusListener((animationStatus) {
        if (animationStatus == AnimationStatus.completed) {
          appSheetAnimation.curve = Curves.linear;
        }
      });
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: GestureDetector(
        onTap: () {
          if (closeOnTap) {
            // Close when tapped anywhere
            Navigator.of(context).pop();
          }
        },
        child: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
          child: AnimatedBuilder(
            animation: appSheetAnimation,
            builder: (context, child) => CustomSingleChildLayout(
              delegate: _AppHeightNineSheetLayout(appSheetAnimation.value),
              child: BottomSheet(
                animationController: _animationController,
                onClosing: () => Navigator.pop(context),
                builder: (context) => Container(
                  decoration: BoxDecoration(
                    color: this.color,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(this.radius),
                      topRight: Radius.circular(this.radius),
                    ),
                  ),
                  child: Builder(builder: this.builder),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration =>
      Duration(milliseconds: animationDurationMs);
}
//App Height Nine Sheet End

class _AppHeightEightSheetLayout extends SingleChildLayoutDelegate {
  _AppHeightEightSheetLayout(this.progress);

  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    if (constraints.maxHeight < 667) {
      return BoxConstraints(
          minWidth: constraints.maxWidth,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight * 0.9);
    }
    if (constraints.maxHeight / constraints.maxWidth > 2.1) {
      return BoxConstraints(
          minWidth: constraints.maxWidth,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight * 0.7);
    } else {
      return BoxConstraints(
          minWidth: constraints.maxWidth,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight * 0.8);
    }
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_AppHeightEightSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _AppHeightEightModalRoute<T> extends PopupRoute<T> {
  _AppHeightEightModalRoute(
      {required this.builder,
      required this.barrierLabel,
      required this.color,
      required this.radius,
      required RouteSettings settings,
      required this.barrier,
      required this.animationDurationMs})
      : super(settings: settings);

  final WidgetBuilder builder;
  final double radius;
  final Color color;
  final Color barrier;
  final int animationDurationMs;

  @override
  Color get barrierColor => barrier;

  @override
  bool get barrierDismissible => true;

  @override
  String barrierLabel;

  AnimationController _animationController;
  CurvedAnimation appSheetAnimation;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator!.overlay as TickerProvider);
    _animationController.duration = Duration(milliseconds: animationDurationMs);
    this.appSheetAnimation = CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
        reverseCurve: Curves.linear)
      ..addStatusListener((animationStatus) {
        if (animationStatus == AnimationStatus.completed) {
          appSheetAnimation.curve = Curves.linear;
        }
      });
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: AnimatedBuilder(
          animation: appSheetAnimation,
          builder: (context, child) => CustomSingleChildLayout(
            delegate: _AppHeightEightSheetLayout(appSheetAnimation.value),
            child: BottomSheet(
              animationController: _animationController,
              onClosing: () => Navigator.pop(context),
              builder: (context) => Container(
                decoration: BoxDecoration(
                  color: this.color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(this.radius),
                    topRight: Radius.circular(this.radius),
                  ),
                ),
                child: Builder(builder: this.builder),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration =>
      Duration(milliseconds: animationDurationMs);
}
//App HeightEight Sheet End