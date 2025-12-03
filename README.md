<!-- TODO: Add badges for pub version, license, etc. once published -->
<!-- e.g., [![pub package](https://img.shields.io/pub/v/your_package_name.svg)](https://pub.dev/packages/your_package_name) -->

# Dart Isolate Abstraction

This project provides a high-level, object-oriented abstraction for multi-threading in Dart. It simplifies the use of `Isolate` by wrapping the complex handshake and communication boilerplate into two intuitive classes: `ThreadController` and `Thread`.

The design is inspired by the classic threading patterns found in languages like Java (`Thread`) and Python (`threading.Thread`), allowing developers to create concurrent applications by simply extending a class and implementing their business logic.

## Core Concepts

The library is built around two main classes that manage the communication between the main application and a worker isolate.

- **`ThreadController`**: This is the "master" class that lives on the main isolate. It is responsible for spawning, managing, and communicating with its corresponding `Thread`.
- **`Thread`**: This is the "worker" class. An instance of this class is sent to a new isolate to perform heavy computations or background tasks. It listens for messages from the `ThreadController` and can send results back.

## Features

- **Zero Boilerplate:** Abstracts away the initial `ReceivePort`/`SendPort` handshake.
- **Object-Oriented:** Use familiar inheritance patterns to create and manage threads.
- **Type-Safe Communication:** Leverages Dart generics to ensure type safety for messages passed between the controller and the thread.
- **Clean Lifecycle Management:** Simple `initializeThread()` and `terminateThread()` methods for clear control.

## Getting Started

### Prerequisites

Make sure you have the Dart SDK installed.

### Installation

This project is not yet on `pub.dev`. To use it locally, you can clone the repository and use a path dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  isolate_practice:
    path: ../path/to/isolate_practice
```

### Usage

Here is a simple example demonstrating a `TaskController` that offloads a task to a `TaskProcessorThread`.

```dart
import 'package:isolate_practice/isolate_practice.dart';
import 'dart:isolate';

// The Controller, living on the main isolate.
// It sends a `String` task and expects a `String` result.
class TaskController extends ThreadController<String, String> {
  @override
  void onMessageReceived(String result) {
    print(
      "[CONTROLLER] Result received from worker: '$result'",
    );
  }

  @override
  Future<void> initializeThread(Thread<String, String> workerThread) async {
    print("[CONTROLLER] Initializing worker thread...");
    await super.initializeThread(workerThread);
    print("[CONTROLLER] Worker thread initialized. Sending task.");
    // Once initialized, send the first task.
    sendMessage("Process this data");
  }

  @override
  Future<void> terminateThread() async {
    print("[CONTROLLER] Terminating worker thread.");
    await super.terminateThread();
    print("[CONTROLLER] Controller and worker have been terminated.");
  }
}

// The Worker, running in a separate isolate.
// It expects a `String` task and sends back a `String` result.
class TaskProcessorThread extends Thread<String, String> {
  @override
  void onMessageReceived(String task) async {
    print(
      "[WORKER] Task received on worker isolate: '$task'",
    );

    // Simulate some work
    await Future.delayed(const Duration(seconds: 1));

    final result = task.toUpperCase();
    print("[WORKER] Work complete. Sending result: '$result'");
    sendMessage(result);
  }

  @override
  Future<void> terminateThread() async {
    await super.terminateThread();
    // You can add any isolate-specific cleanup logic here.
    print("[WORKER] Worker isolate terminated.");
  }
}

void main() async {
  // 1. Create instances of the controller and the worker.
  final controller = TaskController();
  final worker = TaskProcessorThread();

  // 2. Initialize the controller with the worker to spawn the isolate.
  await controller.initializeThread(worker);

  // 3. Let the program run for a bit to exchange messages.
  await Future.delayed(const Duration(seconds: 3));

  // 4. Terminate the controller and the worker isolate.
  await controller.terminateThread();
}
