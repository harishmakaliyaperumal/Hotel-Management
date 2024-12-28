import 'package:flutter/material.dart';
import 'package:holtelmanagement/common/helpers/constants.dart';
// import 'package:holtelmanagement/features/auth/screens/auth_page.dart';
import 'package:holtelmanagement/features/auth/widgets/login_button.dart';
import 'package:holtelmanagement/features/customer/user_menu.dart';
import 'package:holtelmanagement/features/kitchenMenu/screens/kitchendashboard.dart';
import '../../../common/helpers/app_bar.dart';
import '../../../common/helpers/shared_preferences_helper.dart';
import '../../dashboard/services/services_page_screens/servicedashboard.dart';
import '../widgets/email_field.dart';
import '../widgets/password_field.dart';
import 'package:holtelmanagement/features/services/apiservices.dart';
import 'package:provider/provider.dart';
import '../../../classes/ LanguageProvider.dart';
import '../../../classes/language.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';


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
  final ApiService _apiService = ApiService();

  final SharedPreferencesHelper _preferencesHelper = SharedPreferencesHelper();

  // final SharedPreferencesHelper _preferencesHelper = SharedPreferencesHelper();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LanguageProvider>(context, listen: false).initLanguage();
    });
  }
  // Function to handle language change
  void onLanguageChange(Language newLanguage) async {
    await Provider.of<LanguageProvider>(context, listen: false)
        .changeLanguage(newLanguage);
  }

  // Login functional
  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService(). login(
        _userEmailIdController.text,
        _passwordController.text,
      );

      if (response.containsKey('error')) {
        _showError(response['details']);
        return;
      }




      await _preferencesHelper.saveLoginData(response);
      final logindata =  await _preferencesHelper.getLoginData();
      print(logindata);

      final userType = response['userType'];
      final userName = response['username'];
      final userId = response['id'];
      // Convert to string explicitly
      final roomNo = int.tryParse(response['roomNo']?.toString() ?? '0') ?? 0;
      final floorId = int.tryParse(response['floorId']?.toString() ?? '0') ?? 0;




      if (userType == 'CUSTOMER') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => UserMenu(
            userName: userName, userId: userId, floorId: floorId, roomNo: roomNo, rname:userName,loginResponse: response)));
      } else if (userType == 'SERVICE') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ServicesDashboard(
            userId: userId, userName: userName, roomNo: roomNo.toString(), floorId: floorId.toString())));
      } else if(userType == "RESTAURANT"){
        Navigator.pushReplacement(context, MaterialPageRoute( builder:(_)=>KitchenDashboard()));
      }
      else {
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

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.whiteColor,
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(AppConstants.logo),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'INN-SERV',
          style: TextStyle(color: AppColors.whiteColor, fontSize: 26),
        ),
        const Text(
          'HOTEL MANAGEMENT',
          style: TextStyle(color: AppColors.whiteColor, fontSize: 10),
        ),
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context).translate('loing_pg_text_welcome'),
          style: const TextStyle(
              color: AppColors.whiteColor,
              fontSize: 23,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppColors.backgroundColor,
      appBar:  buildAppBar(
        context: context,
        onLanguageChange: (Language newLanguage) {
          // Handle language change
        },
        isLoginPage: true,
        extraActions: [], dashboardType: DashboardType.other,
        onLogout: () {
          logOut(context);
        },apiService: _apiService,
      ),
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
                    decoration:  const BoxDecoration(
                      color: AppColors.whiteColor,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(AppConstants.logo),
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
                    EmailField(controller: _userEmailIdController),
                    const SizedBox(height: 20),
                    PasswordField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      toggleVisibility: () => setState(() => _obscureText = !_obscureText),
                    ),
                    const SizedBox(height: 30),
                    LoginButton(isLoading: _isLoading, onPressed: _login),
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