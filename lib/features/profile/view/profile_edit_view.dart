import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/components/custom_button.dart';
import '../../../core/components/custom_image_view.dart';
import '../../../core/components/custom_text_field.dart';
import '../../auth/controller/auth_controller.dart';

class EditProfileScreen extends StatelessWidget {
  final AuthController _authController = Get.find();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  EditProfileScreen({super.key}) {
    final user = _authController.user;
    if (user != null) {
      _nameController.text = user.fullName;
      _bioController.text = user.bio ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture Edit
            Obx(() {
              final user = _authController.user;
              return GestureDetector(
                onTap: _pickImage,
                child: Center(
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
                          child: _authController.isLoading.value ?
                          const Center(
                            child: CupertinoActivityIndicator(),
                          ) :
                          user?.profileImageUrl != null ?
                          UltimateCachedNetworkImage(
                            imageUrl: user!.profileImageUrl!,
                            fit: BoxFit.cover,
                          ) :
                          Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey[200],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Edit Form
            CustomTextField(
              controller: _nameController,
              hintText: 'Full Name',

              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _bioController,
              hintText: 'Bio',
              prefixIcon: Icons.info,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Save Button
            Obx(() => CustomButton(
              isLoading: _authController.isLoading.value,
              title: "Save Changes",
              onPressed: () async {
                final success = await _authController.updateProfile(
                  fullName: _nameController.text.trim(),
                  bio: _bioController.text.trim(),
                );
                if (success) {
                  Get.back();
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      await _authController.updateProfilePicture(file);
    }
  }
}
