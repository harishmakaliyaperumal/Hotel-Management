import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/dashboard/screens/users_page_screens/user_food_services.dart';

class FoodServicesCard extends StatefulWidget {
  @override
  _FoodServicesCardState createState() => _FoodServicesCardState();
}

class _FoodServicesCardState extends State<FoodServicesCard> {
  String? selectedRestaurant;
  List<String> restaurants = [
    'Restaurant A',
    'Restaurant B',
    'Restaurant C'
  ];

  void _showRestaurantSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Restaurant'),
          content: DropdownButton<String>(
            value: selectedRestaurant,
            hint: Text('Choose a Restaurant'),
            items: restaurants.map((String restaurant) {
              return DropdownMenuItem<String>(
                value: restaurant,
                child: Text(restaurant),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedRestaurant = newValue;
              });
              Navigator.of(context).pop(); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserFoodServices(
                    selectedRestaurant: selectedRestaurant!,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: _showRestaurantSelectionDialog,
        child: Container(
          width: 200,
          height: 100,
          alignment: Alignment.center,
          child: const Text(
            'FOOD SERVICES',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

