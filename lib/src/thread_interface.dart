import 'package:easy_isolate/src/message_listenable.dart';
import 'package:easy_isolate/src/message_sendable.dart';

/// An abstract interface for defining the contract of a thread, which can be
/// either a [ThreadController] (the master) or a [Thread] (the worker).
///
/// Classes implementing this interface must provide implementations for
/// [initializeThread], [terminateThread], [onMessageReceived], and [sendMessage].
abstract interface class ThreadInterface<
  I extends Object,
  T extends Object,
  X extends Object
>
    implements MessageListenable<T>, MessageSendable<X> {
  /// Initializes the thread with a given argument.
  ///
  /// The [argument] can be a [SendPort] for a [Thread] or
  /// a [Thread] instance for a [ThreadController].
  /// This method sets up the necessary communication channels and resources
  /// for the thread to operate.
  Future<void> initializeThread(I argument);

  /// Terminates the thread, releasing any resources it holds.
  ///
  /// This method should gracefully shut down the thread's operations
  /// and close any open communication channels.
  Future<void> terminateThread();
}
