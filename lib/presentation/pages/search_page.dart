import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/supabase/supabase_service.dart';
import '../../l10n/generated/app_localizations.dart';

enum SearchFilter { teachers, classrooms, subjects, schedules }

class SearchResult {
  final SearchFilter type;
  final String id;
  final String title;
  final String? subtitle;

  SearchResult({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
  });
}

class SearchState {
  final String query;
  final Set<SearchFilter> activeFilters;
  final bool loading;
  final String? error;
  final List<SearchResult> results;
  final List<String> history;
  final int focusedIndex;

  const SearchState({
    this.query = '',
    this.activeFilters = const {
      SearchFilter.teachers,
      SearchFilter.classrooms,
      SearchFilter.subjects,
      SearchFilter.schedules,
    },
    this.loading = false,
    this.error,
    this.results = const [],
    this.history = const [],
    this.focusedIndex = -1,
  });

  SearchState copyWith({
    String? query,
    Set<SearchFilter>? activeFilters,
    bool? loading,
    String? error,
    List<SearchResult>? results,
    List<String>? history,
    int? focusedIndex,
  }) {
    return SearchState(
      query: query ?? this.query,
      activeFilters: activeFilters ?? this.activeFilters,
      loading: loading ?? this.loading,
      error: error,
      results: results ?? this.results,
      history: history ?? this.history,
      focusedIndex: focusedIndex ?? this.focusedIndex,
    );
  }
}

class SearchCubit extends Cubit<SearchState> {
  SupabaseClient? _client;
  SupabaseClient get client => _client ??= SupabaseService().client;
  Timer? _debounce;
  static const _debounceMs = 300;
  static const _historyKey = 'search_history';

