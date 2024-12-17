// class RequestJob {
//   final bool requestJobIsActive;
//   final int roomDataId;
//   final String nextJobStatus;
//   final String jobStatus;
//   final String? flag;
//   final String description;
//   final DateTime requestJobUpdatedOn;
//   final String taskNorweign;
//   final dynamic flagsData; // Use dynamic as the type is unknown
//   final String descriptionNorweign;
//   final String userName;
//   final String taskArabian;
//   final int userId;
//   final int roomId;
//   final int roomName;
//   final int requestJobHistoryId;
//   final String name;
//   final DateTime requestJobCreatedOn;
//   final String taskName;
//   final String decripyionArabian;
//   final int taskId;
//
//   RequestJob({
//     required this.requestJobIsActive,
//     required this.roomDataId,
//     required this.nextJobStatus,
//     required this.jobStatus,
//     this.flag,
//     required this.description,
//     required this.requestJobUpdatedOn,
//     required this.taskNorweign,
//     this.flagsData,
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
//     required this.decripyionArabian,
//     required this.taskId,
//   });
//
//   factory RequestJob.fromJson(Map<String, dynamic> json) {
//     return RequestJob(
//       requestJobIsActive: json['requestJobIsActive'],
//       roomDataId: json['roomDataId'],
//       nextJobStatus: json['nextJobStatus'],
//       jobStatus: json['jobStatus'],
//       flag: json['flag'],
//       description: json['Description'],
//       requestJobUpdatedOn: DateTime.parse(json['requestJobUpdatedOn']),
//       taskNorweign: json['taskNorweign'],
//       flagsData: json['flagsData'],
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
//       decripyionArabian: json['decripyionArabian'],
//       taskId: json['taskId'],
//     );
//   }
//
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
//       'decripyionArabian': decripyionArabian,
//       'taskId': taskId,
//     };
//   }
// }

class RequestJob {
  final String userName;
  final String Description;
  final String taskName;
  final String jobStatus;
  final int requestJobHistoryId;

  RequestJob({
    required this.userName,
    required this.Description,
    required this.taskName,
    required this.jobStatus,
    required this.requestJobHistoryId,
  });

  factory RequestJob.fromJson(Map<String, dynamic> json) {
    return RequestJob(
      userName: json['userName'] ?? 'Unknown User',
      Description: json['Description'] ?? 'No description',
      taskName: json['taskName'] ?? 'Unnamed Task',
      jobStatus: json['jobStatus'] ?? 'Unknown',
      requestJobHistoryId: json['requestJobHistoryId'] ?? 0, // Corrected field name
    );
  }
}





