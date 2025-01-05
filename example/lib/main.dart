import 'package:flutter/material.dart';
import 'package:repo_notifier/repo_notifier.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Home(),
      theme: ThemeData.dark(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Subscriber(
      (_) => Scaffold(
        appBar: AppBar(
          title: const Text('RepoNotifier Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: userDataRepo.match<Widget>(
                    onData: (d) => Text(
                      'Current User: ${d.name ?? 'No name'}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    onError: (error, _) => Text(
                      'Error: $error',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    onNull: () => Text(
                      'No user data',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => userDataRepo
                    .create(UserDataModel(id: '1', name: 'John Doe')),
                child: const Text('Create User'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => userDataRepo.read(),
                child: const Text('Fetch User'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => userDataRepo
                    .update(UserDataModel(id: '1', name: 'Updated User')),
                child: const Text('Update User'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => userDataRepo.delete(),
                child: const Text('Delete User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A model class representing user data.
class UserDataModel {
  UserDataModel({required this.id, this.name});
  final String id;
  String? name;

  UserDataModel copyWith({String? id, String? name}) {
    return UserDataModel(id: id ?? this.id, name: name ?? this.name);
  }
}

/// A repository for managing user data.
final userDataRepo = UserDataRepo();

class UserDataRepo extends RepoNotifier<UserDataModel, String> {
  @override
  Future<void> onCreate(UserDataModel data) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> onUpdate(UserDataModel data) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> onDelete([String? id]) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<UserDataModel> onRead([String? id]) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return UserDataModel(id: '1', name: 'John Doe');
  }
}
