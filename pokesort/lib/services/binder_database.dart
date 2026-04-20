import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/binder.dart';
import '../models/card_model.dart';

class BinderDatabase {
  static final BinderDatabase instance = BinderDatabase._init();
  static Database? _database;

  BinderDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('binder.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 6,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE binders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        coverImage TEXT,
        sheetCount INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        binderId INTEGER NOT NULL,
        name TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        category INTEGER NOT NULL,
        cardLanguage INTEGER NOT NULL,
        rarity INTEGER NOT NULL,
        type INTEGER,
        stage INTEGER,
        pokemonVariant INTEGER,
        customPokemonVariant TEXT,
        trainerVariant INTEGER,
        itemStadiumKind INTEGER,
        itemStadiumVariant INTEGER,
        legendary INTEGER,
        forSale INTEGER NOT NULL,
        price REAL,
        pageNumber INTEGER NOT NULL,
        row INTEGER NOT NULL,
        column INTEGER NOT NULL,
        FOREIGN KEY (binderId) REFERENCES binders(id) ON DELETE CASCADE,
        UNIQUE(binderId, pageNumber, row, column)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 6) {
      await db.execute('DROP TABLE IF EXISTS cards');
      await db.execute('DROP TABLE IF EXISTS binders');
      await _createDB(db, newVersion);
    }
  }

  Future<int> insertBinder(Binder binder) async {
    final db = await database;
    return db.insert('binders', binder.toMap());
  }

  Future<List<Binder>> getBinders() async {
    final db = await database;
    final maps = await db.query('binders', orderBy: 'name ASC');
    return maps.map((map) => Binder.fromMap(map)).toList();
  }

  Future<int> deleteBinder(int binderId) async {
    final db = await database;

    await db.delete('cards', where: 'binderId = ?', whereArgs: [binderId]);

    return db.delete('binders', where: 'id = ?', whereArgs: [binderId]);
  }

  Future<int> insertCard(CardModel card) async {
    final db = await database;
    return db.insert(
      'cards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> updateCard(CardModel card) async {
    final db = await database;
    if (card.id == null) {
      throw ArgumentError('Cannot update a card with no id.');
    }

    return db.update(
      'cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> deleteCard(int cardId) async {
    final db = await database;
    return db.delete('cards', where: 'id = ?', whereArgs: [cardId]);
  }

  Future<List<CardModel>> getCardsByBinder(int binderId) async {
    final db = await database;
    final maps = await db.query(
      'cards',
      where: 'binderId = ?',
      whereArgs: [binderId],
      orderBy: 'pageNumber ASC, row ASC, column ASC',
    );

    return maps.map((map) => CardModel.fromMap(map)).toList();
  }

  Future<List<CardModel>> getAllCards() async {
    final db = await database;
    final maps = await db.query('cards', orderBy: 'name COLLATE NOCASE ASC');

    return maps.map((map) => CardModel.fromMap(map)).toList();
  }

  Future<bool> cardSlotExists({
    required int binderId,
    required int pageNumber,
    required int row,
    required int column,
    int? excludeCardId,
  }) async {
    final db = await database;

    String where = 'binderId = ? AND pageNumber = ? AND row = ? AND column = ?';
    final whereArgs = <Object?>[binderId, pageNumber, row, column];

    if (excludeCardId != null) {
      where += ' AND id != ?';
      whereArgs.add(excludeCardId);
    }

    final maps = await db.query(
      'cards',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );

    return maps.isNotEmpty;
  }

  Future<CardModel?> getCardBySlot({
    required int binderId,
    required int pageNumber,
    required int row,
    required int column,
    int? excludeCardId,
  }) async {
    final db = await database;

    String where = 'binderId = ? AND pageNumber = ? AND row = ? AND column = ?';
    final whereArgs = <Object?>[binderId, pageNumber, row, column];

    if (excludeCardId != null) {
      where += ' AND id != ?';
      whereArgs.add(excludeCardId);
    }

    final maps = await db.query(
      'cards',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return CardModel.fromMap(maps.first);
  }

  Future<void> moveCardToSlot({
    required int cardId,
    required int pageNumber,
    required int row,
    required int column,
  }) async {
    final db = await database;
    await db.update(
      'cards',
      {'pageNumber': pageNumber, 'row': row, 'column': column},
      where: 'id = ?',
      whereArgs: [cardId],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> swapCardSlots({
    required CardModel firstCard,
    required CardModel secondCard,
  }) async {
    final db = await database;

    if (firstCard.id == null || secondCard.id == null) {
      throw ArgumentError('Both cards must have ids before swapping slots.');
    }

    await db.transaction((txn) async {
      await txn.update(
        'cards',
        {'pageNumber': 0, 'row': 0, 'column': 0},
        where: 'id = ?',
        whereArgs: [firstCard.id],
      );
      await txn.update(
        'cards',
        {
          'pageNumber': firstCard.pageNumber,
          'row': firstCard.row,
          'column': firstCard.column,
        },
        where: 'id = ?',
        whereArgs: [secondCard.id],
      );
      await txn.update(
        'cards',
        {
          'pageNumber': secondCard.pageNumber,
          'row': secondCard.row,
          'column': secondCard.column,
        },
        where: 'id = ?',
        whereArgs: [firstCard.id],
      );
    });
  }

  Future<void> updateCardWithSwap({
    required CardModel originalCard,
    required CardModel updatedCard,
    required CardModel conflictingCard,
  }) async {
    final db = await database;

    if (originalCard.id == null ||
        updatedCard.id == null ||
        conflictingCard.id == null) {
      throw ArgumentError('All cards must have ids before swapping slots.');
    }

    await db.transaction((txn) async {
      await txn.update(
        'cards',
        {'pageNumber': 0, 'row': 0, 'column': 0},
        where: 'id = ?',
        whereArgs: [updatedCard.id],
      );
      await txn.update(
        'cards',
        {
          'pageNumber': originalCard.pageNumber,
          'row': originalCard.row,
          'column': originalCard.column,
        },
        where: 'id = ?',
        whereArgs: [conflictingCard.id],
      );
      await txn.update(
        'cards',
        updatedCard.toMap(),
        where: 'id = ?',
        whereArgs: [updatedCard.id],
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });
  }
}
