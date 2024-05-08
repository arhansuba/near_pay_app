// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
// ignore: library_prefixes
import 'dart:math' as Math;

import 'package:near_pay_app/app_icons.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/dimens.dart';
import 'package:near_pay_app/localization.dart';
import 'package:near_pay_app/presantation/ui/receive/share_card.dart';
import 'package:near_pay_app/presantation/ui/util/ui_util.dart';
import 'package:near_pay_app/presantation/ui/widgets/buttons.dart';
import 'package:near_pay_app/themes.dart';

import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flare_flutter/flare_actor.dart';

class ReceiveSheet extends StatefulWidget {
  final Widget qrWidget;

  const ReceiveSheet({super.key, required this.qrWidget});

  @override
  _ReceiveSheetStateState createState() => _ReceiveSheetStateState();
}

class _ReceiveSheetStateState extends State<ReceiveSheet> {
  late GlobalKey shareCardKey;
  late ByteData shareImageData;

  // Address copied items
  // Current state references
  late bool _showShareCard;
  late bool _addressCopied;
  // Timer reference so we can cancel repeated events
  late Timer _addressCopiedTimer;

  Future<Uint8List?> _capturePng() async {
    if (shareCardKey.currentContext != null) {
      RenderRepaintBoundary? boundary =
          shareCardKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
      ui.Image? image = await boundary?.toImage(pixelRatio: 5.0);
      ByteData? byteData =
          await image?.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Set initial state of copy button
    _addressCopied = false;
    // Create our SVG-heavy things in the constructor because they are slower operations
    // Share card initialization
    shareCardKey = GlobalKey();
    _showShareCard = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            // A row for the address text and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //Empty SizedBox
                const SizedBox(
                  width: 60,
                  height: 60,
                ),
                //Container for the address text and sheet handle
                Column(
                  children: <Widget>[
                    // Sheet handle
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 5,
                      width: MediaQuery.of(context).size.width * 0.15,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context)?.curTheme.text10,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 15.0),
                      child: UIUtil.threeLineAddressText(
                          context, StateContainer.of(context)!.wallet.address,
                          type: ThreeLineAddressTextType.PRIMARY60, contactName: ''),
                    ),
                  ],
                ),
                //Empty SizedBox
                const SizedBox(
                  width: 60,
                  height: 60,
                ),
              ],
            ),
            // QR which takes all the available space left from the buttons & address text
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                    top: 20, bottom: 28, start: 20, end: 20),
                child: LayoutBuilder(builder: (context, constraints) {
                  double availableWidth = constraints.maxWidth;
                  double availableHeight = constraints.maxHeight;
                  double widthDivideFactor = 1.3;
                  double computedMaxSize = Math.min(
                      availableWidth / widthDivideFactor, availableHeight);
                  return Center(
                    child: Stack(
                      children: <Widget>[
                        _showShareCard
                            ? Container(
                                alignment: const AlignmentDirectional(0.0, 0.0),
                                child: AppShareCard(
                                    shareCardKey,
                                    SvgPicture.asset('assets/QR.svg'),
                                    SvgPicture.asset(
                                        'assets/sharecard_logo.svg')),
                              )
                            : const SizedBox(),
                        // This is for hiding the share card
                        Center(
                          child: Container(
                            width: 260,
                            height: 150,
                            color: StateContainer.of(context)
                                ?.curTheme
                                .backgroundDark,
                          ),
                        ),
                        // Background/border part the QR
                        Center(
                          child: SizedBox(
                            width: computedMaxSize / 1.07,
                            height: computedMaxSize / 1.07,
                            child: SvgPicture.asset('assets/QR.svg'),
                          ),
                        ),
                        // Actual QR part of the QR
                        Center(
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(computedMaxSize / 51),
                            height: computedMaxSize / 1.53,
                            width: computedMaxSize / 1.53,
                            child: widget.qrWidget,
                          ),
                        ),
                        // Outer ring
                        Center(
                          child: Container(
                            width: (StateContainer.of(context)?.curTheme
                                    is IndiumTheme)
                                ? computedMaxSize / 1.05
                                : computedMaxSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: StateContainer.of(context)
                                      !.curTheme
                                      .primary,
                                  width: computedMaxSize / 90),
                            ),
                          ),
                        ),
                        // Logo Background White
                        StateContainer.of(context)!.natriconOn
                            ? Center(
                                child: Container(
                                  width: computedMaxSize / 5.5,
                                  height: computedMaxSize / 5.5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      width: (StateContainer.of(context)
                                              ?.curTheme is IndiumTheme)
                                          ? computedMaxSize / 85
                                          : computedMaxSize / 110,
                                      color: (StateContainer.of(context)
                                              ?.curTheme is IndiumTheme)
                                          ? StateContainer.of(context)
                                              ?.curTheme
                                              .backgroundDark
                                          : StateContainer.of(context)
                                              ?.curTheme
                                              .primary,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: (StateContainer.of(context)!
                                                .curTheme is IndiumTheme)
                                            ? computedMaxSize / 110
                                            : computedMaxSize / 85,
                                        color: (StateContainer.of(context)!
                                                .curTheme is IndiumTheme)
                                            ? StateContainer.of(context)
                                                ?.curTheme
                                                .primary
                                            : StateContainer.of(context)!
                                                .curTheme
                                                .backgroundDark,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Container(
                                  width: computedMaxSize / 5.5,
                                  height: computedMaxSize / 5.5,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                        StateContainer.of(context)!.natriconOn
                            ? const SizedBox()
                            : // Logo Background Primary
                            Center(
                                child: Container(
                                  width: computedMaxSize / 6.5,
                                  height: computedMaxSize / 6.5,
                                  decoration: BoxDecoration(
                                    color: StateContainer.of(context)!
                                        .curTheme
                                        .primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                        // natricon
                        StateContainer.of(context)!.natriconOn
                            ? Center(
                                child: Container(
                                  width: computedMaxSize / 6.5,
                                  height: computedMaxSize / 6.5,
                                  margin: EdgeInsetsDirectional.only(
                                      top: computedMaxSize / 170),
                                  child: SvgPicture.network(
                                    UIUtil.getNatriconURL(
                                        StateContainer.of(context)!
                                            .selectedAccount
                                            .address,
                                        StateContainer.of(context)!
                                            .getNatriconNonce(
                                                StateContainer.of(context)!
                                                    .selectedAccount
                                                    .address)),
                                    key: Key(UIUtil.getNatriconURL(
                                        StateContainer.of(context)
                                            !.selectedAccount
                                            .address,
                                        StateContainer.of(context)!
                                            .getNatriconNonce(
                                                StateContainer.of(context)!
                                                    .selectedAccount
                                                    .address))),
                                    placeholderBuilder:
                                        (BuildContext context) => FlareActor(
                                          "assets/ntr_placeholder_animation.flr",
                                          animation: "main",
                                          fit: BoxFit.contain,
                                          color: StateContainer.of(context)
                                              ?.curTheme
                                              .primary,
                                        ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Container(
                                  height: computedMaxSize / 25,
                                  padding: EdgeInsetsDirectional.only(
                                    end: computedMaxSize / 16,
                                  ),
                                  child: Icon(
                                    AppIcons.natriumhorizontal,
                                    size: computedMaxSize / 25,
                                    color: StateContainer.of(context)
                                        ?.curTheme
                                        .backgroundDark,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            //A column with Copy Address and Share Address buttons
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        // Share Address Button
                        _addressCopied
                            ? AppButtonType.SUCCESS
                            : AppButtonType.PRIMARY,
                        _addressCopied
                            ? AppLocalization.of(context)?.addressCopied
                            : AppLocalization.of(context)?.copyAddress,
                        Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text: StateContainer.of(context)!.wallet.address));
                      setState(() {
                        // Set copied style
                        _addressCopied = true;
                      });
                      _addressCopiedTimer.cancel();
                                          _addressCopiedTimer =
                          Timer(const Duration(milliseconds: 800), () {
                        setState(() {
                          _addressCopied = false;
                        });
                      });
                    }),
                  ],
                ),
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        // Share Address Button
                        AppButtonType.PRIMARY_OUTLINE,
                        AppLocalization.of(context)!.addressShare,
                        Dimens.BUTTON_BOTTOM_DIMENS,
                        disabled: _showShareCard, onPressed: () {
                      String receiveCardFileName =
                          "share_${StateContainer.of(context)?.wallet.address}.png";
                      getApplicationDocumentsDirectory().then((directory) {
                        String filePath =
                            "${directory.path}/$receiveCardFileName";
                        File f = File(filePath);
                        setState(() {
                          _showShareCard = true;
                        });
                        Future.delayed(const Duration(milliseconds: 50), () {
                          if (_showShareCard) {
                            _capturePng().then((byteData) {
                              f.writeAsBytes(byteData as List<int>).then((file) {
                                UIUtil.cancelLockEvent();
                                Share.shareFile(file,
                                    text: StateContainer.of(context)
                                        ?.wallet
                                        .address);
                              });
                                                          setState(() {
                                _showShareCard = false;
                              });
                            });
                          }
                        });
                      });
                    }),
                  ],
                ),
              ],
            ),
          ],
        ));
  }
}


