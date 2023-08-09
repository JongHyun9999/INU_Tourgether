import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utilities/color_palette.dart';

PreferredSize getAppBar(BuildContext context, double appBarHeight) {
  return PreferredSize(
    preferredSize: Size.fromHeight(appBarHeight),
    child: AppBar(
      // 2023.08.07, jdk
      // Circular Border AppBar
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.vertical(
      //     bottom: Radius.circular(30),
      //   ),
      // ),
      backgroundColor: ColorPalette.primaryContainer,
      leading: IconButton(
        iconSize: 30,
        onPressed: () {},
        icon: Icon(
          Icons.menu,
          color: ColorPalette.onPrimaryContainer,
        ),
      ),
      actions: [
        IconButton(
          iconSize: 30,
          onPressed: () {
            Navigator.pushNamed(
              context,
              "/locationSetting",
            );
          },
          icon: Icon(
            Icons.location_on,
            color: ColorPalette.primaryContainer,
          ),
        )
      ],
    ),
  );
}

Widget getBottomAppBar(BuildContext context, double bottomNavigationBarHeight) {
  return AnimatedContainer(
    duration: Duration(seconds: 1),
    height: bottomNavigationBarHeight,
    child: BottomAppBar(
      color: ColorPalette.primaryContainer,
      shape: CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        "/userPostList",
                      );
                    },
                    icon: FaIcon(
                      FontAwesomeIcons.listUl,
                      color: ColorPalette.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: FaIcon(
                      FontAwesomeIcons.userGroup,
                      color: ColorPalette.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: FaIcon(
                      FontAwesomeIcons.solidComments,
                      color: ColorPalette.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: FaIcon(
                      FontAwesomeIcons.trophy,
                      color: ColorPalette.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
