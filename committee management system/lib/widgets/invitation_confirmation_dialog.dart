import 'package:flutter/material.dart';
import '../../models/committee.dart';
import '../../models/committee_member.dart';
import '../../services/member_confirmation_service.dart';
import '../../services/auth_service.dart';

class InvitationConfirmationDialog extends StatefulWidget {
  final Committee committee;
  final CommitteeMember membership;

  const InvitationConfirmationDialog({
    super.key,
    required this.committee,
    required this.membership,
  });

  @override
  State<InvitationConfirmationDialog> createState() => _InvitationConfirmationDialogState();
}

class _InvitationConfirmationDialogState extends State<InvitationConfirmationDialog> {
  final MemberConfirmationService _confirmationService = MemberConfirmationService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleConfirmation(bool accept) async {
    setState(() => _isLoading = true);

    try {
      bool success;
      if (accept) {
        success = await _confirmationService.acceptInvitation(widget.committee.id);
      } else {
        success = await _confirmationService.declineInvitation(widget.committee.id);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                accept 
                  ? 'Successfully joined ${widget.committee.name}!' 
                  : 'Invitation declined',
              ),
              backgroundColor: accept ? Colors.green : Colors.orange,
            ),
          );
          Navigator.pop(context, accept);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to process invitation'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.group_add,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          const Text('Committee Invitation'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have been invited to join:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.committee.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.committee.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 16, color: Colors.green[600]),
                      const SizedBox(width: 4),
                      Text(
                        '\$${widget.committee.contributionAmount.toStringAsFixed(0)} per cycle',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.blue[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.committee.currentMembers}/${widget.committee.maxMembers} members',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.orange[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.committee.cycleLengthDays} days per cycle',
                        style: TextStyle(
                          color: Colors.orange[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'By accepting, you will be eligible to make payments and participate in winner selection.',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => _handleConfirmation(false),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('Decline'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _handleConfirmation(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Accept'),
        ),
      ],
    );
  }
}
