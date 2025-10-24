import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/committee.dart';
import '../models/committee_member.dart';
import '../models/payment.dart';
import '../models/cycle.dart';
import '../models/payment_proof.dart';
import '../models/winner.dart';
import '../models/audit_log.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'committee_app.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT NOT NULL,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Committees table
    await db.execute('''
      CREATE TABLE committees (
        id TEXT PRIMARY KEY,
        creator_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        contribution_amount REAL NOT NULL,
        max_members INTEGER NOT NULL,
        cycle_length_days INTEGER NOT NULL,
        payment_deadline_days INTEGER NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        current_members INTEGER DEFAULT 0,
        invite_code TEXT UNIQUE NOT NULL,
        rules TEXT,
        allow_late_payments INTEGER DEFAULT 0,
        allow_partial_payments INTEGER DEFAULT 0,
        no_repeat_until_all_win INTEGER DEFAULT 1,
        current_cycle INTEGER DEFAULT 1,
        FOREIGN KEY (creator_id) REFERENCES users (id)
      )
    ''');

    // Committee members table
    await db.execute('''
      CREATE TABLE committee_members (
        id TEXT PRIMARY KEY,
        committee_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        status TEXT NOT NULL,
        joined_at TEXT NOT NULL,
        left_at TEXT,
        FOREIGN KEY (committee_id) REFERENCES committees (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Payments table
    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        committee_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        amount REAL NOT NULL,
        status TEXT NOT NULL,
        description TEXT NOT NULL,
        receipt_image_path TEXT,
        payment_date TEXT NOT NULL,
        verified_at TEXT,
        verified_by TEXT,
        rejection_reason TEXT,
        FOREIGN KEY (committee_id) REFERENCES committees (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Cycles table
    await db.execute('''
      CREATE TABLE cycles (
        id TEXT PRIMARY KEY,
        committee_id TEXT NOT NULL,
        cycle_number INTEGER NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        payment_deadline TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        winner_id TEXT,
        total_collected REAL DEFAULT 0,
        members_paid INTEGER DEFAULT 0,
        is_randomized INTEGER DEFAULT 0,
        FOREIGN KEY (committee_id) REFERENCES committees (id),
        FOREIGN KEY (winner_id) REFERENCES users (id)
      )
    ''');

    // Payment proofs table
    await db.execute('''
      CREATE TABLE payment_proofs (
        id TEXT PRIMARY KEY,
        committee_id TEXT NOT NULL,
        cycle_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        rejection_reason TEXT,
        receipt_image_path TEXT,
        transaction_id TEXT,
        payer_name TEXT,
        payment_date TEXT NOT NULL,
        submitted_at TEXT NOT NULL,
        verified_at TEXT,
        verified_by TEXT,
        is_late INTEGER DEFAULT 0,
        is_partial INTEGER DEFAULT 0,
        FOREIGN KEY (committee_id) REFERENCES committees (id),
        FOREIGN KEY (cycle_id) REFERENCES cycles (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Winners table
    await db.execute('''
      CREATE TABLE winners (
        id TEXT PRIMARY KEY,
        committee_id TEXT NOT NULL,
        cycle_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        cycle_number INTEGER NOT NULL,
        amount_won REAL NOT NULL,
        won_at TEXT NOT NULL,
        random_seed TEXT NOT NULL,
        eligible_members TEXT NOT NULL,
        transfer_proof TEXT,
        transfer_date TEXT,
        transfer_transaction_id TEXT,
        FOREIGN KEY (committee_id) REFERENCES committees (id),
        FOREIGN KEY (cycle_id) REFERENCES cycles (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Audit logs table
    await db.execute('''
      CREATE TABLE audit_logs (
        id TEXT PRIMARY KEY,
        committee_id TEXT NOT NULL,
        cycle_id TEXT,
        user_id TEXT NOT NULL,
        action TEXT NOT NULL,
        description TEXT NOT NULL,
        metadata TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (committee_id) REFERENCES committees (id),
        FOREIGN KEY (cycle_id) REFERENCES cycles (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop old committees table and recreate with new schema
      await db.execute('DROP TABLE IF EXISTS committees');
      await db.execute('''
        CREATE TABLE committees (
          id TEXT PRIMARY KEY,
          creator_id TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          contribution_amount REAL NOT NULL,
          max_members INTEGER NOT NULL,
          cycle_length_days INTEGER NOT NULL,
          payment_deadline_days INTEGER NOT NULL,
          start_date TEXT NOT NULL,
          end_date TEXT,
          status TEXT NOT NULL,
          created_at TEXT NOT NULL,
          current_members INTEGER DEFAULT 0,
          invite_code TEXT UNIQUE NOT NULL,
          rules TEXT,
          allow_late_payments INTEGER DEFAULT 0,
          allow_partial_payments INTEGER DEFAULT 0,
          no_repeat_until_all_win INTEGER DEFAULT 1,
          current_cycle INTEGER DEFAULT 1,
          FOREIGN KEY (creator_id) REFERENCES users (id)
        )
      ''');

      // Add new tables
      await db.execute('''
        CREATE TABLE cycles (
          id TEXT PRIMARY KEY,
          committee_id TEXT NOT NULL,
          cycle_number INTEGER NOT NULL,
          start_date TEXT NOT NULL,
          end_date TEXT NOT NULL,
          payment_deadline TEXT NOT NULL,
          status TEXT NOT NULL,
          created_at TEXT NOT NULL,
          winner_id TEXT,
          total_collected REAL DEFAULT 0,
          members_paid INTEGER DEFAULT 0,
          is_randomized INTEGER DEFAULT 0,
          FOREIGN KEY (committee_id) REFERENCES committees (id),
          FOREIGN KEY (winner_id) REFERENCES users (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE payment_proofs (
          id TEXT PRIMARY KEY,
          committee_id TEXT NOT NULL,
          cycle_id TEXT NOT NULL,
          user_id TEXT NOT NULL,
          amount REAL NOT NULL,
          description TEXT NOT NULL,
          status TEXT NOT NULL,
          rejection_reason TEXT,
          receipt_image_path TEXT,
          transaction_id TEXT,
          payer_name TEXT,
          payment_date TEXT NOT NULL,
          submitted_at TEXT NOT NULL,
          verified_at TEXT,
          verified_by TEXT,
          is_late INTEGER DEFAULT 0,
          is_partial INTEGER DEFAULT 0,
          FOREIGN KEY (committee_id) REFERENCES committees (id),
          FOREIGN KEY (cycle_id) REFERENCES cycles (id),
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE winners (
          id TEXT PRIMARY KEY,
          committee_id TEXT NOT NULL,
          cycle_id TEXT NOT NULL,
          user_id TEXT NOT NULL,
          cycle_number INTEGER NOT NULL,
          amount_won REAL NOT NULL,
          won_at TEXT NOT NULL,
          random_seed TEXT NOT NULL,
          eligible_members TEXT NOT NULL,
          transfer_proof TEXT,
          transfer_date TEXT,
          transfer_transaction_id TEXT,
          FOREIGN KEY (committee_id) REFERENCES committees (id),
          FOREIGN KEY (cycle_id) REFERENCES cycles (id),
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE audit_logs (
          id TEXT PRIMARY KEY,
          committee_id TEXT NOT NULL,
          cycle_id TEXT,
          user_id TEXT NOT NULL,
          action TEXT NOT NULL,
          description TEXT NOT NULL,
          metadata TEXT,
          timestamp TEXT NOT NULL,
          FOREIGN KEY (committee_id) REFERENCES committees (id),
          FOREIGN KEY (cycle_id) REFERENCES cycles (id),
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');
    }
  }

  // User CRUD operations
  Future<String> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap());
    return user.id;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Committee CRUD operations
  Future<String> insertCommittee(Committee committee) async {
    final db = await database;
    await db.insert('committees', committee.toMap());
    return committee.id;
  }

  Future<List<Committee>> getAllCommittees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('committees');
    return List.generate(maps.length, (i) => Committee.fromMap(maps[i]));
  }

  Future<List<Committee>> getCommitteesByCreator(String creatorId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'committees',
      where: 'creator_id = ?',
      whereArgs: [creatorId],
    );
    return List.generate(maps.length, (i) => Committee.fromMap(maps[i]));
  }

  Future<Committee?> getCommitteeById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'committees',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Committee.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCommittee(Committee committee) async {
    final db = await database;
    return await db.update(
      'committees',
      committee.toMap(),
      where: 'id = ?',
      whereArgs: [committee.id],
    );
  }

  Future<int> deleteCommittee(String id) async {
    final db = await database;
    return await db.delete(
      'committees',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Committee Member CRUD operations
  Future<String> insertCommitteeMember(CommitteeMember member) async {
    final db = await database;
    await db.insert('committee_members', member.toMap());
    return member.id;
  }

  Future<List<CommitteeMember>> getCommitteeMembers(String committeeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'committee_members',
      where: 'committee_id = ?',
      whereArgs: [committeeId],
    );
    return List.generate(maps.length, (i) => CommitteeMember.fromMap(maps[i]));
  }

  Future<List<CommitteeMember>> getUserCommittees(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'committee_members',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'joined'],
    );
    return List.generate(maps.length, (i) => CommitteeMember.fromMap(maps[i]));
  }

  Future<int> updateCommitteeMember(CommitteeMember member) async {
    final db = await database;
    return await db.update(
      'committee_members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<int> deleteCommitteeMember(String memberId) async {
    final db = await database;
    return await db.delete(
      'committee_members',
      where: 'id = ?',
      whereArgs: [memberId],
    );
  }

  // Payment CRUD operations
  Future<String> insertPayment(Payment payment) async {
    final db = await database;
    await db.insert('payments', payment.toMap());
    return payment.id;
  }

  Future<List<Payment>> getCommitteePayments(String committeeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'committee_id = ?',
      whereArgs: [committeeId],
    );
    return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
  }

  Future<List<Payment>> getUserPayments(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
  }

  Future<int> updatePayment(Payment payment) async {
    final db = await database;
    return await db.update(
      'payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  // Cycle CRUD operations
  Future<String> insertCycle(Cycle cycle) async {
    final db = await database;
    await db.insert('cycles', cycle.toMap());
    return cycle.id;
  }

  Future<List<Cycle>> getCommitteeCycles(String committeeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cycles',
      where: 'committee_id = ?',
      whereArgs: [committeeId],
      orderBy: 'cycle_number ASC',
    );
    return List.generate(maps.length, (i) => Cycle.fromMap(maps[i]));
  }

  Future<Cycle?> getCurrentCycle(String committeeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cycles',
      where: 'committee_id = ? AND status = ?',
      whereArgs: [committeeId, 'active'],
      orderBy: 'cycle_number DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Cycle.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCycle(Cycle cycle) async {
    final db = await database;
    return await db.update(
      'cycles',
      cycle.toMap(),
      where: 'id = ?',
      whereArgs: [cycle.id],
    );
  }

  // Payment Proof CRUD operations
  Future<String> insertPaymentProof(PaymentProof proof) async {
    final db = await database;
    await db.insert('payment_proofs', proof.toMap());
    return proof.id;
  }

  Future<List<PaymentProof>> getCyclePaymentProofs(String cycleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payment_proofs',
      where: 'cycle_id = ?',
      whereArgs: [cycleId],
      orderBy: 'submitted_at DESC',
    );
    return List.generate(maps.length, (i) => PaymentProof.fromMap(maps[i]));
  }

  Future<List<PaymentProof>> getPendingPaymentProofs(String committeeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payment_proofs',
      where: 'committee_id = ? AND status = ?',
      whereArgs: [committeeId, 'pending'],
      orderBy: 'submitted_at ASC',
    );
    return List.generate(maps.length, (i) => PaymentProof.fromMap(maps[i]));
  }

  Future<PaymentProof?> getUserCyclePaymentProof(String userId, String cycleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payment_proofs',
      where: 'user_id = ? AND cycle_id = ?',
      whereArgs: [userId, cycleId],
    );
    if (maps.isNotEmpty) {
      return PaymentProof.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePaymentProof(PaymentProof proof) async {
    final db = await database;
    return await db.update(
      'payment_proofs',
      proof.toMap(),
      where: 'id = ?',
      whereArgs: [proof.id],
    );
  }

  Future<PaymentProof?> getPaymentProofById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payment_proofs',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return PaymentProof.fromMap(maps.first);
    }
    return null;
  }

  Future<List<PaymentProof>> getPaymentProofsByCommittee(String committeeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payment_proofs',
      where: 'committee_id = ?',
      whereArgs: [committeeId],
      orderBy: 'submitted_at DESC',
    );
    return List.generate(maps.length, (i) => PaymentProof.fromMap(maps[i]));
  }

  Future<Cycle?> getCycleById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cycles',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Cycle.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Cycle>> getCyclesByCommittee(String committeeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cycles',
      where: 'committee_id = ?',
      whereArgs: [committeeId],
      orderBy: 'cycle_number ASC',
    );
    return List.generate(maps.length, (i) => Cycle.fromMap(maps[i]));
  }

  // Winner CRUD operations
  Future<String> insertWinner(Winner winner) async {
    final db = await database;
    await db.insert('winners', winner.toMap());
    return winner.id;
  }

  Future<List<Winner>> getCommitteeWinners(String committeeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'winners',
      where: 'committee_id = ?',
      whereArgs: [committeeId],
      orderBy: 'cycle_number ASC',
    );
    return List.generate(maps.length, (i) => Winner.fromMap(maps[i]));
  }

  Future<List<Winner>> getWinnersByCommittee(String committeeId) async {
    return getCommitteeWinners(committeeId);
  }

  Future<Winner?> getCycleWinner(String cycleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'winners',
      where: 'cycle_id = ?',
      whereArgs: [cycleId],
    );
    if (maps.isNotEmpty) {
      return Winner.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateWinner(Winner winner) async {
    final db = await database;
    return await db.update(
      'winners',
      winner.toMap(),
      where: 'id = ?',
      whereArgs: [winner.id],
    );
  }

  // Audit Log CRUD operations
  Future<String> insertAuditLog(AuditLog log) async {
    final db = await database;
    await db.insert('audit_logs', log.toMap());
    return log.id;
  }

  Future<List<AuditLog>> getCommitteeAuditLogs(String committeeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'audit_logs',
      where: 'committee_id = ?',
      whereArgs: [committeeId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => AuditLog.fromMap(maps[i]));
  }

  Future<List<AuditLog>> getCycleAuditLogs(String cycleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'audit_logs',
      where: 'cycle_id = ?',
      whereArgs: [cycleId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => AuditLog.fromMap(maps[i]));
  }

  // Utility methods
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
