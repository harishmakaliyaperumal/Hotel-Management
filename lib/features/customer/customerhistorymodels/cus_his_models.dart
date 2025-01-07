class CustomerRequest {
  final String taskName;
  final String jobStatus;
  final String starttime;
  final String? endTime;
  final String? date;  // Added date field
  final String? time;
  final String description;
  final int requestDataId;
  final String rname;
  final int floorId;
  final String floorName;
  final bool requestDataIsActive;
  final String descriptionArabian;
  final String descriptionNorweign;
  final String taskArabian;
  final String taskNorweign;
  final int? flagData;
  final int taskId;
  final int createdBy;
  final String? rating;
  final String? ratingComment;
  final List<dynamic> jobHistories;

  CustomerRequest({
    required this.taskName,
    required this.jobStatus,
    required this.starttime,
    this.endTime,
    this.date,
    this.time,
    required this.description,
    required this.requestDataId,
    required this.rname,
    required this.floorId,
    required this.floorName,
    required this.requestDataIsActive,
    required this.descriptionArabian,
    required this.descriptionNorweign,
    required this.taskArabian,
    required this.taskNorweign,
    this.flagData,
    required this.taskId,
    required this.createdBy,
    this.rating,
    this.ratingComment,
    required this.jobHistories,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskName': taskName,
      'jobStatus': jobStatus,
      'starttime': starttime,
      'endTime': endTime,
      'date': date,
      'time': time,
      'description': description,
      'requestDataId': requestDataId,
      'rname': rname,
      'floorId': floorId,
      'floorName': floorName,
      'requestDataIsActive': requestDataIsActive,
      'descriptionArabian': descriptionArabian,
      'descriptionNorweign': descriptionNorweign,
      'taskArabian': taskArabian,
      'taskNorweign': taskNorweign,
      'flagData': flagData,
      'taskId': taskId,
      'createdBy': createdBy,
      'rating': rating,
      'ratingComment': ratingComment,
      'jobHistories': jobHistories,
    };
  }

  factory CustomerRequest.fromMap(Map<String, dynamic> map) {
    return CustomerRequest(
      taskName: map['taskName']?.toString() ?? '',
      jobStatus: map['jobStatus']?.toString() ?? '',
      starttime: map['starttime']?.toString() ?? '',
      endTime: map['endTime']?.toString(),
      date: map['date']?.toString(),
      time: map['time']?.toString(),
      description: map['description']?.toString() ?? '',
      requestDataId: map['requestDataId'] is String
          ? int.tryParse(map['requestDataId']) ?? 0
          : map['requestDataId'] ?? 0,
      rname: map['rname']?.toString() ?? '',
      floorId: map['floorId'] is String
          ? int.tryParse(map['floorId']) ?? 0
          : map['floorId'] ?? 0,
      floorName: map['floorName']?.toString() ?? '',
      requestDataIsActive: map['requestDataIsActive'] ?? false,
      descriptionArabian: map['descriptionArabian']?.toString() ?? '',
      descriptionNorweign: map['descriptionNorweign']?.toString() ?? '',
      taskArabian: map['taskArabian']?.toString() ?? '',
      taskNorweign: map['taskNorweign']?.toString() ?? '',
      flagData: map['flagData'],
      taskId: map['taskId'] is String
          ? int.tryParse(map['taskId']) ?? 0
          : map['taskId'] ?? 0,
      createdBy: map['createdBy'] is String
          ? int.tryParse(map['createdBy']) ?? 0
          : map['createdBy'] ?? 0,
      rating: map['rating']?.toString(),
      ratingComment: map['ratingComment']?.toString(),
      jobHistories: map['jobHistories'] ?? [],
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
