import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:virtual_career/features/profile/view/profile_edit_view.dart';
import '../../../config/routes/route_name.dart';
import '../../../core/components/custom_button.dart';
import '../../../core/components/custom_image_view.dart';
import '../../../core/managers/cache_manager.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileView extends StatelessWidget {
  final AuthController _authController = Get.find();

  ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.to(() => EditProfileScreen()),
          ),
        ],
      ),
      body: Obx(() {
        final user = _authController.user;
        if (user == null) {
          return const Center(child: CupertinoActivityIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: user.profileImageUrl != null ?
                        UltimateCachedNetworkImage(
                          imageUrl: user.profileImageUrl!,
                          fit: BoxFit.cover,
                        ) :
                        Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.grey[200],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // User Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileItem(
                        icon: Icons.person,
                        label: 'Full Name',
                        value: user.fullName,
                      ),
                      const Divider(),
                      _buildProfileItem(
                        icon: Icons.email,
                        label: 'Email',
                        value: user.email,
                      ),
                      const Divider(),
                      _buildProfileItem(
                        icon: Icons.info,
                        label: 'Bio',
                        value: user.bio ?? 'No bio added',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Account Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileItem(
                        icon: Icons.calendar_today,
                        label: 'Member Since',
                        value: '${user.dateCreated.day}/${user.dateCreated.month}/${user.dateCreated.year}',
                      ),
                      const Divider(),
                      _buildProfileItem(
                        icon: Icons.verified_user,
                        label: 'Account Status',
                        value: user.isActive ? 'Active' : 'Inactive',
                        valueColor: user.isActive ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              CustomButton(
                isSecondButton: true,
                title: "Sign Out",
                onPressed: () async {
                  var success = await _authController.signOut();
                  if (success) {
                    SharedPrefs.instance.removeUser();
                    Get.offAllNamed(RouteNames.login);
                  }
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}