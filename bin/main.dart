import 'dart:isolate';
import 'package:easy_isolate/dart_thread.dart';

class MainThread extends ThreadController<DateTime, String> {
  @override
  void onMessageReceived(String message) async {
    print(
      "[${Isolate.current.debugName}] Message received from child thread at $message",
    );

    await Future.delayed(const Duration(seconds: 1));

    sendMessage(DateTime.now());
  }

  @override
  Future<void> initializeThread(Thread<DateTime, String> workerThread) async {
    await super.initializeThread(workerThread);
    sendMessage(DateTime.now());
  }

  @override
  Future<void> terminateThread() async {
    await super.terminateThread();
    print("Main thread terminated");
  }
}

class ChildThread extends Thread<DateTime, String> {
  @override
  void onMessageReceived(DateTime message) async {
    print(
      "[${Isolate.current.debugName}] Message received from main thread at $message",
    );

    await Future.delayed(const Duration(seconds: 1));

    sendMessage("${DateTime.now()}");
  }

  @override
  Future<void> terminateThread() async {
    await super.terminateThread();
    print("Child thread terminated");
  }
}

void main() async {
  final mainThread = MainThread();
  final childThread = ChildThread();

  await mainThread.initializeThread(childThread);
  await Future.delayed(const Duration(seconds: 20));
  await mainThread.terminateThread();
}