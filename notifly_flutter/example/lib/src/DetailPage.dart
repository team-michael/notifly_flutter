import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailPage extends StatelessWidget {
  final String id;

  const DetailPage({
    required this.id,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Route id: $id')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Route id: $id'),
            ElevatedButton(
              onPressed: () async {
                await GoRouter.of(context).push('/');
              },
              child: const Text('Go to home'),
            ),
          ],
        ),
      ),
    );
  }
}
