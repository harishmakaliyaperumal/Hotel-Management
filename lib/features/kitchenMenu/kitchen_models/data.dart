class KitchenRequest {
  final RequestData requestData;
  final String requestOrderStatus;
  final String? nextStatus;
  final int restaurantOrderId;

  KitchenRequest({
    required this.requestData,
    required this.requestOrderStatus,
    this.nextStatus,
    required this.restaurantOrderId,
  });

  factory KitchenRequest.fromJson(Map<String, dynamic> json) {
    return KitchenRequest(
      requestData: RequestData.fromJson(json['requestData']),
      requestOrderStatus: json['requestOrderStatus'] ?? '',
      nextStatus: json['nextStatus'],
      restaurantOrderId: json['restaurantOrderId']
    );
  }
}

class RequestData {
  final int restaurantOrderId;
  final String rname;
  final String description;
  final String nextStatus;



  RequestData({
    required this.restaurantOrderId,
    required this.rname,
    required this.description,
    required this.nextStatus

  });

  factory RequestData.fromJson(Map<String, dynamic> json) {
    return RequestData(
      restaurantOrderId: json['restaurantOrderId'] ?? 0,
      rname: json['rname'] ?? '',
       description: json['description'] ?? '',
       nextStatus: json['nextStatus'] ?? ''

    );
  }
}