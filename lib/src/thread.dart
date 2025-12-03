import 'dart:isolate';
import 'package:easy_isolate/src/messages.dart';
import 'package:easy_isolate/src/thread_interface.dart';

/// An abstract class that represents a worker thread in an isolate-based
/// concurrency model.
///
/// The `WorkerThread` is designed to run in a separate isolate and perform
/// tasks delegated by a [MasterThread]. It communicates with the master thread
/// using `SendPort` and `ReceivePort` mechanisms.
///
/// Implementations of this class must provide concrete logic for handling
/// messages received from the master thread via the `onMessageReceived` method.
///
/// This class extends [ThreadInterface] with a generic type of [SendPort],
/// indicating that it initializes with a `SendPort` to communicate back
/// to the master thread.
abstract class Thread<T extends Object, X extends Object>
    implements ThreadInterface<SendPort, T, X> {
  late final SendPort _sendPort;
  late final ReceivePort _receivePort;

  @override
  Future<void> initializeThread(SendPort sendPort) async {
    _sendPort = sendPort;
    _receivePort = ReceivePort("$runtimeType");

    void onRawMessageReceived(dynamic data) async {
      if (data is TerminationMessage) {
        return await terminateThread();
      }

      onMessageReceived(data as T);
    }

    _receivePort.listen(onRawMessageReceived);

    _sendPort.send(_receivePort.sendPort);
  }

  @override
  void sendMessage(X message) => _sendPort.send(message);

  @override
  Future<void> terminateThread() async => _receivePort.close();
}