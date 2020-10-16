import 'package:flutter/material.dart';
import 'package:flutter_pensil_app/helper/images.dart';
import 'package:flutter_pensil_app/helper/utility.dart';
import 'package:flutter_pensil_app/model/create_announcement_model.dart';
import 'package:flutter_pensil_app/ui/theme/theme.dart';

class AnnouncementWidget extends StatelessWidget {
  const AnnouncementWidget(
    this.model, {
    Key key,
  }) : super(key: key);
  final AnnouncementModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: AppTheme.decoration(context).copyWith(color: Theme.of(context).primaryColor),
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: Container(
                child: Image.asset(
                  Images.megaphone,
                  fit: BoxFit.contain,
                  width: 30,
                  height:30,
                ),
              ),
            ),
            flex: 1,
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(model.description),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      Utility.toTimeOfDate(model.createdAt),
                      style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
