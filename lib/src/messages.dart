import 'dart:isolate';
import 'package:easy_isolate/src/thread.dart';

final class InitializationMessage {
  final SendPort sendPort;
  final Thread workerThread;
  const InitializationMessage(this.sendPort, this.workerThread);
}

final class TerminationMessage {}
