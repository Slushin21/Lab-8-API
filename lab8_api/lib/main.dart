import 'package:flutter/material.dart';
import 'tab_a.dart';
import 'package:lab8_api/brewery.dart';


void main() => runApp(const Lab8App());

class Lab8App extends StatelessWidget {
  const Lab8App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 8',
      home: const HomeTabs(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});
  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      TabAPage(),
      BreweryTab() 
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.movie), label: 'Studio Ghibli'),
          NavigationDestination(icon: Icon(Icons.sports_bar), label: 'Brewery Finder'),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}
