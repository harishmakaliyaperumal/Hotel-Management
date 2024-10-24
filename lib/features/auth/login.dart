import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/dashboard/servicedashboard.dart';
import 'package:holtelmanagement/features/dashboard/userdashboard.dart';
import 'package:holtelmanagement/features/services/apiservices.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;


  // Keys for SharedPreferences
  static const String KEY_JWT = 'jwt';
  static const  KEY_USER_ID = 'userId';
  static const String KEY_USERNAME = 'username';
  static const String KEY_TOKEN = 'token';
  static const String KEY_USER_TYPE = 'userType';
  static const String KEY_STATUS = 'status';
  static const String KEY_roomNo = 'roomNo';
  static const String KEY_floorId = 'floorId';


  Future<void> _saveLoginData(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_JWT, response['jwt']);
    await prefs.setInt(KEY_USER_ID, response['id']);
    await prefs.setString(KEY_USERNAME, response['username']);
    await prefs.setString(KEY_TOKEN, response['token']);
    await prefs.setString(KEY_USER_TYPE, response['userType']);
    await prefs.setInt(KEY_STATUS, response['status']);
    // await prefs.setInt(KEY_roomNo, response['roomNo']);
    // await prefs.setInt(KEY_floorId, response['floorId']);

    if (response['roomNo'] != null) {
      await prefs.setInt(KEY_roomNo, response['roomNo']);
    }
    if (response['floorId'] != null) {
      await prefs.setInt(KEY_floorId, response['floorId']);
    }

  }



  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().login(
        _usernameController.text,
        _passwordController.text,
      );

      if (response.containsKey('error')) {
        _showError(response['details']);
        return;
      }

      // Save response data to SharedPreferences
      await _saveLoginData(response);

      final  userType = response['userType'];
      final  userName = response['username'];
      final  userId = response['id'];
      final roomNo = response['roomNo'];
      final floorId = response['floorId'];


      print('User Type: $userType');
      print('User Name: $userName');
      print('User Id:$userId');
      // print('User Data: $userDashboardData');

      // Navigate based on the userType
      if (userType == 'CUSTOMER') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) =>UserDashboard(userName: userName,
          userId: userId,
          loginResponse: response,)));
      } else if (userType == 'SERVICE') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) =>ServicesDashboard(
          userId: userId,
          userName: userName,
          roomNo: roomNo.toString(),   // Convert int to String if roomNo is an int
          floorId: floorId.toString(),
        )));
      } else {
        _showError("Unknown user type");
      }

    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 15,
                      offset: Offset(4, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "WELCOME BACK",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: _usernameController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.supervised_user_circle_outlined, color: Colors.black),
                        hintText: "User Name",
                        hintStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF7bb274), width: 4.0), // Green border when not focused
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF7bb274), width: 4.0), // Blue border when focused
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                          // borderColor:Colors.greenAccent,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                      obscureText: _obscureText,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Colors.black),
                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF7bb274), width: 4.0), // Green border when not focused
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color:Color(0xFF7bb274), width: 4.0), // Blue border when focused
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black87,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            Colors.lightGreenAccent.withOpacity(0.1),
                            Color(0xFF7bb274),
                          ],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}