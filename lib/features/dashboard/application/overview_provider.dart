import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/empty_workspace_reader.dart';
import '../../../shared/domain/workspace_reader.dart';

final overviewProvider = FutureProvider<WorkspaceOverview>(
  (ref) => ref.watch(workspaceReaderProvider).overview(),
  retry: (retryCount, error) => null,
);
