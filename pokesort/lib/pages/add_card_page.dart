import 'dart:io';

import 'package:flutter/material.dart';

import '../models/card_enums.dart';
import '../models/card_model.dart';
import '../services/binder_database.dart';
import '../widgets/card_slot_dialog.dart';

import '../utils/page_mapping.dart';

class AddCardPage extends StatefulWidget {
  final int binderId;
  final int binderSheetCount;
  final String imagePath;

  const AddCardPage({
    super.key,
    required this.binderId,
    required this.binderSheetCount,
    required this.imagePath,
  });

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _sheetController = TextEditingController(text: '1');
  BinderSide _selectedSide = BinderSide.front;
  final _rowController = TextEditingController(text: '1');
  final _columnController = TextEditingController(text: '1');
  final _customPokemonVariantController = TextEditingController();

  CardCategory _selectedCategory = CardCategory.pokemon;
  CardLanguage _selectedLanguage = CardLanguage.english;
  CardRarity _selectedRarity = CardRarity.common;

  CardType _selectedType = CardType.grass;
  CardStage _selectedStage = CardStage.basic;
  PokemonVariant _selectedPokemonVariant = PokemonVariant.defaultVariant;

  TrainerVariant _selectedTrainerVariant = TrainerVariant.normal;

  ItemStadiumKind _selectedItemStadiumKind = ItemStadiumKind.item;
  ItemStadiumVariant _selectedItemStadiumVariant = ItemStadiumVariant.normal;

