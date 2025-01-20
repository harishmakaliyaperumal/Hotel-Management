class GeneralRequest {
  final String id;
  final String userName;
  final String taskName;
  final String description;
  final String descriptionNorwegian;
  final String name;
  final String roomName;
  final String jobStatus;
  final String estimationTime;
  final String roomId;
  final String nextJobStatus;
  final String requestJobHistoryId;
  final String flag;
  final bool feedbackStatus;
  final String? completedAt;

  GeneralRequest({
    required this.id,
    required this.userName,
    required this.taskName,
    required this.description,
    required this.descriptionNorwegian,
    required this.name,
    required this.roomName,
    required this.jobStatus,
    required this.estimationTime,
    required this.roomId,
    required this.nextJobStatus,
    required this.requestJobHistoryId,
    required this.flag,
    required this.feedbackStatus,
    this.completedAt,
  });

  factory GeneralRequest.fromJson(Map<String, dynamic> json) {
    return GeneralRequest(
      id: json['id']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      taskName: json['taskName']?.toString() ?? '',
      description: json['Description']?.toString() ?? '',
      descriptionNorwegian: json['DescriptionNorweign']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      roomName: json['roomName']?.toString() ?? '',
      jobStatus: json['jobStatus']?.toString() ?? '',
      estimationTime: json['estimationTime']?.toString() ?? '',
      roomId: json['roomId']?.toString() ?? '',
      nextJobStatus: json['nextJobStatus']?.toString() ?? '',
      requestJobHistoryId: json['requestJobHistoryId']?.toString() ?? '',
      flag: json['flag']?.toString() ?? '',
      feedbackStatus: json['feedback_status'] ?? false,
      completedAt: json['completedAt']?.toString(),
    );
  }
}
