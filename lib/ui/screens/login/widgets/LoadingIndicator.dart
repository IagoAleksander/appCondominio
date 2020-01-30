
import 'package:app_condominio/utils/appColors.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
      height: 28,
      width: 28,
      child: Center(
        child: CircularProgressIndicator(
            strokeWidth: 2.6,
            valueColor: AlwaysStoppedAnimation(
                AppColors.circularProgressIndicatorColor)),
      ),
    ));
  }
}
