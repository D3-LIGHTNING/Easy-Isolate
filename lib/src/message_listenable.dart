/// An abstract interface for classes that can listen for messages.
///
/// Classes implementing this interface must provide an implementation for
/// the [onMessageReceived] method, which is called when a message is received.
abstract interface class MessageListenable<T extends Object> {
  /// Handles the reception of a message.
  ///
  /// This method is invoked when a message is received. The [message] parameter
  /// contains the content of the received message.
  void onMessageReceived(T message);
}
