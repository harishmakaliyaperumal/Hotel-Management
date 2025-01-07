// class JobResponse {
//   bool requestJobIsActive;
//   int roomDataId;
//   String nextJobStatus;
//   String jobStatus;
//   int flag;
//   String description;
//   DateTime requestJobUpdatedOn;
//   String taskNorweign;
//   int flagsData;
//   String? rating;
//   String descriptionNorweign;
//   String userName;
//   String taskArabian;
//   int userId;
//   int roomId;
//   String roomName;
//   int requestJobHistoryId;
//   String name;
//   DateTime requestJobCreatedOn;
//   String taskName;
//   String? comment;
//   String decripyionArabian;
//   int taskId;
//
//   JobResponse({
//     required this.requestJobIsActive,
//     required this.roomDataId,
//     required this.nextJobStatus,
//     required this.jobStatus,
//     required this.flag,
//     required this.description,
//     required this.requestJobUpdatedOn,
//     required this.taskNorweign,
//     required this.flagsData,
//     this.rating,
//     required this.descriptionNorweign,
//     required this.userName,
//     required this.taskArabian,
//     required this.userId,
//     required this.roomId,
//     required this.roomName,
//     required this.requestJobHistoryId,
//     required this.name,
//     required this.requestJobCreatedOn,
//     required this.taskName,
//     this.comment,
//     required this.decripyionArabian,
//     required this.taskId,
//   });
//
//   // Method to parse JSON and create a JobResponse object
//   factory JobResponse.fromJson(Map<String, dynamic> json) {
//     return JobResponse(
//       requestJobIsActive: json['requestJobIsActive'],
//       roomDataId: json['roomDataId'],
//       nextJobStatus: json['nextJobStatus'],
//       jobStatus: json['jobStatus'],
//       flag: json['flag'],
//       description: json['Description'],
//       requestJobUpdatedOn: DateTime.parse(json['requestJobUpdatedOn']),
//       taskNorweign: json['taskNorweign'],
//       flagsData: json['flagsData'],
//       rating: json['rating'],
//       descriptionNorweign: json['DescriptionNorweign'],
//       userName: json['userName'],
//       taskArabian: json['taskArabian'],
//       userId: json['userId'],
//       roomId: json['roomId'],
//       roomName: json['roomName'],
//       requestJobHistoryId: json['requestJobHistoryId'],
//       name: json['name'],
//       requestJobCreatedOn: DateTime.parse(json['requestJobCreatedOn']),
//       taskName: json['taskName'],
//       comment: json['comment'],
//       decripyionArabian: json['decripyionArabian'],
//       taskId: json['taskId'],
//     );
//   }
//
//   // Method to convert the JobResponse object back to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'requestJobIsActive': requestJobIsActive,
//       'roomDataId': roomDataId,
//       'nextJobStatus': nextJobStatus,
//       'jobStatus': jobStatus,
//       'flag': flag,
//       'Description': description,
//       'requestJobUpdatedOn': requestJobUpdatedOn.toIso8601String(),
//       'taskNorweign': taskNorweign,
//       'flagsData': flagsData,
//       'rating': rating,
//       'DescriptionNorweign': descriptionNorweign,
//       'userName': userName,
//       'taskArabian': taskArabian,
//       'userId': userId,
//       'roomId': roomId,
//       'roomName': roomName,
//       'requestJobHistoryId': requestJobHistoryId,
//       'name': name,
//       'requestJobCreatedOn': requestJobCreatedOn.toIso8601String(),
//       'taskName': taskName,
//       'comment': comment,
//       'decripyionArabian': decripyionArabian,
//       'taskId': taskId,
//     };
//   }
// }
