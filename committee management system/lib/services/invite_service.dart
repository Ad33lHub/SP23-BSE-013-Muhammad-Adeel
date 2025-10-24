import 'package:uuid/uuid.dart';
import '../models/committee.dart';
import '../models/committee_member.dart';
import '../models/audit_log.dart';
import '../database/database_helper.dart';
import '../services/auth_service.dart';

class InviteService {
  static final InviteService _instance = InviteService._internal();
  factory InviteService() => _instance;
  InviteService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();
  final Uuid _uuid = const Uuid();

  Future<Committee?> getCommitteeByInviteCode(String inviteCode) async {
    try {
      final committees = await _dbHelper.getAllCommittees();
      return committees.where((c) => c.inviteCode == inviteCode).firstOrNull;
    } catch (e) {
      print('Error getting committee by invite code: $e');
      return null;
    }
  }

  Future<bool> joinCommitteeWithCode(String inviteCode) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      final committee = await getCommitteeByInviteCode(inviteCode);
      if (committee == null) return false;

      // Check if committee is still active
      if (committee.status != 'active') return false;

      // Check if committee has space
      if (committee.currentMembers >= committee.maxMembers) return false;

      // Check if user is already a member
      final members = await _dbHelper.getCommitteeMembers(committee.id);
      final isAlreadyMember = members.any((m) => m.userId == currentUser.id);
      if (isAlreadyMember) return false;

      // Add user as member
      final member = CommitteeMember(
        id: _uuid.v4(),
        committeeId: committee.id,
        userId: currentUser.id,
        status: 'joined',
        joinedAt: DateTime.now(),
      );

      await _dbHelper.insertCommitteeMember(member);

      // Update committee member count
      final updatedCommittee = committee.copyWith(
        currentMembers: committee.currentMembers + 1,
      );
      await _dbHelper.updateCommittee(updatedCommittee);

      // Log the join action
      await _dbHelper.insertAuditLog(
        AuditLog(
          id: _uuid.v4(),
          committeeId: committee.id,
          userId: currentUser.id,
          action: 'joined',
          description: '${currentUser.name} joined committee "${committee.name}"',
          metadata: {
            'invite_code': inviteCode,
            'member_count': updatedCommittee.currentMembers,
          },
          timestamp: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      print('Error joining committee: $e');
      return false;
    }
  }

  Future<bool> sendInviteToUser(String committeeId, String userEmail) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      final committee = await _dbHelper.getCommitteeById(committeeId);
      if (committee == null) return false;

      // Check if user is the creator
      if (committee.creatorId != currentUser.id) return false;

      final invitedUser = await _dbHelper.getUserByEmail(userEmail);
      if (invitedUser == null) return false;

      // Check if user is already a member
      final members = await _dbHelper.getCommitteeMembers(committeeId);
      final isAlreadyMember = members.any((m) => m.userId == invitedUser.id);
      if (isAlreadyMember) return false;

      // Add user as invited member
      final member = CommitteeMember(
        id: _uuid.v4(),
        committeeId: committeeId,
        userId: invitedUser.id,
        status: 'invited',
        joinedAt: DateTime.now(),
      );

      await _dbHelper.insertCommitteeMember(member);

      // Log the invite action
      await _dbHelper.insertAuditLog(
        AuditLog(
          id: _uuid.v4(),
          committeeId: committeeId,
          userId: currentUser.id,
          action: 'invited',
          description: '${currentUser.name} invited ${invitedUser.name} to committee "${committee.name}"',
          metadata: {
            'invited_user_email': userEmail,
            'invite_code': committee.inviteCode,
          },
          timestamp: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      print('Error sending invite: $e');
      return false;
    }
  }

  Future<List<CommitteeMember>> getPendingInvites(String userId) async {
    try {
      final members = await _dbHelper.getUserCommittees(userId);
      return members.where((m) => m.status == 'invited').toList();
    } catch (e) {
      print('Error getting pending invites: $e');
      return [];
    }
  }

  Future<bool> acceptInvite(String committeeId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      final members = await _dbHelper.getCommitteeMembers(committeeId);
      final member = members.where((m) => m.userId == currentUser.id).firstOrNull;
      
      if (member == null || member.status != 'invited') return false;

      // Update member status
      final updatedMember = member.copyWith(status: 'joined');
      await _dbHelper.updateCommitteeMember(updatedMember);

      // Update committee member count
      final committee = await _dbHelper.getCommitteeById(committeeId);
      if (committee != null) {
        final updatedCommittee = committee.copyWith(
          currentMembers: committee.currentMembers + 1,
        );
        await _dbHelper.updateCommittee(updatedCommittee);
      }

      // Log the acceptance
      await _dbHelper.insertAuditLog(
        AuditLog(
          id: _uuid.v4(),
          committeeId: committeeId,
          userId: currentUser.id,
          action: 'accepted_invite',
          description: '${currentUser.name} accepted invitation to committee',
          timestamp: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      print('Error accepting invite: $e');
      return false;
    }
  }

  Future<bool> declineInvite(String committeeId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      final members = await _dbHelper.getCommitteeMembers(committeeId);
      final member = members.where((m) => m.userId == currentUser.id).firstOrNull;
      
      if (member == null || member.status != 'invited') return false;

      // Update member status
      final updatedMember = member.copyWith(
        status: 'left',
        leftAt: DateTime.now(),
      );
      await _dbHelper.updateCommitteeMember(updatedMember);

      // Log the decline
      await _dbHelper.insertAuditLog(
        AuditLog(
          id: _uuid.v4(),
          committeeId: committeeId,
          userId: currentUser.id,
          action: 'declined_invite',
          description: '${currentUser.name} declined invitation to committee',
          timestamp: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      print('Error declining invite: $e');
      return false;
    }
  }

  String generateInviteLink(String inviteCode) {
    return 'committee://join/$inviteCode';
  }

  String generateShareableText(String committeeName, String inviteCode) {
    return 'Join my committee "$committeeName" using invite code: $inviteCode\n\nDownload the Committee App and use this code to join!';
  }
}