  SearchCubit() : super(const SearchState()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_historyKey) ?? [];
      emit(state.copyWith(history: list));
    } catch (_) {}
  }

  Future<void> _saveHistory(String q) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = [
        q,
        ...state.history.where((e) => e != q),
      ].take(10).toList();
      await prefs.setStringList(_historyKey, history);
      emit(state.copyWith(history: history));
    } catch (_) {}
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      emit(state.copyWith(history: const []));
    } catch (_) {}
  }

  Future<void> removeHistoryItem(String item) async {
    try {
      final updated = state.history.where((e) => e != item).toList();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyKey, updated);
      emit(state.copyWith(history: updated));
    } catch (_) {}
  }

  void setQuery(String q) {
    emit(state.copyWith(query: q, error: null));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: _debounceMs), () {
      _performSearch();
    });
  }

  void toggleFilter(SearchFilter f) {
    final set = Set<SearchFilter>.from(state.activeFilters);
    if (set.contains(f)) {
      set.remove(f);
    } else {
      set.add(f);
    }
    emit(state.copyWith(activeFilters: set));
    _performSearch();
  }

  void clearQuery() {
    emit(state.copyWith(query: '', results: [], error: null));
  }

  void moveFocus(int delta) {
    if (state.results.isEmpty) return;
    var idx = state.focusedIndex + delta;
    if (idx < 0) idx = 0;
    if (idx >= state.results.length) idx = state.results.length - 1;
    emit(state.copyWith(focusedIndex: idx));
  }

  Future<void> _performSearch() async {
    final q = state.query.trim();
    if (q.isEmpty) {
      emit(state.copyWith(results: [], loading: false, error: null));
      return;
    }

    emit(state.copyWith(loading: true, error: null));
    try {
      final like = '%$q%';
      final List<SearchResult> out = [];
      final filters = state.activeFilters;
      final futures = <Future<void>>[];

      if (filters.contains(SearchFilter.teachers)) {
        futures.add(
          client.from('teachers').select().ilike('name', like).then((res) {
            for (final m in (res as List)) {
              out.add(
                SearchResult(
                  type: SearchFilter.teachers,
                  id: m['id'].toString(),
                  title: m['name'] ?? '',
                ),
              );
            }
          }),
        );
      }

      if (filters.contains(SearchFilter.classrooms)) {
        futures.add(
          client.from('classrooms').select().ilike('name', like).then((res) {
            for (final m in (res as List)) {
              out.add(
                SearchResult(
                  type: SearchFilter.classrooms,
                  id: m['id'].toString(),
                  title: m['name'] ?? '',
                ),
              );
            }
          }),
        );
      }

      if (filters.contains(SearchFilter.subjects)) {
        futures.add(
          client.from('subjects').select().ilike('name', like).then((res) {
            for (final m in (res as List)) {
              out.add(
                SearchResult(
                  type: SearchFilter.subjects,
                  id: m['id'].toString(),
                  title: m['name'] ?? '',
                ),
              );
            }
          }),
        );
      }

      if (filters.contains(SearchFilter.schedules)) {
        futures.add(
          client.from('schedules').select().ilike('notes', like).then((res) {
            for (final m in (res as List)) {
              out.add(
                SearchResult(
                  type: SearchFilter.schedules,
                  id: m['id'].toString(),
                  title: 'Schedule ${(m['date'] ?? '').toString()}',
                  subtitle: (m['notes'] ?? '').toString().isEmpty
                      ? null
                      : (m['notes'] ?? '').toString(),
                ),
              );
            }
          }),
        );
      }

      await Future.wait(futures);
      _saveHistory(q);
      emit(
        state.copyWith(
          results: out,
          loading: false,
          focusedIndex: out.isNotEmpty ? 0 : -1,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => SearchCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
          actions: [
            TextButton(
              onPressed: () {
                _controller.clear();
                context.read<SearchCubit>().clearQuery();
                _focusNode.requestFocus();
              },
              child: const Text('Clear'),
            ),
          ],
        ),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: state.query.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _controller.clear();
                                context.read<SearchCubit>().clearQuery();
                                _focusNode.requestFocus();
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                      hintText:
                          'Search teachers, classrooms, subjects, schedules',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    onChanged: (v) => context.read<SearchCubit>().setQuery(v),
                    textInputAction: TextInputAction.search,
                    autofocus: true,
                  ),
                ),
                _FiltersRow(),
                const SizedBox(height: 6),
                Expanded(child: _ResultsList(isDark: isDark)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FiltersRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cubit = context.read<SearchCubit>();

    Widget buildChip(SearchFilter f, IconData icon, String label) {
      return BlocBuilder<SearchCubit, SearchState>(
        builder: (context, s) {
          final active = s.activeFilters.contains(f);
          return FilterChip(
            label: Text(label),
            selected: active,
            onSelected: (_) => cubit.toggleFilter(f),
            selectedColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.2),
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Wrap(
        spacing: 8,
        children: [
          buildChip(SearchFilter.teachers, Icons.person_outline, t.teachers),
          buildChip(
            SearchFilter.classrooms,
            Icons.meeting_room_outlined,
            t.classrooms,
          ),
          buildChip(
            SearchFilter.subjects,
            Icons.menu_book_outlined,
            t.subjects,
          ),
          buildChip(SearchFilter.schedules, Icons.event_outlined, t.schedules),
        ],
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final bool isDark;
  const _ResultsList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, s) {
        if (s.error != null) {
          return Center(
            child: Text(
              'Error: ${s.error}',
              style: TextStyle(color: Colors.red.shade700),
            ),
          );
        }
        if (s.loading) return const Center(child: CircularProgressIndicator());
        if (s.query.isEmpty) return _HistoryView(history: s.history);
        if (s.results.isEmpty)
          return const Center(child: Text('No results found'));

        return ListView.builder(
          itemCount: s.results.length,
          itemBuilder: (context, index) {
            final r = s.results[index];
            final selected = index == s.focusedIndex;
            return ListTile(
              leading: Icon(_iconFor(r.type)),
              title: Text(r.title),
              subtitle: r.subtitle != null ? Text(r.subtitle!) : null,
              selected: selected,
              onTap: () => _navigateToResult(context, r),
            );
          },
        );
      },
    );
  }

  IconData _iconFor(SearchFilter f) {
    switch (f) {
      case SearchFilter.teachers:
        return Icons.person_outline;
      case SearchFilter.classrooms:
        return Icons.meeting_room_outlined;
      case SearchFilter.subjects:
        return Icons.menu_book_outlined;
      case SearchFilter.schedules:
        return Icons.event_outlined;
    }
  }

  void _navigateToResult(BuildContext context, SearchResult r) {
    final search = context.read<SearchCubit>().state.query;
    String path;
    switch (r.type) {
      case SearchFilter.teachers:
        path = '/teachers';
        break;
      case SearchFilter.classrooms:
        path = '/classrooms';
        break;
      case SearchFilter.subjects:
        path = '/subjects';
        break;
      case SearchFilter.schedules:
        path = '/schedules';
        break;
    }
    final uri = Uri(
      path: path,
      queryParameters: {
        'search': search,
        'id': r.id,
        'type': r.type.name,
        'title': r.title,
      },
    );
    context.push(uri.toString());
  }
}

class _HistoryView extends StatelessWidget {
  final List<String> history;
  const _HistoryView({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(child: Text('Start typing to search'));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Semantics(
              button: true,
              label: 'Clear all search history',
              hint: 'Opens a confirmation to clear history',
              child: FilledButton(
                onPressed: () async {
                  final confirm =
                      await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Clear All'),
                          content: const Text(
                            'Do you want to permanently clear search history?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                  if (confirm) {
                    await context.read<SearchCubit>().clearHistory();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('History cleared')),
                      );
                    }
                  }
                },
                child: const Text('Clear All'),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (_, i) {
              final q = history[i];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(q),
                onTap: () => context.read<SearchCubit>().setQuery(q),
                trailing: IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      context.read<SearchCubit>().removeHistoryItem(q),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
