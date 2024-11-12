import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/dashboard/servicedashboard.dart';
import 'package:holtelmanagement/features/dashboard/userdashboard.dart';
import 'package:holtelmanagement/features/services/apiservices.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Common/app_bar.dart';
import '../../classes/language.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userEmailIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;


  // Keys for SharedPreferences
  static const String KEY_JWT = 'jwt';
  static const String KEY_USER_ID = 'userId';
  static const String KEY_USERNAME = 'username';
  static const String KEY_TOKEN = 'token';
  static const String KEY_USER_TYPE = 'userType';
  static const String KEY_STATUS = 'status';
  static const String KEY_ROOM_NO = 'roomNo';
  static const String KEY_FLOOR_ID = 'floorId';

  Future<void> _saveLoginData(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_JWT, response['jwt']);
    await prefs.setInt(KEY_USER_ID, response['id']);
    await prefs.setString(KEY_USERNAME, response['username']);
    await prefs.setString(KEY_TOKEN, response['token']);
    await prefs.setString(KEY_USER_TYPE, response['userType']);
    await prefs.setInt(KEY_STATUS, response['status']);
    if (response['roomNo'] != null) {
      await prefs.setInt(KEY_ROOM_NO, response['roomNo']);
    }
    if (response['floorId'] != null) {
      await prefs.setInt(KEY_FLOOR_ID, response['floorId']);
    }
  }

  @override
  void initState() {

    super.initState();
    _loadSavedLanguage();
  }
  Language _selectedLanguage = Language.languageList().first;

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString('language_code') ?? 'en';

    setState(() {
      _selectedLanguage = Language.languageList().firstWhere(
            (lang) => lang.languageCode == savedLanguageCode,
        orElse: () => Language.languageList().first,
      );
    });
  }



  // Function to handle language change
  void onLanguageChange(Language newLanguage) {
    setState(() {
      _selectedLanguage = newLanguage;
    });
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().login(
        _userEmailIdController.text,
        _passwordController.text,
      );

      if (response.containsKey('error')) {
        _showError(response['details']);
        return;
      }

      await _saveLoginData(response);

      final userType = response['userType'];
      final userName = response['username'];
      final userId = response['id'];
      final roomNo = response['roomNo'];
      final floorId = response['floorId'];

      if (userType == 'CUSTOMER') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => UserDashboard(
            userName: userName, userId: userId, floorId: floorId, roomNo: roomNo, loginResponse: response)));
      } else if (userType == 'SERVICE') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ServicesDashboard(
            userId: userId, userName: userName, roomNo: roomNo.toString(), floorId: floorId.toString())));
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
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppColors.backgroundColor,
      // appBar: buildAppBar(
      //   context,
      //   _selectedLanguage,
      //   onLanguageChange,
      //   isLoginPage: true,
      //   extraActions: [],
      // ),
      body: Stack(
        children: [
          Positioned.fill(
            top: 30,
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: AppColors.whiteColor,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('INN-SERV', style: TextStyle(color: AppColors.whiteColor, fontSize: 26)),
                const Text('HOTEL MANAGEMENT', style: TextStyle(color: AppColors.whiteColor, fontSize: 10)),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context).translate('loing_pg_text_welcome'),
                  style: const TextStyle(color: AppColors.whiteColor, fontSize: 23, fontWeight: FontWeight.bold),
                ),

              ],
            ),

          ),

          Positioned(
            top: 290,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('loing_pg_htext_login'),
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _userEmailIdController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.supervised_user_circle_outlined, color: Colors.black),
                        hintText: AppLocalizations.of(context).translate('login_pg_form_filed_userEmailId'),
                        hintStyle: const TextStyle(color: Colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.backgroundColor, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Colors.black),
                        hintText: AppLocalizations.of(context).translate('login_pg_form_filed_userPassword'),
                        hintStyle: const TextStyle(color: Colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.backgroundColor, width: 1.5),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: Colors.black),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.textColor))
                        : Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.backgroundColor,
                      ),
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          AppLocalizations.of(context).translate('login_pg_form_filed_button_login'),
                          style: const TextStyle(fontSize: 18, color: AppColors.whiteColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}