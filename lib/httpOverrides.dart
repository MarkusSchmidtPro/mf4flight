import 'dart:io';

class DEV_HttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (host == '10.0.2.2') {
          print('⚠️ Certificate verification disabled for $host:$port');
          return true; // Accept any certificate;
        }
        return false; 
      };
  }
}
