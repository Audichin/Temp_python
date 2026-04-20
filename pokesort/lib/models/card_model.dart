import 'card_enums.dart';

class CardModel {
  final int? id;
  final int binderId;
  final String name;
  final String imagePath;

  final CardCategory category;
  final CardLanguage cardLanguage;
  final CardRarity rarity;

  final CardType? type;
  final CardStage? stage;

  final PokemonVariant? pokemonVariant;
  final String? customPokemonVariant;

  final TrainerVariant? trainerVariant;

  final ItemStadiumKind? itemStadiumKind;
  final ItemStadiumVariant? itemStadiumVariant;

  final bool? legendary;

  final bool forSale;
  final double? price;

  final int pageNumber;
  final int row;
  final int column;

  CardModel({
    this.id,
    required this.binderId,
    required this.name,
    required this.imagePath,
    required this.category,
    required this.cardLanguage,
    required this.rarity,
    this.type,
    this.stage,
    this.pokemonVariant,
    this.customPokemonVariant,
    this.trainerVariant,
    this.itemStadiumKind,
    this.itemStadiumVariant,
    this.legendary,
    required this.forSale,
    this.price,
    required this.pageNumber,
    required this.row,
    required this.column,
  });

  CardModel copyWith({
    int? id,
    int? binderId,
    String? name,
    String? imagePath,
    CardCategory? category,
    CardLanguage? cardLanguage,
    CardRarity? rarity,
    CardType? type,
    CardStage? stage,
    PokemonVariant? pokemonVariant,
    String? customPokemonVariant,
    TrainerVariant? trainerVariant,
    ItemStadiumKind? itemStadiumKind,
    ItemStadiumVariant? itemStadiumVariant,
    bool? legendary,
    bool? forSale,
    double? price,
    int? pageNumber,
    int? row,
    int? column,
  }) {
    return CardModel(
      id: id ?? this.id,
      binderId: binderId ?? this.binderId,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      cardLanguage: cardLanguage ?? this.cardLanguage,
      rarity: rarity ?? this.rarity,
      type: type ?? this.type,
      stage: stage ?? this.stage,
      pokemonVariant: pokemonVariant ?? this.pokemonVariant,
      customPokemonVariant:
          customPokemonVariant ?? this.customPokemonVariant,
      trainerVariant: trainerVariant ?? this.trainerVariant,
      itemStadiumKind: itemStadiumKind ?? this.itemStadiumKind,
      itemStadiumVariant: itemStadiumVariant ?? this.itemStadiumVariant,
      legendary: legendary ?? this.legendary,
      forSale: forSale ?? this.forSale,
      price: price ?? this.price,
      pageNumber: pageNumber ?? this.pageNumber,
      row: row ?? this.row,
      column: column ?? this.column,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'binderId': binderId,
      'name': name,
      'imagePath': imagePath,
      'category': category.index,
      'cardLanguage': cardLanguage.index,
      'rarity': rarity.index,
      'type': type?.index,
      'stage': stage?.index,
      'pokemonVariant': pokemonVariant?.index,
      'customPokemonVariant': customPokemonVariant,
      'trainerVariant': trainerVariant?.index,
      'itemStadiumKind': itemStadiumKind?.index,
      'itemStadiumVariant': itemStadiumVariant?.index,
      'legendary': legendary == null ? null : (legendary! ? 1 : 0),
      'forSale': forSale ? 1 : 0,
      'price': price,
      'pageNumber': pageNumber,
      'row': row,
      'column': column,
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'] as int?,
      binderId: map['binderId'] as int,
      name: map['name'] as String,
      imagePath: map['imagePath'] as String,
      category: CardCategory.values[map['category'] as int],
      cardLanguage: CardLanguage.values[map['cardLanguage'] as int],
      rarity: CardRarity.values[map['rarity'] as int],
      type: map['type'] == null ? null : CardType.values[map['type'] as int],
      stage: map['stage'] == null
          ? null
          : CardStage.values[map['stage'] as int],
      pokemonVariant: map['pokemonVariant'] == null
          ? null
          : PokemonVariant.values[map['pokemonVariant'] as int],
      customPokemonVariant: map['customPokemonVariant'] as String?,
      trainerVariant: map['trainerVariant'] == null
          ? null
          : TrainerVariant.values[map['trainerVariant'] as int],
      itemStadiumKind: map['itemStadiumKind'] == null
          ? null
          : ItemStadiumKind.values[map['itemStadiumKind'] as int],
      itemStadiumVariant: map['itemStadiumVariant'] == null
          ? null
          : ItemStadiumVariant.values[map['itemStadiumVariant'] as int],
      legendary: map['legendary'] == null
          ? null
          : (map['legendary'] as int) == 1,
      forSale: (map['forSale'] as int) == 1,
      price: map['price'] == null ? null : (map['price'] as num).toDouble(),
      pageNumber: map['pageNumber'] as int,
      row: map['row'] as int,
      column: map['column'] as int,
    );
  }
}
