// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/localization.dart';
import 'package:near_pay_app/presantation/ui/widgets/outline_button.dart';
import 'package:near_pay_app/presantation/utils/user_data_util.dart';
import 'package:near_pay_app/styles.dart';




/// A widget for displaying a mnemonic phrase
class MnemonicDisplay extends StatefulWidget {
  final List<String> wordList;
  final bool obscureSeed;
  final bool showButton;

  const MnemonicDisplay(
      {super.key, required this.wordList,
      this.obscureSeed = false,
      this.showButton = true});

  @override
  _MnemonicDisplayState createState() => _MnemonicDisplayState();
}

class _MnemonicDisplayState extends State<MnemonicDisplay> {
  static final List<String> _obscuredSeed = List.filled(24, '•' * 6);
  late bool _seedCopied;
  late bool _seedObscured;
  late Timer _seedCopiedTimer;

  @override
  void initState() {
    super.initState();
    _seedCopied = false;
    _seedObscured = true;
  }

  List<Widget> _buildMnemonicRows() {
    int nRows = 8;
    int itemsPerRow = 24 ~/ nRows;
    int curWord = 0;
    List<Widget> ret = [];
    for (int i = 0; i < nRows; i++) {
      ret.add(Container(
        width: (MediaQuery.of(context).size.width),
        height: 1,
        color: StateContainer.of(context)!.curTheme.text05,
      ));
      // Build individual items
      List<Widget> items = [];
      for (int j = 0; j < itemsPerRow; j++) {
        items.add(
          SizedBox(
            width: (MediaQuery.of(context).size.width -
                    (smallScreen(context) ? 15 : 30)) /
                itemsPerRow,
            child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(children: [
                TextSpan(
                  text: curWord < 9 ? " " : "",
                  style: AppStyles.textStyleNumbersOfMnemonic(context),
                ),
                TextSpan(
                  text: " ${curWord + 1}) ",
                  style: AppStyles.textStyleNumbersOfMnemonic(context),
                ),
                TextSpan(
                  text: _seedObscured && widget.obscureSeed
                      ? _obscuredSeed[curWord]
                      : widget.wordList[curWord],
                  style: _seedCopied
                      ? AppStyles.textStyleMnemonicSuccess(context)
                      : AppStyles.textStyleMnemonic(context),
                )
              ]),
            ),
          ),
        );
        curWord++;
      }
      ret.add(
        Padding(
            padding: EdgeInsets.symmetric(
                vertical: smallScreen(context) ? 6.0 : 9.0),
            child: Container(
              margin: const EdgeInsetsDirectional.only(start: 5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, children: items),
            )),
      );
      if (curWord == itemsPerRow * nRows) {
        ret.add(Container(
          width: (MediaQuery.of(context).size.width),
          height: 1,
          color: StateContainer.of(context)!.curTheme.text05,
        ));
      }
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
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
              margin: const EdgeInsets.only(top: 15),
              child: Column(
                children: _buildMnemonicRows(),
              ),
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
        ),
      ),
      widget.showButton
          ? Container(
              margin: const EdgeInsetsDirectional.only(top: 5),
              padding: const EdgeInsets.all(0.0),
              child: OutlineButton(
                onPressed: () {
                  UserDataUtil.setSecureClipboardItem(
                      widget.wordList.join(' '));
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
                      : AppLocalization.of(context)?.copy,
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
    ]);
  }
}
