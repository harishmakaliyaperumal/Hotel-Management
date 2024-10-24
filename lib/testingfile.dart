// import 'package:flutter/material.dart';
// // import 'package:audioplayers/audioplayers.dart';
//
// class NotificationPage extends StatefulWidget {
//   @override
//   _NotificationPageState createState() => _NotificationPageState();
// }
//
// class _NotificationPageState extends State<NotificationPage> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//
//   @override
//   void initState() {
//     super.initState();
//     // Simulate a new request after 5 seconds (for example purposes)
//     Future.delayed(Duration(seconds: 5), () {
//       _playNotificationSound();
//     });
//   }
//
//   Future<void> _playNotificationSound() async {
//     await _audioPlayer.play(AssetSource('assets/audio/notification.mp3'));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Notification Example')),
//       body: Center(
//         child: Text('Waiting for new request...'),
//       ),
//     );
//   }
// }
