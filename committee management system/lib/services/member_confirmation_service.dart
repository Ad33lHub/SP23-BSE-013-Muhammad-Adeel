import 'package:uuid/uuid.dart';
import '../models/committee_member.dart';
import '../models/audit_log.dart';
import '../database/database_helper.dart';
import '../services/auth_service.dart';

class MemberConfirmationService {
  static final MemberConfirmationService _instance = MemberConfirmationService._internal();
  factory MemberConfirmationService() => _instance;
  MemberConfirmationService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();
  final Uuid _uuid = const Uuid();

  /// Send invitation to a user (creator action)
  Future<bool> sendInvitationToUser(String committeeId, String userId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      final committee = await _dbHelper.getCommitteeById(committeeId);
      if (committee == null || committee.creatorId != currentUser.id) return false;

      // Check if user is already a member
      final existingMembers = await _dbHelper.getCommitteeMembers(committeeId);
      final existingMember = existingMembers.where((m) => m.userId == userId).firstOrNull;

      if (existingMember != null) {
        if (existingMember.status == 'active') {
          return false; // Already an active member
        } else if (existingMember.status == 'invited') {
          return true; // Already invited
        } else if (existingMember.status == 'requested') {
          // Update status to invited
          final updatedMember = existingMember.copyWith(status: 'invited');
          await _dbHelper.updateCommitteeMember(updatedMember);
        }
      } else {
        // Create new member with invited status
        final memberId = _uuid.v4();
        await _dbHelper.insertCommitteeMember(
          CommitteeMember(
            id: memberId,
            committeeId: committeeId,
            userId: userId,
            status: 'invited',
            joinedAt: DateTime.now(),
          ),
        );
      }

      // Log the invitation
      await _dbHelper.insertAuditLog(
        AuditLog(
          id: _uuid.v4(),
          committeeId: committeeId,
          userId: currentUser.id,
          action: 'invitation_sent',
          description: 'Creator ${currentUser.name} sent invitation to user $userId for committee "${committee.name}"',
          metadata: {
            'invited_user_id': userId,
            'committee_name': committee.name,
          },
          timestamp: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      print('Error sending invitation: $e');
      return false;
    }
  }

  /// Accept invitation (user action)
  Future<bool> acceptInvitation(String committeeId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      final members = await _dbHelper.getCommitteeMembers(committeeId);
      final member = members.where((m) => m.userId == currentUser.id).firstOrNull;

      if (member == null || member.status != 'invited') return false;

      // Update member status to active
      final updatedMember = member.copyWith(status: 'active');
      await _dbHelper.updateCommitteeMember(updatedMember);

      // Update committee member count
      final committee = await _dbHelper.getCommitteeById(committeeId);
      if (committee != null) {
        final updatedCommittee = committee.copyWith(
          currentMembers: (committee.currentMembers ?? 0) + 1,
        );
        await _dbHelper.updateCommittee(updatedCommittee);
      }

      // Log the acceptance
      await _dbHelper.insertAuditLog(
        AuditLog(
          id: _uuid.v4(),
          committeeId: committeeId,
          userId: currentUser.id,
          action: 'invitation_accepted',
          description: 'User ${currentUser.name} accepted invitation to committee "${committee?.name ?? committeeId}"',
          metadata: {
            'committee_name': committee?.name ?? committeeId,
            'member_status': 'active',
          },
          timestamp: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      print('Error accepting invitation: $e');
      return false;
    }
  }

  /// Decline invitation (user action)
  Future<bool> declineInvitation(String committeeId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      final members = await _dbHelper.getCommitteeMembers(committeeId);
      final member = members.where((m) => m.userId == currentUser.id).firstOrNull;

      if (member == null || member.status != 'invited') return false;

      // Remove member from committee
      await _dbHelper.deleteCommitteeMember(member.id);

      // Log the decline
      final committee = await _dbHelper.getCommitteeById(committeeId);
      await _dbHelper.insertAuditLog(
        AuditLog(
          id: _uuid.v4(),
          committeeId: committeeId,
          userId: currentUser.id,
          action: 'invitation_declined',
          description: 'User ${currentUser.name} declined invitation to committee "${committee?.name ?? committeeId}"',
          metadata: {
            'committee_name': committee?.name ?? committeeId,
            'member_status': 'declined',
          },
          timestamp: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      print('Error declining invitation: $e');
      return false;
    }
  }

  /// Get pending invitations for a user
  Future<List<Map<String, dynamic>>> getPendingInvitationsForUser(String userId) async {
    try {
      // Get all committees and check for invited memberships
      final committees = await _dbHelper.getAllCommittees();
      final invitations = <Map<String, dynamic>>[];
      
      for (final committee in committees) {
        final members = await _dbHelper.getCommitteeMembers(committee.id);
        final invitedMembership = members.where((m) => m.userId == userId && m.status == 'invited').firstOrNull;
        
        if (invitedMembership != null) {
          invitations.add({
            'membership': invitedMembership,
            'committee': committee,
          });
        }
      }
      
      return invitations;
    } catch (e) {
      print('Error getting pending invitations: $e');
      return [];
    }
  }

  /// Get pending requests for a creator
  Future<List<Map<String, dynamic>>> getPendingRequestsForCreator(String committeeId) async {
    try {
      final members = await _dbHelper.getCommitteeMembers(committeeId);
      final requestedMembers = members.where((m) => m.status == 'requested').toList();
      
      final requests = <Map<String, dynamic>>[];
      for (final member in requestedMembers) {
        final user = await _dbHelper.getUserById(member.userId);
        if (user != null) {
          requests.add({
            'member': member,
            'user': user,
          });
        }
      }
      
      return requests;
    } catch (e) {
      print('Error getting pending requests: $e');
      return [];
    }
  }

  /// Check if user is eligible for payments and winner selection
  Future<bool> isUserEligibleForCommittee(String userId, String committeeId) async {
    try {
      final members = await _dbHelper.getCommitteeMembers(committeeId);
      final member = members.where((m) => m.userId == userId).firstOrNull;
      
      return member != null && member.status == 'active';
    } catch (e) {
      print('Error checking user eligibility: $e');
      return false;
    }
  }

  /// Get member status for a user in a committee
  Future<String?> getMemberStatus(String userId, String committeeId) async {
    try {
      final members = await _dbHelper.getCommitteeMembers(committeeId);
      final member = members.where((m) => m.userId == userId).firstOrNull;
      
      return member?.status;
    } catch (e) {
      print('Error getting member status: $e');
      return null;
    }
  }
}
