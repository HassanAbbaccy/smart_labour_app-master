import 'package:flutter/foundation.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  final ValueNotifier<String> localeNotifier = ValueNotifier<String>('en');

  String get currentLocale => localeNotifier.value;

  void toggleLocale() {
    localeNotifier.value = localeNotifier.value == 'en' ? 'ur' : 'en';
  }

  void setLocale(String locale) {
    if (locale == 'en' || locale == 'ur') {
      localeNotifier.value = locale;
    }
  }

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'app_title': 'SmartLabour',
      'welcome_back': 'Welcome back',
      'signin_desc': 'Please enter your email and password to sign in.',
      'email': 'Email',
      'password': 'Password',
      'signin': 'Sign In',
      'signup': 'Sign Up',
      'already_have_acc': 'Already have an account?',
      'dont_have_acc': 'Don\'t have an account?',
      'forgot_password': 'Forgot Password?',
      'home': 'Home',
      'search': 'Search',
      'feed': 'Feed',
      'jobs': 'Jobs',
      'chat': 'Chat',
      'profile': 'Profile',
      'recent_activity': 'Recent Activity',
      'categories': 'Categories',
      'see_all': 'See All',
      'nearby_workers': 'Nearby Professionals',
      'hire_now': 'Hire Now',
      'schedule_job': 'Schedule Job',
      'job_details': 'Job Details',
      'mark_completed': 'Mark Completed',
      'ratings': 'Ratings',
      'reviews': 'Reviews',
      'withdraw': 'Withdraw',
      'wallet_balance': 'Wallet Balance',
      'language': 'Language',
      'settings': 'Settings',
      'logout': 'Logout',
      'location': 'Location',
      'description': 'Description',
      'pay': 'Pay',
      'status': 'Status',
      'confirm_booking': 'Confirm Booking',
      'select_date': 'Select Date',
      'select_time': 'Select Time',
      'apply': 'Apply',
      'application_submitted': 'Application submitted successfully!',
      'hired_success': 'Hired successfully!',
      'distance': 'Distance',
      'km_away': 'km away',
      'no_workers_found': 'No workers found in this category',
      'featured_workers': 'Featured Workers',
      'top_rated': 'Top Rated',
      'hiring_options': 'Hiring Options',
      'hourly_rate': 'Hourly Rate',
      'availability': 'Availability',
      'client_reviews': 'Client Reviews',
      'experience': 'Experience',
      'whatsapp': 'WhatsApp',
    },
    'ur': {
      'app_title': 'اسمارٹ لیبر',
      'welcome_back': 'خوش آمدید',
      'signin_desc': 'سائن ان کرنے کے لیے براہ کرم اپنا ای میل اور پاس ورڈ درج کریں۔',
      'email': 'ای میل',
      'password': 'پاس ورڈ',
      'signin': 'سائن ان کریں',
      'signup': 'سائن اپ کریں',
      'already_have_acc': 'پہلے سے اکاؤنٹ ہے؟',
      'dont_have_acc': 'اکاؤنٹ نہیں ہے؟',
      'forgot_password': 'پاس ورڈ بھول گئے؟',
      'home': 'ہوم',
      'search': 'تلاش',
      'feed': 'فیڈ',
      'jobs': 'کام',
      'chat': 'چیٹ',
      'profile': 'پروفائل',
      'recent_activity': 'حالیہ سرگرمی',
      'categories': 'اقسام',
      'see_all': 'سب دیکھیں',
      'nearby_workers': 'قریبی ماہرین',
      'hire_now': 'ابھی ہائر کریں',
      'schedule_job': 'کام شیڈول کریں',
      'job_details': 'کام کی تفصیلات',
      'mark_completed': 'مکمل نشان زد کریں',
      'ratings': 'ریٹنگز',
      'reviews': 'تبصرے',
      'withdraw': 'رقم نکالیں',
      'wallet_balance': 'والٹ بیلنس',
      'language': 'زبان',
      'settings': 'ترتیبات',
      'logout': 'لاگ آؤٹ',
      'location': 'مقام',
      'description': 'تفصیل',
      'pay': 'ادائیگی',
      'status': 'حالت',
      'confirm_booking': 'بکنگ کی تصدیق کریں',
      'select_date': 'تاریخ منتخب کریں',
      'select_time': 'وقت منتخب کریں',
      'apply': 'درخواست دیں',
      'application_submitted': 'درخواست کامیابی کے ساتھ جمع کر دی گئی!',
      'hired_success': 'ہائرنگ کامیاب رہی!',
      'distance': 'فاصلہ',
      'km_away': 'کلومیٹر دور',
      'no_workers_found': 'اس زمرے میں کوئی ورکر نہیں ملا',
      'featured_workers': 'نمایاں ورکرز',
      'top_rated': 'اعلی درجہ بندی',
      'hiring_options': 'ہائرنگ کے اختیارات',
      'hourly_rate': 'گھنٹہ کی شرح',
      'availability': 'دستیابی',
      'client_reviews': 'کلائنٹ کے تبصرے',
      'experience': 'تجربہ',
      'whatsapp': 'واٹس ایپ',
    },
  };

  String translate(String key) {
    return _translations[currentLocale]?[key] ?? key;
  }
}

// Global helper for cleaner code
String tr(String key) => LocalizationService().translate(key);
