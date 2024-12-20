class KitchenRequest {
  final RequestData requestData;
  final String requestOrderStatus;
  final String? nextStatus;
  final int restaurantOrderId;
  final String descriptionNorwegian;
  final String descriptionArabian;

  KitchenRequest({
    required this.requestData,
    required this.requestOrderStatus,
    this.nextStatus,
    required this.restaurantOrderId,
    required this.descriptionNorwegian,
    required this.descriptionArabian,
  });

  factory KitchenRequest.fromJson(Map<String, dynamic> json) {
    return KitchenRequest(
      requestData: RequestData.fromJson(json['requestData']),
      requestOrderStatus: json['requestOrderStatus'] ?? '',
      nextStatus: json['nextStatus'],
      restaurantOrderId: json['restaurantOrderId'],
        descriptionNorwegian:json['descriptionNorwegian'] ?? '',
        descriptionArabian:json['descriptionArabian'] ?? ''
    );
  }
}

class RequestData {
  final int restaurantOrderId;
  final String rname;
  final String description;
  final String nextStatus;
  final String descriptionNorwegian;
  final String descriptionArabian;





  RequestData({
    required this.restaurantOrderId,
    required this.rname,
    required this.description,
    required this.nextStatus,
    required this.descriptionNorwegian,
    required this.descriptionArabian,


  });

  factory RequestData.fromJson(Map<String, dynamic> json) {
    return RequestData(
      restaurantOrderId: json['restaurantOrderId'] ?? 0,
      rname: json['rname'] ?? '',
       description: json['description'] ?? '',
       nextStatus: json['nextStatus'] ?? '',
      descriptionNorwegian: json['descriptionNorwegian'] ?? '',
      descriptionArabian: json['descriptionArabian'] ?? '',



    );
  }
}