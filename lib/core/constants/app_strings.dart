/// Centralized user-facing strings (Module 1).
/// Swap this for a localization solution (intl / arb files) in Module 9.
abstract final class AppStrings {
  static const appName = 'TailorConnect';
  static const tagline = 'Custom Clothing Made Easy';

  // Onboarding
  static const onboardTitle1 = 'Find the right tailor';
  static const onboardBody1 =
      'Browse verified tailors near you, compare portfolios, prices, and reviews before you book.';
  static const onboardTitle2 = 'Made to your measure';
  static const onboardBody2 =
      'Save measurement profiles for yourself and your family, then reuse them on every order.';
  static const onboardTitle3 = 'Track every stitch';
  static const onboardBody3 =
      'Follow your order from cutting to delivery, chat with your tailor, and pay securely.';
  static const skip = 'Skip';
  static const next = 'Next';
  static const getStarted = 'Get started';

  // Auth
  static const login = 'Log in';
  static const register = 'Create account';
  static const email = 'Email';
  static const password = 'Password';
  static const confirmPassword = 'Confirm password';
  static const fullName = 'Full name';
  static const phone = 'Phone number';
  static const rememberMe = 'Remember me';
  static const forgotPassword = 'Forgot password?';
  static const continueWithGoogle = 'Continue with Google';
  static const noAccount = "Don't have an account?";
  static const haveAccount = 'Already have an account?';
  static const resetPassword = 'Reset password';
  static const resetPasswordHint =
      'Enter the email you registered with and we will send you a reset link.';
  static const sendResetLink = 'Send reset link';

  // Roles
  static const chooseRole = 'How will you use TailorConnect?';
  static const roleCustomerTitle = 'I need a tailor';
  static const roleCustomerBody =
      'Order custom clothing, save measurements, and track progress.';
  static const roleTailorTitle = 'I am a tailor';
  static const roleTailorBody =
      'Receive orders, manage your shop, and grow your business.';
  static const businessName = 'Shop / business name';
}
