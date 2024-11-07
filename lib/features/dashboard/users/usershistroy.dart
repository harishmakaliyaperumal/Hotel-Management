// import 'package:flutter/material.dart';
// // import 'request_card_widget.dart';
//
// class TabbedRequestPage extends StatefulWidget {
//   @override
//   _TabbedRequestPageState createState() => _TabbedRequestPageState();
// }
//
// class _TabbedRequestPageState extends State<TabbedRequestPage> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool isFinished = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//
//     List<Map<String, dynamic>> availableTasks = [
//       {"userName": "John Doe", "jobStatus": "Pending", "taskName": "Room Cleaning", "roomId": "Room 101", "Description": "Clean the room"},
//     ];
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Task Requests"),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: [
//             Tab(text: "Available Tasks"),
//             Tab(text: "Completed Tasks"),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           ListView.builder(
//             itemCount: availableTasks.length,
//             itemBuilder: (context, index) {
//               return RequestCardWidget(
//                 request: availableTasks[index],
//                 screenWidth: screenWidth,
//                 screenHeight: screenHeight,
//                 isFinished: isFinished,
//                 onStatusUpdate: () {
//                   setState(() {
//                     isFinished = true;
//                   });
//                 },
//               );
//             },
//           ),
//           Center(child: Text("Completed Tasks")),
//         ],
//       ),
//     );
//   }
// }