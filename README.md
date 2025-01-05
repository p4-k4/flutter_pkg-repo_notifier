# repo_notifier

A Flutter package providing a simple and efficient way to manage repository state with built-in CRUD operations and state management.

## Features

- Built-in state management for repository operations
- Type-safe state handling with pattern matching
- Automatic state updates and UI rebuilding
- Support for CRUD operations with loading states
- Easy integration with Flutter widgets
- Optimistic updates with previous state handling
- Error handling with stack trace support

## Getting started

Add `repo_notifier` to your `pubspec.yaml`:

```yaml
dependencies:
  repo_notifier: ^0.0.1
```

## Usage

### 1. Create a Data Model

```dart
class UserDataModel {
  UserDataModel({required this.id, this.name});
  final String id;
  String? name;

  UserDataModel copyWith({String? id, String? name}) {
    return UserDataModel(id: id ?? this.id, name: name ?? this.name);
  }
}
```

### 2. Create a Repository

Extend `RepoNotifier` with your model type and ID type:

```dart
class UserDataRepo extends RepoNotifier<UserDataModel, String> {
  @override
  Future<void> onCreate(UserDataModel data) async {
    // Implement creation logic
    await api.createUser(data);
  }

  @override
  Future<void> onUpdate(UserDataModel data) async {
    // Implement update logic
    await api.updateUser(data);
  }

  @override
  Future<void> onDelete([String? id]) async {
    // Implement deletion logic
    await api.deleteUser(id);
  }

  @override
  Future<UserDataModel> onRead([String? id]) async {
    // Implement read logic
    return await api.getUser(id);
  }
}
```

### 3. Use in Widgets

Wrap your widget tree with `Subscriber` and use pattern matching to handle different states:

```dart
class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Subscriber(
      (_) => Scaffold(
        body: userDataRepo.match<Widget>(
          onData: (data) => Text(data.name ?? ''),
          onWaiting: () => CircularProgressIndicator(),
          onError: (error, stack) => Text('Error: $error'),
          onNull: () => Text('No data'),
        ),
      ),
    );
  }
}
```

### 4. Perform CRUD Operations

```dart
// Create
userDataRepo.create(UserDataModel(id: '1', name: 'John'));

// Read
userDataRepo.read('1');

// Update
userDataRepo.update(UserDataModel(id: '1', name: 'Updated Name'));

// Delete
userDataRepo.delete('1');
```

## Additional Features

### State Pattern Matching

The `match` method provides type-safe pattern matching for handling different repository states:

```dart
userDataRepo.match<Widget>(
  onData: (data) => Text(data.name ?? ''),
  onWaiting: () => CircularProgressIndicator(),
  onError: (error, stack) => Text('Error: $error'),
  onNull: () => Text('No data'),
);
```

### Optimistic Updates

The package maintains the previous state during operations, allowing for optimistic UI updates:

```dart
// During loading, the previous data is still accessible
userDataRepo.match<Widget>(
  onData: (data) => Text(data.name ?? ''),
  onWaiting: () => Text('Loading...'),
  onNull: () => Text('No data'),
);
```

## Example

Check out the [example](example) directory for a complete working demo.

## Author

Paurini Taketakehikuroa Wiringi

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
