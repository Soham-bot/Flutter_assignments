import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IDCard(),
    );
  }
}

class IDCard extends StatelessWidget {
  const IDCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Card'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          margin: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 50.0,
                backgroundImage: AssetImage('assets/profile.jpg'),
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Soham Ahirrao',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5.0),
              const Text(
                'Student',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20.0),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Icon(Icons.cake, color: Colors.blue),
                      SizedBox(height: 5.0),
                      Text('20 Years'),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.badge, color: Colors.green),
                      SizedBox(height: 5.0),
                      Text('150096724095'),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.favorite, color: Colors.red),
                      SizedBox(height: 5.0),
                      Text('AB+'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email, color: Colors.blue),
                    SizedBox(width: 8.0),
                    Text('2024.sohama@iau.ac.in'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
