import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => dotenv.get('SUPABASE_URL');
  static String get supabaseKey => dotenv.get('SUPABASE_KEY');
  static String get kakaoNativeAppKey => dotenv.get('KAKAO_NATIVE_APP_KEY');
  static String get googleMapsApiKey => dotenv.get('GOOGLE_MAPS_API_KEY');
}
