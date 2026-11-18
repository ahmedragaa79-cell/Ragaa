import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/workspace_providers.dart';
import '../domain/workspace_reader.dart';

final overviewProvider = StreamProvider<WorkspaceOverview>((ref) async* {
  final reader = await ref.watch(workspaceReaderProvider);
  yield* reader.watchOverview();
}, retry: (count, error) => null);
