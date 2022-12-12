import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

class Internet {
  String id = 'id';

  static Future<bool> isInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      if (await DataConnectionChecker().hasConnection) {
        // print("Mobile data detected & internet connection confirmed.");
        return true;
      } else {
        // print('No internet :( Reason:');
        return false;
      }
    } else if (connectivityResult == ConnectivityResult.wifi) {
      if (await DataConnectionChecker().hasConnection) {
        // print("wifi data detected & internet connection confirmed.");
        return true;
      } else {
        // print('No internet :( Reason:');
        return false;
      }
    } else {
      // print(
      //     "Neither mobile data or WIFI detected, not internet connection found.");
      return false;
    }
  }
}
