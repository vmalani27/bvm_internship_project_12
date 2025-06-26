import 'package:flutter/material.dart';
import 'video_category_select_page.dart';

// NextPage widget
class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'This is the next page. Add your logic here.',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const VideoCategorySelectPage(),
                  ),
                );
              },
              child: const Text('Go to Video Selection'),
            ),
          ],
        ),
      ),
    );
  }
} 