/// An abstract interface for classes that can send messages.
///
/// Classes implementing this interface must provide an implementation for
/// the [sendMessage] method, which is used to send a message.
abstract interface class MessageSendable<T extends Object> {
  /// Sends a message.
  ///
  /// This method is used to send a message to a receiver. The [message] parameter
  /// contains the content of the message to be sent.
  void sendMessage(T message);
}
