import 'package:flutter/material.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({Key? key}) : super(key: key);
  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تتبع الشحنة')),
      body: Container(
        color: Colors.blue.withOpacity(0.12),
        child: const Center(child: Text('جاري تتبع الموقع الحركي للشحنة...')),
      ),
    );
  }
}