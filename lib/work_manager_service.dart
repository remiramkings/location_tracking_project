import 'package:workmanager/workmanager.dart';

class WorkManagerService{
  static void callbackDispatcher(){
    Workmanager().executeTask((taskName, inputData) {
      print('=================HELLO WORLD=====================');
      return Future.value(true);
    });
  }
}