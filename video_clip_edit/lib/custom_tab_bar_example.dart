import 'package:flutter/material.dart';
import 'custom_tab_bar.dart';

class CustomTabBarExample extends StatefulWidget {
  const CustomTabBarExample({Key? key}) : super(key: key);

  @override
  State<CustomTabBarExample> createState() => _CustomTabBarExampleState();
}

class _CustomTabBarExampleState extends State<CustomTabBarExample> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义标签栏示例'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTabBar(
              tabs: const ['AI成片', 'AI对话'],
              initialSelectedIndex: _selectedTabIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
            const SizedBox(height: 32),
            Text(
              '当前选中: ${_selectedTabIndex == 0 ? 'AI成片' : 'AI对话'}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
