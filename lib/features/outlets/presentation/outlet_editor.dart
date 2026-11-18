import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/localization/localization.dart';
import '../../../shared/data/workspace_providers.dart';
import '../../../shared/domain/outlet.dart';
import '../domain/outlet_repository.dart';

Future<void> editOutlet(BuildContext context, [Outlet? outlet]) async {
  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _OutletEditor(outlet),
  );
  if (saved == true && context.mounted) {
    final l = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(outlet == null ? l.outletAdded : l.outletEdited)),
    );
  }
}

class _OutletEditor extends ConsumerStatefulWidget {
  const _OutletEditor(this.outlet);
  final Outlet? outlet;
  @override
  ConsumerState<_OutletEditor> createState() => _OutletEditorState();
}

class _OutletEditorState extends ConsumerState<_OutletEditor> {
  late final _code = TextEditingController(text: widget.outlet?.outletCode);
  late final _name = TextEditingController(text: widget.outlet?.name);
  late final _description = TextEditingController(
    text: widget.outlet?.description,
  );
  bool _submitted = false, _busy = false, _writeFailed = false;
  OutletProblem? _problem;

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() {
      _submitted = true;
      _problem = null;
      _writeFailed = false;
    });
    if (_code.text.trim().isEmpty || _name.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      final details = OutletDetails(
        outletCode: _code.text,
        name: _name.text,
        description: _description.text,
      );
      final repo = await ref.read(outletRepositoryProvider.future);
      final outlet = widget.outlet;
      if (outlet == null) {
        await repo.create(details);
      } else {
        await repo.edit(outlet.id, details);
      }
      if (mounted) Navigator.pop(context, true);
    } on OutletProblem catch (error) {
      if (mounted) setState(() => _problem = error);
    } catch (_) {
      if (mounted) setState(() => _writeFailed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final codeError = _submitted && _code.text.trim().isEmpty
        ? l.requiredCode
        : _problem == OutletProblem.duplicateCode
        ? l.duplicateCode
        : null;
    final nameError = _submitted && _name.text.trim().isEmpty
        ? l.requiredName
        : null;
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        scrollable: true,
        title: Text(widget.outlet == null ? l.addOutlet : l.editOutlet),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 14,
            children: [
              TextField(
                key: const ValueKey('outlet-code'),
                autofocus: true,
                enabled: !_busy,
                controller: _code,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() => _problem = null),
                decoration: InputDecoration(
                  labelText: l.outletCode,
                  errorText: codeError,
                  errorMaxLines: 3,
                  border: const OutlineInputBorder(),
                ),
              ),
              TextField(
                key: const ValueKey('outlet-name'),
                controller: _name,
                enabled: !_busy,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l.outletName,
                  errorText: nameError,
                  border: const OutlineInputBorder(),
                ),
              ),
              TextField(
                key: const ValueKey('outlet-description'),
                controller: _description,
                enabled: !_busy,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l.optionalDescription,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_writeFailed || _problem == OutletProblem.notFound)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _problem == OutletProblem.notFound
                        ? l.outletNotFound
                        : l.outletWriteFailed,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.pop(context),
            child: Text(l.cancelAction),
          ),
          FilledButton(
            key: const ValueKey('save-outlet'),
            onPressed: _busy ? null : _save,
            child: Text(_busy ? l.savingOutlet : l.saveOutlet),
          ),
        ],
      ),
    );
  }
}
