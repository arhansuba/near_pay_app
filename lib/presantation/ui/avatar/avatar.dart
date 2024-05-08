
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/dimens.dart';
import 'package:near_pay_app/presantation/ui/util/ui_util.dart';
import 'package:near_pay_app/presantation/ui/widgets/buttons.dart';
import 'package:near_pay_app/presantation/utils/sharedprefsutil.dart';
import 'package:near_pay_app/service_locator.dart';




class AvatarPage extends StatefulWidget {
  const AvatarPage({super.key});

  @override
  _AvatarPageState createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _controller;
  late Animation<Color> bgColorAnimation;
  late Animation<Offset> offsetTween;
  late bool hasEnoughFunds;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    hasEnoughFunds = StateContainer.of(context)!.wallet.accountBalance >
        BigInt.parse("1234570000000000000000000000");
    bgColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: StateContainer.of(context)?.curTheme.barrier,
    ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn));
    offsetTween = Tween<Offset>(begin: const Offset(0, 200), end: const Offset(0, 0))
        .animate(CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn));
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: bgColorAnimation.value,
          key: _scaffoldKey,
          body: LayoutBuilder(
            builder: (context, constraints) => SafeArea(
              bottom: false,
              minimum: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.10),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // Gesture Detector
                        GestureDetector(onTapDown: (details) {
                          _controller.reverse();
                          Navigator.pop(context);
                        }),
                        // Avatar
                        Container(
                          margin: EdgeInsetsDirectional.only(
                              bottom: MediaQuery.of(context).size.height * 0.2),
                          child: ClipOval(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.width * 0.8,
                              child: ClipOval(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Hero(
                                      tag: "avatar",
                                      child: SvgPicture.network(
                                        UIUtil.getNatriconURL(
                                            StateContainer.of(context)!
                                                .selectedAccount
                                                .address,
                                            StateContainer.of(context)!
                                                .getNatriconNonce(
                                                    StateContainer.of(context)
                                                        !.selectedAccount
                                                        .address)),
                                        key: Key(UIUtil.getNatriconURL(
                                            StateContainer.of(context)!
                                                .selectedAccount
                                                .address,
                                            StateContainer.of(context)!
                                                .getNatriconNonce(
                                                    StateContainer.of(context)
                                                        !.selectedAccount
                                                        .address))),
                                        placeholderBuilder:
                                            (BuildContext context) => FlareActor(
                                              "assets/ntr_placeholder_animation.flr",
                                              animation: "main",
                                              fit: BoxFit.contain,
                                              color: StateContainer.of(context)!
                                                  .curTheme
                                                  .primary,
                                            ),
                                      ),
                                    ),
                                    /* // Button for the interaction
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(2000.0)),
                                      highlightColor:
                                          StateContainer.of(context).curTheme.text15,
                                      splashColor:
                                          StateContainer.of(context).curTheme.text15,
                                      padding: EdgeInsets.all(0.0),
                                      child: Container(
                                        color: Colors.transparent,
                                      ),
                                    ) */
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: offsetTween.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: StateContainer.of(context)!
                                            .curTheme
                                            .backgroundDark,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(30),
                                            topRight: Radius.circular(30))),
                                    child: SafeArea(
                                      minimum: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.035,
                                          top: hasEnoughFunds ? 24 : 16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          // If balance if below 0.0123457 Nano, don't display this button
                                          hasEnoughFunds
                                              ? Row(
                                                  children: <Widget>[
                                                    AppButton.buildAppButton(
                                                        context,
                                                        AppButtonType.PRIMARY,
                                                        "Change My Natricon",
                                                        Dimens
                                                            .BUTTON_TOP_DIMENS,
                                                        onPressed: () {
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                              '/avatar_change_page');
                                                    }),
                                                  ],
                                                )
                                              : const SizedBox(),
                                          Row(
                                            children: <Widget>[
                                              AppButton.buildAppButton(
                                                  context,
                                                  // Share Address Button
                                                  AppButtonType.PRIMARY_OUTLINE,
                                                  "Turn Off Natricon",
                                                  Dimens.BUTTON_BOTTOM_DIMENS,
                                                  onPressed: () {
                                                _controller.reverse();
                                                sl
                                                    .get<SharedPrefsUtil>()
                                                    .setUseNatricon(false)
                                                    .then((result) {
                                                  setState(() {
                                                    StateContainer.of(context)!
                                                        .setNatriconOn(false);
                                                  });
                                                });
                                                Navigator.pop(context);
                                              }),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
