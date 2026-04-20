import 'dart:io';

import 'package:flutter/material.dart';

import '../models/card_enums.dart';
import '../models/card_model.dart';
import '../services/binder_database.dart';

import '../utils/page_mapping.dart';

enum _EditConflictAction { cancel, swap }

class EditCardPage extends StatefulWidget {
  final CardModel card;
  final int binderSheetCount;

  const EditCardPage({
    super.key,
    required this.card,
    required this.binderSheetCount,
  });

  @override
  State<EditCardPage> createState() => _EditCardPageState();
}

class _EditCardPageState extends State<EditCardPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _sheetController;
  late BinderSide _selectedSide;
  late final TextEditingController _rowController;
  late final TextEditingController _columnController;
  late final TextEditingController _customPokemonVariantController;

  late CardCategory _selectedCategory;
  late CardLanguage _selectedLanguage;
  late CardRarity _selectedRarity;

  late CardType _selectedType;
  late CardStage _selectedStage;
  late PokemonVariant _selectedPokemonVariant;

  late TrainerVariant _selectedTrainerVariant;

  late ItemStadiumKind _selectedItemStadiumKind;
  late ItemStadiumVariant _selectedItemStadiumVariant;

  late bool _legendary;
  late bool _forSale;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final card = widget.card;

    _nameController = TextEditingController(text: card.name);
    _priceController = TextEditingController(
      text: card.price?.toString() ?? '',
    );
    _sheetController = TextEditingController(
      text: sheetFromVirtualPage(card.pageNumber).toString(),
    );
    _selectedSide = sideFromVirtualPage(card.pageNumber);
    _rowController = TextEditingController(text: card.row.toString());
    _columnController = TextEditingController(text: card.column.toString());
    _customPokemonVariantController = TextEditingController(
      text: card.customPokemonVariant ?? '',
    );

    _selectedCategory = card.category;
    _selectedLanguage = card.cardLanguage;
    _selectedRarity = card.rarity;

    _selectedType = card.type ?? CardType.grass;
    _selectedStage = card.stage ?? CardStage.basic;
    _selectedPokemonVariant =
        card.pokemonVariant ?? PokemonVariant.defaultVariant;

    _selectedTrainerVariant = card.trainerVariant ?? TrainerVariant.normal;

    _selectedItemStadiumKind = card.itemStadiumKind ?? ItemStadiumKind.item;
    _selectedItemStadiumVariant =
        card.itemStadiumVariant ?? ItemStadiumVariant.normal;

    _legendary = card.legendary ?? false;
    _forSale = card.forSale;
  }

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

  CardModel _buildUpdatedCard({
    required int pageNumber,
    required int row,
    required int column,
  }) {
    final price = (_forSale && _priceController.text.trim().isNotEmpty)
        ? double.tryParse(_priceController.text.trim())
        : null;

    return CardModel(
      id: widget.card.id,
      binderId: widget.card.binderId,
      name: _nameController.text.trim(),
      imagePath: widget.card.imagePath,
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

  Future<_EditConflictAction?> _promptEditConflict(CardModel conflictingCard) {
    return showDialog<_EditConflictAction>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Spot Already Taken'),
          content: Text(
            '"${conflictingCard.name}" is already in that page and slot. '
            'Would you like to swap spots or cancel?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, _EditConflictAction.cancel),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, _EditConflictAction.swap),
              child: const Text('Swap Spots'),
            ),
          ],
        );
      },
    );
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
    final updatedCard = _buildUpdatedCard(
      pageNumber: pageNumber,
      row: row,
      column: column,
    );

    setState(() => _saving = true);

    final conflictingCard = await BinderDatabase.instance.getCardBySlot(
      binderId: widget.card.binderId,
      pageNumber: pageNumber,
      row: row,
      column: column,
      excludeCardId: widget.card.id,
    );

    if (conflictingCard != null) {
      final action = await _promptEditConflict(conflictingCard);
      if (!mounted) return;
      switch (action ?? _EditConflictAction.cancel) {
        case _EditConflictAction.cancel:
          setState(() => _saving = false);
          return;
        case _EditConflictAction.swap:
          await BinderDatabase.instance.updateCardWithSwap(
            originalCard: widget.card,
            updatedCard: updatedCard,
            conflictingCard: conflictingCard,
          );
          if (!mounted) return;
          Navigator.pop(context, pageNumber);
          return;
      }
    }

    await BinderDatabase.instance.updateCard(updatedCard);

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
      appBar: AppBar(title: const Text('Edit Card')),
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
                      File(widget.card.imagePath),
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
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
    );
  }
}
