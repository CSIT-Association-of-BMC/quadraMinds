import 'package:flutter/material.dart';
import '../../../models/user_models.dart';

class ProfileInfoCard extends StatelessWidget {
  final ClientUser clientUser;

  const ProfileInfoCard({super.key, required this.clientUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: const Color(0xFF2E7D32),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Personal Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Personal Information Grid
          Column(
            children: [
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: clientUser.email,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value:
                    clientUser.phoneNumber.isNotEmpty
                        ? clientUser.phoneNumber
                        : 'Not provided',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.cake_outlined,
                label: 'Date of Birth',
                value:
                    clientUser.dateOfBirth != null
                        ? _formatDate(clientUser.dateOfBirth!)
                        : 'Not provided',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value:
                    clientUser.address?.isNotEmpty == true
                        ? clientUser.address!
                        : 'Not provided',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.emergency_outlined,
                label: 'Emergency Contact',
                value:
                    clientUser.emergencyContact?.isNotEmpty == true
                        ? clientUser.emergencyContact!
                        : 'Not provided',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
