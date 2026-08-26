import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/emergency_contact.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = EmergencyContact.allContacts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // PAGE HEADER
          // ==========================================
          const Text(
            'Emergency Contacts',
            style: AppTextStyles.title,
          ),

          const SizedBox(height: 6),

          const Text(
            'ANGKATAN PERTAHANAN AWAM MALAYSIA (APM)',
            style: AppTextStyles.bodySecondary,
          ),

          const SizedBox(height: 8),

          const Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 12,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 5),
              Text(
                'Available 24/7 during flood seasons',
                style: AppTextStyles.caption,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ==========================================
          // CONTACT LIST
          // ==========================================
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: contacts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return _buildContactCard(context, contact);
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, EmergencyContact contact) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                contact.state,
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
              
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.map_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => _launchMap(contact.locationSearchQuery),
                    tooltip: 'View Location',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            contact.name,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: contact.phoneNumbers.map((phone) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _launchPhone(phone),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.primaryBlue.withOpacity(0.05),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          phone,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri url = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchMap(String query) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
