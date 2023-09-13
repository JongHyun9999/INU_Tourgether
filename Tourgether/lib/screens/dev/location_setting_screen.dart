import 'dart:io';
import 'package:TourGather/utilities/color_palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:TourGather/providers/gps_provider.dart';
import 'package:provider/provider.dart';

class LocationSettingScreen extends StatefulWidget {
  const LocationSettingScreen({super.key});

  @override
  State<LocationSettingScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<LocationSettingScreen> {
  @override
  Widget build(BuildContext context) {
    var gpsProvider = Provider.of<GPSProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        // TODO Appbar 높이 상대적으로 결정하기.
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          iconTheme: IconThemeData(color: ColorPalette.onPrimaryContainer),
          backgroundColor: ColorPalette.primaryContainer,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 5,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.primaryContainer),
                    onPressed: () {
                      // 2023.07.10, jdk
                      // GPS 데이터를 주기적으로 전달받는 콜백 함수 등록
                      // listen: false로 하지 않으면 메서드가 동작하지 않음.
                      gpsProvider.startGPSCallback();
                    },
                    child: Text(
                      "GPS ON",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 5,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // 2023.07.10, jdk
                      // GPS 데이터를 주기적으로 전달받는 콜백 함수 등록 해제
                      gpsProvider.endGPSCallback();
                    },
                    child: Text(
                      "GPS OFF",
                      style: TextStyle(
                        color: ColorPalette.primaryContainer,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (gpsProvider.isLoadingGPS == false)
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Consumer<GPSProvider>(
                                builder: (context, gpsProvider, child) {
                                  return Text(
                                      "Latitude : ${gpsProvider.latitude}");
                                },
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                "Longitude : ${gpsProvider.longitude}",
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              top: 20,
                            ),
                            child: Consumer<GPSProvider>(
                              builder: (context, gpsProvider, child) {
                                return Text(
                                    "StreamInterval : ${gpsProvider.streamInterval}");
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              top: 20,
                            ),
                            child: Consumer<GPSProvider>(
                              builder: (context, gpsProvider, child) {
                                return Text(
                                    "Accuracy : ${gpsProvider.accuracy}");
                              },
                            ),
                          ),
                        ],
                      )
                    : Platform.isAndroid
                        ? Center(child: CircularProgressIndicator())
                        : Center(child: CupertinoActivityIndicator()),
              ],
            ),
          )
        ],
      ),
    );
  }
}
