import 'package:flutter/material.dart';
import 'package:where_im_at/ui/features/home/interactive_map/interactive_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: InteractiveMap(),
    );
  }
}
