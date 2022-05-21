import 'package:get_it/get_it.dart';

import './list_helper.dart';

GetIt getIt = GetIt.instance;

class XuGetIt {
  static void setup() {
    getIt.registerSingleton<ListHelperState>(ListHelperState(),
        signalsReady: true);
  }
}
