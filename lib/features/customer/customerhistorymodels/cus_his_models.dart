class CustomerRequest {
  final String taskName;
  final String jobStatus;
  final String startTime;
  final String endTime;
  final String description;
  final String requestDataId;

  CustomerRequest({
    required this.taskName,
    required this.jobStatus,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.requestDataId,
  });

  // Convert CustomerRequest to a map
  Map<String, dynamic> toMap() {
    return {
      'taskName': taskName,
      'jobStatus': jobStatus,
      'startTime': startTime,
      'endTime': endTime,
      'description': description,
      'requestDataId': requestDataId,
    };
  }

  // Create a CustomerRequest from a map
  factory CustomerRequest.fromMap(Map<String, dynamic> map) {
    return CustomerRequest(
      taskName: map['taskName'] ?? '',
      jobStatus: map['jobStatus'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      description: map['description'] ?? '',
        requestDataId: (map['requestDataId'] ?? 0).toString() ,
    );



  }
  Map<String, dynamic> toJson() => toMap();
}
