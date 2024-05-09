// ignore_for_file: library_private_types_in_public_api, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/data/network/model/response/alerts_response_item.dart';
import 'package:near_pay_app/styles.dart';
import 'package:near_pay_app/presantation/ui/widgets/flat_button.dart';


class RemoteMessageCard extends StatefulWidget {
  final AlertResponseItem alert;
  final Function onPressed;
  final bool showDesc;
  final bool showTimestamp;
  final bool hasBg;

  const RemoteMessageCard({super.key, 
    required this.alert,
    required this.onPressed,
    this.showDesc = true,
    this.showTimestamp = true,
    this.hasBg = true,
  });

  @override
  _RemoteMessageCardState createState() => _RemoteMessageCardState();
}

class _RemoteMessageCardState extends State<RemoteMessageCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.hasBg
            ? StateContainer.of(context)!.curTheme.success.withOpacity(0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 2,
          color: StateContainer.of(context)!.curTheme.success,
        ),
      ),
      child: FlatButton(
        padding: const EdgeInsets.all(0),
        highlightColor:
            StateContainer.of(context)!.curTheme.success.withOpacity(0.15),
        splashColor:
            StateContainer.of(context)!.curTheme.success.withOpacity(0.15),
        onPressed: widget.onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.alert.title != null
                  ? Container(
                      margin: EdgeInsetsDirectional.only(
                        bottom: widget.alert.shortDescription != null &&
                                (widget.showDesc || widget.alert.title == null)
                            ? 4
                            : 0,
                      ),
                      child: Text(
                        widget.alert.title,
                        style: AppStyles.remoteMessageCardTitle(context),
                      ),
                    )
                  : const SizedBox(),
              widget.alert.shortDescription != null &&
                      (widget.showDesc || widget.alert.title == null)
                  ? Container(
                      margin: const EdgeInsetsDirectional.only(
                        bottom: 4,
                      ),
                      child: Text(
                        widget.alert.shortDescription,
                        style: AppStyles.remoteMessageCardShortDescription(
                            context),
                      ),
                    )
                  : const SizedBox(),
              widget.alert.timestamp != null && widget.showTimestamp
                  ? Container(
                      margin: const EdgeInsetsDirectional.only(
                        top: 6,
                        bottom: 2,
                      ),
                      padding: const EdgeInsetsDirectional.only(
                          start: 10, end: 10, top: 2, bottom: 2),
                      decoration: BoxDecoration(
                        color: StateContainer.of(context)!.curTheme.text05,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(100),
                        ),
                        border: Border.all(
                          color: StateContainer.of(context)!.curTheme.text10,
                        ),
                      ),
                      child: Text(
                        "${DateTime.fromMillisecondsSinceEpoch(
                                    widget.alert.timestamp)
                                .toUtc()
                                .toString()
                                .substring(0, 16)} UTC",
                        style: AppStyles.remoteMessageCardTimestamp(context),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
