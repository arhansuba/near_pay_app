// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/localization.dart';
import 'package:near_pay_app/styles.dart';
import 'package:near_pay_app/presantation/ui/util/ui_util.dart';
import 'package:near_pay_app/presantation/ui/widgets/outline_button.dart';
import 'package:near_pay_app/presantation/utils/user_data_util.dart';


/// A widget for displaying a mnemonic phrase
class PlainSeedDisplay extends StatefulWidget {
  final String seed;
  final bool obscureSeed;
  final bool showButton;

  const PlainSeedDisplay(
      {super.key, required this.seed, this.obscureSeed = false, this.showButton = true});

  @override
  _PlainSeedDisplayState createState() => _PlainSeedDisplayState();
}

class _PlainSeedDisplayState extends State<PlainSeedDisplay> {
  static final String _obscuredSeed = '•' * 64;

  late bool _seedCopied;
  late bool _seedObscured;
  late Timer _seedCopiedTimer;

  @override
  void initState() {
    super.initState();
    _seedCopied = false;
    _seedObscured = true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // The paragraph
        Container(
          margin: EdgeInsets.only(
              left: smallScreen(context) ? 30 : 40,
              right: smallScreen(context) ? 30 : 40,
              top: 15.0),
          alignment: Alignment.centerLeft,
          child: AutoSizeText(
            AppLocalization.of(context)!.seedDescription,
            style: AppStyles.textStyleParagraph(context),
            maxLines: 5,
            stepGranularity: 0.5,
          ),
        ),
        // Container for the seed
        GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (widget.obscureSeed) {
                setState(() {
                  _seedObscured = !_seedObscured;
                });
              }
            },
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
                  margin: const EdgeInsets.only(top: 25),
                  decoration: BoxDecoration(
                    color:
                        StateContainer.of(context)!.curTheme.backgroundDarkest,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: UIUtil.threeLineSeedText(
                      context,
                      widget.obscureSeed && _seedObscured
                          ? _obscuredSeed
                          : widget.seed,
                      textStyle: _seedCopied
                          ? AppStyles.textStyleSeedGreen(context)
                          : AppStyles.textStyleSeed(context)),
                ),
                // Tap to reveal or hide
                widget.obscureSeed
                    ? Container(
                        margin: const EdgeInsetsDirectional.only(top: 8),
                        child: _seedObscured
                            ? AutoSizeText(
                                AppLocalization.of(context)!.tapToReveal,
                                style: AppStyles.textStyleParagraphThinPrimary(
                                    context),
                              )
                            : Text(
                                AppLocalization.of(context)!.tapToHide,
                                style: AppStyles.textStyleParagraphThinPrimary(
                                    context),
                              ),
                      )
                    : const SizedBox(),
              ],
            )),
        // Container for the copy button
        widget.showButton
            ? Container(
                margin: const EdgeInsetsDirectional.only(top: 5),
                padding: const EdgeInsets.all(0.0),
                child: OutlineButton(
                  onPressed: () {
                    UserDataUtil.setSecureClipboardItem(widget.seed);
                    setState(() {
                      _seedCopied = true;
                    });
                    _seedCopiedTimer.cancel();
                                      _seedCopiedTimer =
                        Timer(const Duration(milliseconds: 1500), () {
                      setState(() {
                        _seedCopied = false;
                      });
                    });
                  },
                  splashColor: _seedCopied
                      ? Colors.transparent
                      : StateContainer.of(context)!.curTheme.primary30,
                  highlightColor: _seedCopied
                      ? Colors.transparent
                      : StateContainer.of(context)!.curTheme.primary15,
                  highlightedBorderColor: _seedCopied
                      ? StateContainer.of(context)!.curTheme.success
                      : StateContainer.of(context)!.curTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0)),
                  borderSide: BorderSide(
                      color: _seedCopied
                          ? StateContainer.of(context)!.curTheme.success
                          : StateContainer.of(context)!.curTheme.primary,
                      width: 1.0),
                  child: AutoSizeText(
                    _seedCopied
                        ? AppLocalization.of(context)!.copied
                        : AppLocalization.of(context)!.copy,
                    textAlign: TextAlign.center,
                    style: _seedCopied
                        ? AppStyles.textStyleButtonSuccessSmallOutline(context)
                        : AppStyles.textStyleButtonPrimarySmallOutline(context),
                    maxLines: 1,
                    stepGranularity: 0.5,
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
