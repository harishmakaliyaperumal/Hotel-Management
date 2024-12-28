class LoginResponse {
  final String jwt;
  final int id;
  final String username;
  final String userType;
  final int? roomNo;
  final int? floorId;
  final int status;

  LoginResponse({
    required this.jwt,
    required this.id,
    required this.username,
    required this.userType,
    this.roomNo,
    this.floorId,
    required this.status,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      jwt: json['jwt'] as String,
      id: json['id'] as int,
      username: json['username'] as String,
      userType: json['userType'] as String,
      roomNo: json['roomNo'] as int?,
      floorId: json['floorId'] as int?,
      status: json['status'] as int? ?? 0,
    );
  }
}