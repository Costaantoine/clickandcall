
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'elderly_launcher.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        imagePath TEXT,
        phoneNumber TEXT
      )
    ''');
    
    // Table pour sauvegarder les SMS
    await db.execute('''
      CREATE TABLE sms_messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender TEXT,
        message TEXT,
        timestamp TEXT,
        isRead INTEGER DEFAULT 0
      )
    ''');
  }

  Future<int> addContact(String name, String imagePath, String phoneNumber) async {
    final db = await database;
    return await db.insert('contacts', {
      'name': name,
      'imagePath': imagePath,
      'phoneNumber': phoneNumber,
    });
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    final db = await database;
    return await db.query('contacts');
  }

  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }
  
  // Méthodes pour gérer les SMS
  Future<int> saveSms({
    required String sender,
    required String message,
    required String timestamp,
  }) async {
    final db = await database;
    return await db.insert('sms_messages', {
      'sender': sender,
      'message': message,
      'timestamp': timestamp,
      'isRead': 1,
    });
  }
  
  Future<List<Map<String, dynamic>>> getSavedSms() async {
    final db = await database;
    return await db.query('sms_messages', orderBy: 'timestamp DESC');
  }
  
  Future<int> deleteSms(int id) async {
    final db = await database;
    return await db.delete('sms_messages', where: 'id = ?', whereArgs: [id]);
  }
}
