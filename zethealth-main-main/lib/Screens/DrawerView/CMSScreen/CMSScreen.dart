import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:zet_health/Screens/DrawerView/CMSScreen/Cmsscreencontroller.dart';

import '../../../CommonWidget/CustomAppbar.dart';
import '../../../Helper/AppConstants.dart';
import '../../../Helper/StyleHelper.dart';

class CMSScreen extends StatefulWidget {
  final String cms_type;
  const CMSScreen(this.cms_type, {super.key});

  @override
  State<CMSScreen> createState() => _CMSScreenState();
}

class _CMSScreenState extends State<CMSScreen> {
  CmsScreencontroller cmsScreencontroller = Get.put(CmsScreencontroller());

  @override
  void initState() {
    super.initState();
    cmsScreencontroller.callCMSApi(context, widget.cms_type);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppbar(
          isLeading: true,
          title: _buildTitle(widget.cms_type),
          centerTitle: true,
        ),
        body: Obx(() => Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
              child: SingleChildScrollView(
                  child: HtmlWidget(
                cmsScreencontroller.cmsModel.value?.content ?? '',
                textStyle: mediumBlack_14,
              )),
            )),
      ),
    );
  }

  _buildTitle(String cmsType) {
    switch (cmsType) {
      case AppConstants.CONTACT_US:
        return Text("Contact Us", style: boldBlack_16);
      case AppConstants.ABOUT_US:
        return Text("About Us", style: boldBlack_16);
      case AppConstants.BANK_DETAIL:
        return Text("Bank Details", style: boldBlack_16);
      case AppConstants.TERMS_CONDITION:
        return Text("Terms & Conditions", style: boldBlack_16);
      case AppConstants.PRIVACY_POLICY:
        return Text("Privacy Policy", style: boldBlack_16);
    }
  }
}
