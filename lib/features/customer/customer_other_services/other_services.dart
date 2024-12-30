import 'package:flutter/material.dart';

import '../../../classes/language.dart';
import '../../../common/helpers/app_bar.dart';

import '../../services/apiservices.dart';
import '../cus_model/otherservices_models.dart';

class OtherServices extends StatefulWidget {
  const OtherServices({super.key});

  @override
  State<OtherServices> createState() => _OtherServicesState();
}

class _OtherServicesState extends State<OtherServices> {
  String? selectedMainService;
  String? selectedService;
  TimeOfDay? selectedTime;
  final ApiService _apiService = ApiService();

  final List<String> mainServices = ['otherService', 'wakeUpService'];
  List<String> services = []; // Dynamic list of services from API

  // Handle time selection
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // Fetch services based on selected main service
  // Fetch services based on selected main service
  Future<void> _fetchServices(String serviceType) async {
    try {
      final userType = serviceType == 'Other Services' ? 'otherService' : 'wakeUpService';
      final AllServices response = await _apiService.getallotherservices(userType);

      setState(() {
        // Extract service names from the data list
        services = response.data.map((service) => service.serviceName).toList();
        selectedService = null; // Reset the selected service
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load services: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }





  // Handle form submission
  void _handleSubmit() {
    if (selectedMainService == null || selectedService == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service Type: $selectedMainService'),
            Text('Selected Service: $selectedService'),
            Text('Time: ${selectedTime?.format(context)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context: context,
        onLanguageChange: (Language newLanguage) {
          // Handle language change
        },
        isLoginPage: false,
        extraActions: [],
        dashboardType: DashboardType.other,
        onLogout: () {
          logOut(context);
        },
        apiService: _apiService,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Service Type',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedMainService,
                  items: mainServices.map((String service) {
                    return DropdownMenuItem<String>(
                      value: service,
                      child: Text(service),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        selectedMainService = value;
                        selectedService = null; // Reset the secondary selection
                        services.clear(); // Clear previous services
                      });
                      _fetchServices(value);
                    }
                  },
                ),

                const SizedBox(height: 16),

                if (services.isNotEmpty)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Service',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedService,
                    items: services.map((String service) {
                      return DropdownMenuItem<String>(
                        value: service,
                        child: Text(service),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedService = value;
                      });
                    },
                  ),


                const SizedBox(height: 16),

                if (selectedService != null)
                  ElevatedButton.icon(
                    onPressed: () => _selectTime(context),
                    icon: const Icon(Icons.access_time),
                    label: Text(selectedTime != null
                        ? 'Selected Time: ${selectedTime?.format(context)}'
                        : 'Select Time'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),

                const SizedBox(height: 24),

                if (selectedService != null)
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text(
                      'Submit Request',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
