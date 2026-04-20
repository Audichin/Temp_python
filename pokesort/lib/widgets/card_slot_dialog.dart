import 'package:flutter/material.dart';

import '../models/card_model.dart';
import '../utils/page_mapping.dart';

class CardSlotSelection {
  final int pageNumber;
  final int row;
  final int column;

  const CardSlotSelection({
    required this.pageNumber,
    required this.row,
    required this.column,
  });
}

class CardSlotDialog extends StatefulWidget {
  final String title;
  final String description;
  final CardModel card;
  final int binderSheetCount;
  final CardSlotSelection? initialSelection;
  final String? warningMessage;

  const CardSlotDialog({
    super.key,
    required this.title,
    required this.description,
    required this.card,
    required this.binderSheetCount,
    this.initialSelection,
    this.warningMessage,
  });

  @override
  State<CardSlotDialog> createState() => _CardSlotDialogState();
}

class _CardSlotDialogState extends State<CardSlotDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _sheetController;
  late final TextEditingController _rowController;
  late final TextEditingController _columnController;
  late BinderSide _selectedSide;

  @override
  void initState() {
    super.initState();
    final selection = widget.initialSelection;
    final initialPage = selection?.pageNumber ?? widget.card.pageNumber;

    _sheetController = TextEditingController(
      text: sheetFromVirtualPage(initialPage).toString(),
    );
    _rowController = TextEditingController(
      text: (selection?.row ?? widget.card.row).toString(),
    );
    _columnController = TextEditingController(
      text: (selection?.column ?? widget.card.column).toString(),
    );
    _selectedSide = sideFromVirtualPage(initialPage);
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _rowController.dispose();
    _columnController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final selection = CardSlotSelection(
      pageNumber: virtualPageFromSheet(
        sheetNumber: int.parse(_sheetController.text.trim()),
        side: _selectedSide,
      ),
      row: int.parse(_rowController.text.trim()),
      column: int.parse(_columnController.text.trim()),
    );

    Navigator.pop(context, selection);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.description),
              if (widget.warningMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.warningMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _sheetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'IRL Sheet (1-${widget.binderSheetCount})',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  final n = int.tryParse(value?.trim() ?? '');
                  if (n == null) return 'Enter a number';
                  if (n < 1 || n > widget.binderSheetCount) {
                    return 'Must be 1-${widget.binderSheetCount}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text('Side', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<BinderSide>(
                segments: const [
                  ButtonSegment(value: BinderSide.front, label: Text('Front')),
                  ButtonSegment(value: BinderSide.back, label: Text('Back')),
                ],
                selected: {_selectedSide},
                onSelectionChanged: (selection) {
                  setState(() {
                    _selectedSide = selection.first;
                  });
                },
                showSelectedIcon: false,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rowController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Row (1-3)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final n = int.tryParse(value?.trim() ?? '');
                        if (n == null) return 'Required';
                        if (n < 1 || n > 3) return '1-3 only';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _columnController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Column (1-3)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final n = int.tryParse(value?.trim() ?? '');
                        if (n == null) return 'Required';
                        if (n < 1 || n > 3) return '1-3 only';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Use This Spot'),
        ),
      ],
    );
  }
}
