// import 'package:workmanager/workmanager.dart';
//
// class BackgroundExecutor {
//
//   static const androidTask = "AndroidTask";
//
//   static void callbackDispatcher() {
//     Workmanager().executeTask((task, inputData) {
//       switch (task) {
//         case androidTask:
//           print("this method was called from native!");
//           break;
//         case Workmanager.iOSBackgroundTask:
//           print("iOS background fetch delegate ran");
//           break;
//       }
//       return Future.value(true);
//     });
//   }
// }