  bool _legendary = false;
  bool _forSale = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _sheetController.dispose();
    _rowController.dispose();
    _columnController.dispose();
    _customPokemonVariantController.dispose();
    super.dispose();
  }

  DropdownButtonFormField<T> _enumDropdown<T>({
    required String label,
    required T initialValue,
    required List<T> values,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: values
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(labelBuilder(item)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  void _onCategoryChanged(CardCategory newCategory) {
    setState(() {
      _selectedCategory = newCategory;

      _selectedType = CardType.grass;
      _selectedStage = CardStage.basic;
      _selectedPokemonVariant = PokemonVariant.defaultVariant;
      _selectedTrainerVariant = TrainerVariant.normal;
      _selectedItemStadiumKind = ItemStadiumKind.item;
      _selectedItemStadiumVariant = ItemStadiumVariant.normal;
      _legendary = false;
      _customPokemonVariantController.clear();
    });
  }

  CardModel _buildDraftCard({
    required int pageNumber,
    required int row,
    required int column,
  }) {
    final price = (_forSale && _priceController.text.trim().isNotEmpty)
        ? double.tryParse(_priceController.text.trim())
        : null;

    return CardModel(
      binderId: widget.binderId,
      name: _nameController.text.trim(),
      imagePath: widget.imagePath,
      category: _selectedCategory,
      cardLanguage: _selectedLanguage,
      rarity: _selectedRarity,
      type:
          (_selectedCategory == CardCategory.pokemon ||
              _selectedCategory == CardCategory.energy)
          ? _selectedType
          : null,
      stage: _selectedCategory == CardCategory.pokemon ? _selectedStage : null,
      pokemonVariant: _selectedCategory == CardCategory.pokemon
          ? _selectedPokemonVariant
          : null,
      customPokemonVariant:
          _selectedCategory == CardCategory.pokemon &&
              _selectedPokemonVariant == PokemonVariant.notInList
          ? _customPokemonVariantController.text.trim()
          : null,
      trainerVariant: _selectedCategory == CardCategory.trainer
          ? _selectedTrainerVariant
          : null,
      itemStadiumKind: _selectedCategory == CardCategory.itemOrStadium
          ? _selectedItemStadiumKind
          : null,
      itemStadiumVariant:
          _selectedCategory == CardCategory.itemOrStadium &&
              _selectedItemStadiumKind == ItemStadiumKind.item
          ? _selectedItemStadiumVariant
          : null,
      legendary: _selectedCategory == CardCategory.pokemon ? _legendary : null,
      forSale: _forSale,
      price: price,
      pageNumber: pageNumber,
      row: row,
      column: column,
    );
  }

  Future<bool> _moveExistingCardElseCancel(CardModel conflictingCard) async {
    final shouldMove = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Spot Already Taken'),
          content: Text(
            '"${conflictingCard.name}" is already in that page and slot. '
            'Would you like to move it to a new page and slot?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Move Current Card'),
            ),
          ],
        );
      },
    );

    if (shouldMove != true) return false;

    CardSlotSelection? selection;
    String? warningMessage;

    while (true) {
      if (!mounted) return false;

      selection = await showDialog<CardSlotSelection>(
        context: context,
        builder: (_) => CardSlotDialog(
          title: 'Move Current Card',
          description:
              'Choose a new page and slot for ${conflictingCard.name}.',
          card: conflictingCard,
          binderSheetCount: widget.binderSheetCount,
          initialSelection: selection,
          warningMessage: warningMessage,
        ),
      );

      if (selection == null) return false;

      if (selection.pageNumber == conflictingCard.pageNumber &&
          selection.row == conflictingCard.row &&
          selection.column == conflictingCard.column) {
        warningMessage =
            'Choose a different page and slot for the current card.';
        continue;
      }

      final occupant = await BinderDatabase.instance.getCardBySlot(
        binderId: conflictingCard.binderId,
        pageNumber: selection.pageNumber,
        row: selection.row,
        column: selection.column,
        excludeCardId: conflictingCard.id,
      );

      if (occupant == null) {
        await BinderDatabase.instance.moveCardToSlot(
          cardId: conflictingCard.id!,
          pageNumber: selection.pageNumber,
          row: selection.row,
          column: selection.column,
        );
        return true;
      }

      if (!mounted) return false;
      warningMessage =
          '"${occupant.name}" is already in that spot. Choose another one.';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final sheetNumber = int.parse(_sheetController.text.trim());
    final pageNumber = virtualPageFromSheet(
      sheetNumber: sheetNumber,
      side: _selectedSide,
    );
    final row = int.parse(_rowController.text.trim());
    final column = int.parse(_columnController.text.trim());
    final card = _buildDraftCard(
      pageNumber: pageNumber,
      row: row,
      column: column,
    );

    setState(() => _saving = true);

    final conflictingCard = await BinderDatabase.instance.getCardBySlot(
      binderId: widget.binderId,
      pageNumber: pageNumber,
      row: row,
      column: column,
    );

    if (conflictingCard != null) {
      final resolved = await _moveExistingCardElseCancel(conflictingCard);
      if (!mounted) return;
      if (!resolved) {
        setState(() => _saving = false);
        return;
      }
    }

    await BinderDatabase.instance.insertCard(card);

    if (!mounted) return;
    Navigator.pop(context, pageNumber);
  }

  Widget _buildCategoryChooser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Card Category', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<CardCategory>(
          segments: const [
            ButtonSegment(value: CardCategory.pokemon, label: Text('Pokémon')),
            ButtonSegment(value: CardCategory.trainer, label: Text('Trainer')),
            ButtonSegment(
              value: CardCategory.itemOrStadium,
              label: Text('Item/Stadium'),
            ),
            ButtonSegment(value: CardCategory.energy, label: Text('Energy')),
          ],
          selected: {_selectedCategory},
          onSelectionChanged: (selection) {
            _onCategoryChanged(selection.first);
          },
          showSelectedIcon: false,
        ),
      ],
    );
  }

  List<Widget> _buildConditionalFields() {
    switch (_selectedCategory) {
      case CardCategory.pokemon:
        return [
          _enumDropdown<CardType>(
            label: 'Type',
            initialValue: _selectedType,
            values: CardType.values,
            labelBuilder: cardTypeToString,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedType = value);
              }
            },
          ),
          const SizedBox(height: 16),
          _enumDropdown<CardStage>(
            label: 'Stage',
            initialValue: _selectedStage,
            values: CardStage.values,
            labelBuilder: stageToString,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedStage = value);
              }
            },
          ),
          const SizedBox(height: 16),
          _enumDropdown<PokemonVariant>(
            label: 'Variant',
            initialValue: _selectedPokemonVariant,
            values: PokemonVariant.values,
            labelBuilder: pokemonVariantToString,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedPokemonVariant = value);
              }
            },
          ),
          if (_selectedPokemonVariant == PokemonVariant.notInList) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _customPokemonVariantController,
              decoration: const InputDecoration(
                labelText: 'Custom Variant',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (_selectedPokemonVariant == PokemonVariant.notInList &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Enter the custom variant name';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 8),
          SwitchListTile(
            value: _legendary,
            onChanged: (value) => setState(() => _legendary = value),
            title: const Text('Legendary'),
          ),
        ];

      case CardCategory.trainer:
        return [
          _enumDropdown<TrainerVariant>(
            label: 'Variant',
            initialValue: _selectedTrainerVariant,
            values: TrainerVariant.values,
            labelBuilder: trainerVariantToString,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedTrainerVariant = value);
              }
            },
          ),
        ];

      case CardCategory.itemOrStadium:
        return [
          _enumDropdown<ItemStadiumKind>(
            label: 'Item or Stadium',
            initialValue: _selectedItemStadiumKind,
            values: ItemStadiumKind.values,
            labelBuilder: itemStadiumKindToString,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedItemStadiumKind = value);
              }
            },
          ),
          if (_selectedItemStadiumKind == ItemStadiumKind.item) ...[
            const SizedBox(height: 16),
            _enumDropdown<ItemStadiumVariant>(
              label: 'Variant',
              initialValue: _selectedItemStadiumVariant,
              values: ItemStadiumVariant.values,
              labelBuilder: itemStadiumVariantToString,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedItemStadiumVariant = value);
                }
              },
            ),
          ],
        ];

      case CardCategory.energy:
        return [
          _enumDropdown<CardType>(
            label: 'Type',
            initialValue: _selectedType,
            values: CardType.values,
            labelBuilder: cardTypeToString,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedType = value);
              }
            },
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Card')),
      body: _saving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(widget.imagePath),
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildCategoryChooser(),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Card Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _enumDropdown<CardLanguage>(
                    label: 'Language',
                    initialValue: _selectedLanguage,
                    values: CardLanguage.values,
                    labelBuilder: languageToString,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedLanguage = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  _enumDropdown<CardRarity>(
                    label: 'Rarity',
                    initialValue: _selectedRarity,
                    values: CardRarity.values,
                    labelBuilder: rarityToString,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedRarity = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  ..._buildConditionalFields(),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Side',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<BinderSide>(
                        segments: const [
                          ButtonSegment(
                            value: BinderSide.front,
                            label: Text('Front'),
                          ),
                          ButtonSegment(
                            value: BinderSide.back,
                            label: Text('Back'),
                          ),
                        ],
                        selected: {_selectedSide},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _selectedSide = selection.first;
                          });
                        },
                        showSelectedIcon: false,
                      ),
                    ],
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

                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _forSale,
                    onChanged: (value) => setState(() => _forSale = value),
                    title: const Text('For Sale'),
                  ),

                  if (_forSale) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      validator: (value) {
                        if (!_forSale) return null;
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('Save Card'),
                  ),
                ],
              ),
            ),
    );
  }
}
