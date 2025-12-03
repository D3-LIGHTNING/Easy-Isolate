import 'dart:async';
import 'dart:isolate';
import 'package:easy_isolate/src/messages.dart';
import 'package:easy_isolate/src/thread_interface.dart';
import 'package:easy_isolate/src/thread.dart';

/// An abstract class that represents the master thread in an isolate-based
/// concurrency model.
///
/// The `MasterThread` is responsible for spawning and managing a [Thread].
/// It communicates with the worker thread using `SendPort` and `ReceivePort`
/// mechanisms.
///
/// Implementations of this class must provide concrete logic for handling
/// messages received from the worker thread via the `onMessageReceived` method.
///
/// This class extends [ThreadInterface] with a generic type of [Thread],
/// indicating that it initializes with a worker thread instance.
abstract class ThreadController<T extends Object, X extends Object>
    implements ThreadInterface<Thread<T, X>, X, T> {
  late final Isolate _controller;
  late final SendPort _sendPort;
  late final ReceivePort _receivePort;

  @override
  Future<void> initializeThread(Thread<T, X> workerThread) async {
    _receivePort = ReceivePort("$runtimeType");
    Completer completer = Completer<void>();

    void onRawMessageReceived(dynamic data) {
      if (data is SendPort) {
        _sendPort = data;
        completer.complete();
        return;
      }

      onMessageReceived(data as X);
    }

    _receivePort.listen(onRawMessageReceived);

    _controller = await Isolate.spawn<InitializationMessage>(
      _RemoteExectionPerformer.startRemoteExecution,
      InitializationMessage(_receivePort.sendPort, workerThread),
      debugName: "${workerThread.runtimeType}",
    );

    return completer.future;
  }

  @override
  void sendMessage(T data) => _sendPort.send(data);

  @override
  Future<void> terminateThread() async {
    _sendPort.send(const TerminationMessage());

    _controller.kill();
    _receivePort.close();
  }
}

// A utility class that performs the entry point execution for the thread in creation.
class _RemoteExectionPerformer {
  // Acts as the entrypoint to the thread being created
  static void startRemoteExecution(InitializationMessage message) async {
    final sendPort = message.sendPort;
    final workerThread = message.workerThread;

    await workerThread.initializeThread(sendPort);
  }
}
