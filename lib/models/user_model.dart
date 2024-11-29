// lib/models/user_model.dart

class User {
  final int userId;
  final String userName;
  final String userType;
  final int roomNo;
  final int floorId;

  User({
    required this.userId,
    required this.userName,
    required this.userType,
    required this.roomNo,
    required this.floorId,
  });

  // Factory constructor to create User instance from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['id'],
      userName: json['username'],
      userType: json['userType'],
      roomNo: json['roomNo'],
      floorId: json['floorId'],
    );
  }

  // Method to convert User instance to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'username': userName,
      'userType': userType,
      'roomNo': roomNo,
      'floorId': floorId,
    };
  }
}
