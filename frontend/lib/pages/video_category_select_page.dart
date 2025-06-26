import 'package:flutter/material.dart';
import 'video_list_page.dart';

// VideoCategorySelectPage: Ask user to select Shaft or Housing
class VideoCategorySelectPage extends StatelessWidget {
  const VideoCategorySelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Item to Measure')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Which item are you measuring?', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoListPage(category: 'housing'),
                  ),
                );
              },
              child: const Text('Housing'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoListPage(category: 'shaft'),
                  ),
                );
              },
              child: const Text('Shaft'),
            ),
          ],
        ),
      ),
    );
  }
} 