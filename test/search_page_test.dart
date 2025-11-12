import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:schedules_flutter/presentation/pages/search_page.dart';

void main() {
  group('SearchCubit history management', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('clearHistory empties state and persistent storage', () async {
      // seed history
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('search_history', ['Alice', 'Bob']);

      final cubit = SearchCubit();
      // ensure initial load
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(cubit.state.history, ['Alice', 'Bob']);

      await cubit.clearHistory();

      expect(cubit.state.history, isEmpty);
      expect(prefs.getStringList('search_history') ?? [], isEmpty);
    });

    test('removeHistoryItem removes only the specified item', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('search_history', ['Alice', 'Bob', 'Charlie']);

      final cubit = SearchCubit();
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(cubit.state.history, ['Alice', 'Bob', 'Charlie']);

      await cubit.removeHistoryItem('Bob');

      expect(cubit.state.history, ['Alice', 'Charlie']);
      expect(prefs.getStringList('search_history'), ['Alice', 'Charlie']);
    });
  });
}
