import '../screens/dashboard_page.dart';
import '../screens/registration_screen.dart';
import '../screens/login_page.dart';
import '../screens/splash_screen.dart';
import '../screens/admission_form_page.dart';
import 'routes_name.dart';

// Centralized routing configuration for the application
class AppRoutes{
  static final routes= {
    RouteNames.splashscreen: (context) => const SplashScreen(),
    RouteNames.registration: (context) => const RegistrationScreen(),
    RouteNames.login: (context) => const LoginPage(),
    RouteNames.dashboard: (context) => const DashboardPage(),
    RouteNames.admissionForm: (context) => const AdmissionFormPage(),
  };
}
