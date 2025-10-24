import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/committee.dart';
import '../models/cycle.dart';
import '../models/committee_member.dart';
import '../models/winner.dart';
import '../models/audit_log.dart';
import '../database/database_helper.dart';
import '../services/auth_service.dart';
import 'member_confirmation_service.dart';

class WinnerSelectionService {
  static final WinnerSelectionService _instance = WinnerSelectionService._internal();
  factory WinnerSelectionService() => _instance;
  WinnerSelectionService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();
  final MemberConfirmationService _confirmationService = MemberConfirmationService();
  final Uuid _uuid = const Uuid();
  final Random _random = Random();

  Future<Map<String, dynamic>> selectWinner(String committeeId, String cycleId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      // Get committee and verify creator
      final committee = await _dbHelper.getCommitteeById(committeeId);
      if (committee == null) {
        return {'success': false, 'error': 'Committee not found'};
      }

      if (committee.creatorId != currentUser.id) {
        return {'success': false, 'error': 'Only committee creator can select winner'};
      }

      // Get cycle
      final cycle = await _dbHelper.getCycleById(cycleId);
      if (cycle == null) {
        return {'success': false, 'error': 'Cycle not found'};
      }

      if (cycle.status != 'active') {
        return {'success': false, 'error': 'Cycle is not active'};
      }

      // Get eligible members
      final eligibleMembers = await _getEligibleMembers(committeeId, cycleId, committee);
      if (eligibleMembers.isEmpty) {
        return {'success': false, 'error': 'No eligible members found'};
      }

      // Generate random seed for audit trail
      final seed = DateTime.now().millisecondsSinceEpoch.toString();
      final random = Random(DateTime.now().millisecondsSinceEpoch);

      // Select winner
      final winnerIndex = random.nextInt(eligibleMembers.length);
      final winner = eligibleMembers[winnerIndex];

      // Calculate pot amount
      final potAmount = await _calculatePotAmount(committeeId, cycleId);

      // Create winner record
      final winnerRecord = Winner(
        id: _uuid.v4(),
        committeeId: committeeId,
        cycleId: cycleId,
        userId: winner.userId,
        cycleNumber: cycle.cycleNumber,
        amountWon: potAmount,
        wonAt: DateTime.now(),
        randomSeed: seed,
        eligibleMembers: eligibleMembers.map((m) => m.userId).toList(),
      );

      await _dbHelper.insertWinner(winnerRecord);

      // Update cycle status
      final updatedCycle = cycle.copyWith(
        status: 'completed',
        endDate: DateTime.now(),
      );
      await _dbHelper.updateCycle(updatedCycle);

      // Create next cycle if needed
      await _createNextCycle(committeeId, cycle);

      // Log the selection
      await _dbHelper.insertAuditLog(
        AuditLog(
          id: _uuid.v4(),
          committeeId: committeeId,
          userId: currentUser.id,
          action: 'winner_selected',
          description: '${currentUser.name} selected ${winner.userId} as winner for cycle ${cycle.cycleNumber}',
          metadata: {
            'cycle_id': cycleId,
            'winner_id': winner.userId,
            'pot_amount': potAmount,
            'random_seed': seed,
            'eligible_count': eligibleMembers.length,
            'eligible_members': eligibleMembers.map((m) => m.userId).toList(),
          },
          timestamp: DateTime.now(),
        ),
      );

      return {
        'success': true,
        'winner': winner,
        'potAmount': potAmount,
        'seed': seed,
        'eligibleCount': eligibleMembers.length,
      };
    } catch (e) {
      print('Error selecting winner: $e');
      return {'success': false, 'error': 'Failed to select winner: $e'};
    }
  }

  Future<List<CommitteeMember>> _getEligibleMembers(
    String committeeId,
    String cycleId,
    Committee committee,
  ) async {
    try {
      // Get all active members
      final members = await _dbHelper.getCommitteeMembers(committeeId);
      final activeMembers = members.where((m) => m.status == 'active').toList();

      // Get approved payment proofs for this cycle
      final paymentProofs = await _dbHelper.getCyclePaymentProofs(cycleId);
      final approvedProofs = paymentProofs.where((p) => p.status == 'approved').toList();

      // Get previous winners if no-repeat rule is enabled
      List<String> excludedMemberIds = [];
      if (committee.noRepeatUntilAllWin) {
        final previousWinners = await _dbHelper.getWinnersByCommittee(committeeId);
        excludedMemberIds = previousWinners.map((w) => w.userId).toList();
      }

      // Filter eligible members
      final eligibleMembers = <CommitteeMember>[];
      
      for (final member in activeMembers) {
        // Check if member has approved payment
        final hasApprovedPayment = approvedProofs.any((p) => p.userId == member.userId);
        
        // Check if member is excluded due to no-repeat rule
        final isExcluded = excludedMemberIds.contains(member.userId);
        
        if (hasApprovedPayment && !isExcluded) {
          eligibleMembers.add(member);
        }
      }

      return eligibleMembers;
    } catch (e) {
      print('Error getting eligible members: $e');
      return [];
    }
  }

  Future<double> _calculatePotAmount(String committeeId, String cycleId) async {
    try {
      final paymentProofs = await _dbHelper.getCyclePaymentProofs(cycleId);
      final approvedProofs = paymentProofs.where((p) => p.status == 'approved').toList();
      
      double total = 0.0;
      for (final proof in approvedProofs) {
        total += proof.amount;
      }
      return total;
    } catch (e) {
      print('Error calculating pot amount: $e');
      return 0.0;
    }
  }

  Future<void> _createNextCycle(String committeeId, Cycle currentCycle) async {
    try {
      final committee = await _dbHelper.getCommitteeById(committeeId);
      if (committee == null) return;

      // Check if committee should continue
      if (committee.endDate != null && DateTime.now().isAfter(committee.endDate!)) {
        // Committee has ended
        await _dbHelper.updateCommittee(committee.copyWith(status: 'completed'));
        return;
      }

      // Create next cycle
      final nextCycleNumber = currentCycle.cycleNumber + 1;
      final nextCycleStartDate = currentCycle.endDate ?? DateTime.now();
      final nextCycleEndDate = nextCycleStartDate.add(Duration(days: committee.cycleLengthDays));

      final nextCycle = Cycle(
        id: _uuid.v4(),
        committeeId: committeeId,
        cycleNumber: nextCycleNumber,
        startDate: nextCycleStartDate,
        endDate: nextCycleEndDate,
        status: 'active',
        createdAt: DateTime.now(),
        paymentDeadline: nextCycleStartDate.add(Duration(days: committee.paymentDeadlineDays)),
      );

      await _dbHelper.insertCycle(nextCycle);

      // Log cycle creation
      await _dbHelper.insertAuditLog(
        AuditLog(
          id: _uuid.v4(),
          committeeId: committeeId,
          userId: committee.creatorId,
          action: 'cycle_created',
          description: 'New cycle $nextCycleNumber created',
          metadata: {
            'cycle_number': nextCycleNumber,
            'start_date': nextCycleStartDate.toIso8601String(),
            'end_date': nextCycleEndDate.toIso8601String(),
          },
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      print('Error creating next cycle: $e');
    }
  }

  Future<bool> canSelectWinner(String committeeId, String cycleId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      // Check if user is creator
      final committee = await _dbHelper.getCommitteeById(committeeId);
      if (committee == null || committee.creatorId != currentUser.id) return false;

      // Check if cycle is active
      final cycle = await _dbHelper.getCycleById(cycleId);
      if (cycle == null || cycle.status != 'active') return false;

      // Check if deadline has passed
      final deadline = cycle.startDate.add(Duration(days: committee.paymentDeadlineDays));
      if (DateTime.now().isBefore(deadline)) return false;

      // Check if there are eligible members
      final eligibleMembers = await _getEligibleMembers(committeeId, cycleId, committee);
      return eligibleMembers.isNotEmpty;
    } catch (e) {
      print('Error checking winner selection eligibility: $e');
      return false;
    }
  }

  Future<List<Winner>> getCommitteeWinners(String committeeId) async {
    try {
      return await _dbHelper.getWinnersByCommittee(committeeId);
    } catch (e) {
      print('Error getting committee winners: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getCycleStatus(String committeeId, String cycleId) async {
    try {
      final cycle = await _dbHelper.getCycleById(cycleId);
      if (cycle == null) {
        return {'error': 'Cycle not found'};
      }

      final committee = await _dbHelper.getCommitteeById(committeeId);
      if (committee == null) {
        return {'error': 'Committee not found'};
      }

      final eligibleMembers = await _getEligibleMembers(committeeId, cycleId, committee);
      final potAmount = await _calculatePotAmount(committeeId, cycleId);
      final canSelect = await canSelectWinner(committeeId, cycleId);

      return {
        'cycle': cycle,
        'eligibleMembers': eligibleMembers,
        'potAmount': potAmount,
        'canSelectWinner': canSelect,
        'deadline': cycle.startDate.add(Duration(days: committee.paymentDeadlineDays)),
      };
    } catch (e) {
      print('Error getting cycle status: $e');
      return {'error': 'Failed to get cycle status: $e'};
    }
  }

  Future<List<Map<String, dynamic>>> getWinnerHistory(String committeeId) async {
    try {
      final winners = await getCommitteeWinners(committeeId);
      final history = <Map<String, dynamic>>[];

      for (final winner in winners) {
        final user = await _dbHelper.getUserById(winner.userId);
        final cycle = await _dbHelper.getCycleById(winner.cycleId);
        
        history.add({
          'winner': winner,
          'user': user,
          'cycle': cycle,
          'amount': winner.amountWon,
          'selectedAt': winner.wonAt,
        });
      }

      return history;
    } catch (e) {
      print('Error getting winner history: $e');
      return [];
    }
  }
}
