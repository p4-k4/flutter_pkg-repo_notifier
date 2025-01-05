import 'package:flutter_test/flutter_test.dart';
import 'package:repo_notifier/repo_notifier.dart';

void main() {
  late TestRepo testRepo;

  setUp(() {
    testRepo = TestRepo();
  });

  test('initial state should be DataNull', () {
    expect(testRepo.currentState, isA<DataNull>());
  });

  group('CRUD operations', () {
    test('create should update state to DataLoaded', () async {
      final testData = TestModel(id: '1', value: 'test');
      await testRepo.create(testData);
      expect(testRepo.currentState, isA<DataLoaded<TestModel>>());
      expect((testRepo.currentState as DataLoaded).data.value, equals('test'));
    });

    test('read should return DataLoaded with correct data', () async {
      final result = await testRepo.read();
      expect(result, isA<DataLoaded<TestModel>>());
      expect((result as DataLoaded).data.value, equals('test value'));
    });

    test('update should modify existing data', () async {
      final testData = TestModel(id: '1', value: 'updated');
      await testRepo.update(testData);
      expect(testRepo.currentState, isA<DataLoaded<TestModel>>());
      expect(
          (testRepo.currentState as DataLoaded).data.value, equals('updated'));
    });

    test('delete should set state to DataNull', () async {
      await testRepo.delete();
      expect(testRepo.currentState, isA<DataNull>());
    });
  });

  group('match pattern', () {
    test('should handle all states correctly', () async {
      // Test DataNull
      var result = testRepo.match<String>(
        onData: (data) => 'data',
        onNull: () => 'null',
      );
      expect(result, equals('null'));

      // Test DataLoaded
      await testRepo.create(TestModel(id: '1', value: 'test'));
      result = testRepo.match<String>(
        onData: (data) => data.value,
        onNull: () => 'null',
      );
      expect(result, equals('test'));

      // Test DataLoading with previous data
      testRepo.read(); // Removed notify parameter
      result = testRepo.match<String>(
        onData: (data) => data.value,
        onWaiting: () => 'loading',
        onNull: () => 'null',
      );
      expect(result, equals('loading'));
    });
  });
}

class TestModel {
  final String id;
  final String value;

  TestModel({required this.id, required this.value});
}

class TestRepo extends RepoNotifier<TestModel, String> {
  @override
  Future<void> onCreate(TestModel data) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<TestModel> onRead([String? id]) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return TestModel(id: '1', value: 'test value');
  }

  @override
  Future<void> onUpdate(TestModel data) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> onDelete([String? id]) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
