import 'package:flutter/material.dart';
import 'package:mytourgether/providers/gps_provider.dart';
import 'package:provider/provider.dart';

class LocationSettingScreen extends StatefulWidget {
  const LocationSettingScreen({super.key});

  @override
  State<LocationSettingScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<LocationSettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        // TODO Appbar 높이 상대적으로 결정하기.
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
                    onPressed: () {
                      // 2023.07.10, jdk
                      // GPS 데이터를 주기적으로 전달받는 콜백 함수 등록
                      Provider.of<GPSProvider>(context, listen: false)
                          .startGPSCallback();
                    },
                    child: Text(
                      "GPS ON",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                      Provider.of<GPSProvider>(context, listen: false)
                          .endGPSCallback();
                    },
                    child: Text(
                      "GPS OFF",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                Column(
                  children: [
                    Row(
                      children: [
                        Consumer<GPSProvider>(
                          builder: (context, gpsProvider, child) {
                            return Text("Latitude : ${gpsProvider.latitude}");
                          },
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Longitude : ${Provider.of<GPSProvider>(context).longitude}",
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
                          return Text("Accuracy : ${gpsProvider.accuracy}");
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
