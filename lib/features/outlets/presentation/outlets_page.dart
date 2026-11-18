import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/localization/localization.dart';
import '../../../core/widgets/surface.dart';
import '../../../shared/data/workspace_providers.dart';
import '../../../shared/presentation/page_layout.dart';
import '../../../shared/presentation/storage_error_panel.dart';
import '../../../shared/application/overview_provider.dart';
import '../application/directory_providers.dart';
import 'directory_header.dart';
import 'directory_list.dart';
import 'outlet_editor.dart';

class OutletsPage extends ConsumerStatefulWidget {
  const OutletsPage({super.key});
  @override
  ConsumerState<OutletsPage> createState() => _OutletsPageState();
}

class _OutletsPageState extends ConsumerState<OutletsPage> {
  late final _search = TextEditingController(
    text: ref.read(directoryQueryProvider).search,
  );
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n, query = ref.watch(directoryQueryProvider);
    final controller = ref.read(directoryQueryProvider.notifier);
    final overview = ref.watch(overviewProvider),
        rows = ref.watch(directoryRowsProvider);
    Widget failure(Object error, StackTrace _) => StorageErrorPanel(
      heading: l.directoryUnavailable,
      error: error,
      onRetry: () {
        ref.invalidate(outletRepositoryProvider);
        ref.invalidate(overviewProvider);
        ref.invalidate(directoryRowsProvider);
      },
    );
    Widget loading() => Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: CircularProgressIndicator(semanticsLabel: l.loadingOutlets),
      ),
    );
    return WorkspacePage(
      eyebrow: l.directoryEyebrow,
      title: l.outletManagement,
      description: l.outletsDescription,
      trailing: FilledButton.icon(
        key: const ValueKey('add-outlet'),
        onPressed: overview.hasValue && !overview.hasError
            ? () => editOutlet(context)
            : null,
        icon: const Icon(Icons.add),
        label: Text(l.addOutlet),
      ),
      children: [
        overview.when(
          loading: loading,
          error: failure,
          data: (counts) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DirectoryCounts(counts),
              const SizedBox(height: 18),
              SurfacePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DirectoryControls(
                      search: _search,
                      onSearch: controller.search,
                      filter: query.filter,
                      onFilter: controller.filter,
                    ),
                    const Divider(height: 1),
                    rows.when(
                      loading: loading,
                      error: failure,
                      data: (list) => list.isEmpty
                          ? EmptyDirectory(
                              total: counts.totalOutlets,
                              query: query,
                            )
                          : DirectoryList(list),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
