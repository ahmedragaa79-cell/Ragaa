import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/workspace_providers.dart';
import '../../../shared/domain/outlet.dart';
import '../domain/outlet_repository.dart';

/// Session state, intentionally independent of locale, theme and route rebuilds.
class DirectoryController extends Notifier<DirectoryQuery> {
  @override
  DirectoryQuery build() => (search: '', filter: OutletFilter.all);
  void search(String value) => state = (search: value, filter: state.filter);
  void filter(OutletFilter value) =>
      state = (search: state.search, filter: value);
}

final directoryQueryProvider =
    NotifierProvider<DirectoryController, DirectoryQuery>(
      DirectoryController.new,
    );
final directoryRowsProvider = StreamProvider.autoDispose<List<Outlet>>((
  ref,
) async* {
  final query = ref.watch(directoryQueryProvider);
  final repo = await ref.watch(outletRepositoryProvider.future);
  yield* repo.watchDirectory(query);
}, retry: (count, error) => null);
