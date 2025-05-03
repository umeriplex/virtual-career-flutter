import 'package:flutter/material.dart';

class JobView extends StatefulWidget {
  const JobView({super.key});

  @override
  State<JobView> createState() => _JobViewState();
}

class _JobViewState extends State<JobView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Job View',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
