import 'package:flutter/material.dart';

class NarBar extends StatefulWidget {
  const NarBar({super.key});

  @override
  State<NarBar> createState() => _NarBarState();
}

class _NarBarState extends State<NarBar> {
  bool onlineSwitch = false;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            // 학과, 학번, 이름
            accountName: const Text(
              "임베디드시스템공학과",
              style: TextStyle(fontSize: 15),
            ),
            accountEmail: const Text(
              "202201676 장경은",
              style: TextStyle(fontSize: 15),
            ),
            // 프로필 사진
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset(
                  'image/userInfo_profile.jpg',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // 배경 이미지
            decoration: const BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                  image: AssetImage(
                    'image/userInfo_background.jpg',
                  ),
                  fit: BoxFit.cover,
                )),
          ),
          Row(
            children: [
              const SizedBox(
                width: 13,
              ),
              const Icon(
                Icons.online_prediction,
                size: 30,
              ),
              const SizedBox(
                width: 10,
              ),
              const Text(
                "활동 상태",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                width: 10,
              ),
              Switch(
                value: onlineSwitch,
                onChanged: (value) {
                  setState(() {
                    onlineSwitch = value;
                  });
                },
                activeColor: Colors.green,
              ),
            ],
          ),
          const Divider(),
          // 메뉴
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('즐겨찾기'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('친구'),
            onTap: () {},
            // 친구 요청 알림
            trailing: ClipOval(
                child: Container(
                    color: Colors.red,
                    width: 20,
                    height: 20,
                    child: const Center(
                      child: Text(
                        '8',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ))),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('설정'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('라이선스'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('개발자들'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
