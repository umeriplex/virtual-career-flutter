import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repository/connection_repo.dart';
import '../../auth/model/user_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../../../core/utils/toast_helper.dart';

class ConnectionController extends GetxController {
  final ConnectionRepository _connectionRepository;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<UserModel> myConnections = <UserModel>[].obs;
  final RxList<UserModel> myFollowers = <UserModel>[].obs;
  final RxList<UserModel> suggestedUsers = <UserModel>[].obs;
  final RxList<UserModel> searchResults = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final selectedUser = Rxn<UserModel>();
  final isConnected = false.obs;

  ConnectionController(this._connectionRepository);

  @override
  void onInit() {
    super.onInit();
    fetchMyConnections();
    fetchMyFollowers();
    fetchSuggestedUsers();
  }






  // Connect with a user
  Future<void> connectWithUser(String targetUserId) async {
    try {
      if (_authController.user == null) return;

      isLoading(true);
      final response = await _connectionRepository.connectWithUser(
        currentUserId: _authController.user!.id,
        targetUserId: targetUserId,
      );

      if (response.success) {
        showSuccessMessage(response.message);

        // Update local lists
        await fetchMyConnections();
        await fetchSuggestedUsers();

        // Update auth user connections
        _authController.user = _authController.user!.copyWith(
          connections: [..._authController.user!.connections, targetUserId],
        );
        isConnected.value = true;
      } else {
        isConnected.value = false;
        showErrorMessage(response.message);
      }
    } catch (e) {
      debugPrint("Error connecting: $e");
      isConnected.value = false;
      showErrorMessage("Failed to connect");
    } finally {
      isLoading(false);
    }
  }

  // Disconnect from a user
  Future<void> disconnectFromUser(String targetUserId) async {
    try {
      if (_authController.user == null) return;

      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Disconnect'),
          content: const Text('Are you sure you want to disconnect from this user?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Disconnect'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isLoading(true);
      final response = await _connectionRepository.disconnectFromUser(
        currentUserId: _authController.user!.id,
        targetUserId: targetUserId,
      );

      if (response.success) {
        showSuccessMessage(response.message);

        // Update local lists
        await fetchMyConnections();
        await fetchSuggestedUsers();

        // Update auth user connections
        final updatedConnections = List<String>.from(_authController.user!.connections)..remove(targetUserId);
        _authController.user = _authController.user!.copyWith(
          connections: updatedConnections,
        );
        isConnected.value = false;
      } else {
        showErrorMessage(response.message);
      }
    } catch (e) {
      debugPrint("Error disconnecting: $e");
      showErrorMessage("Failed to disconnect");
    } finally {
      isLoading(false);
    }
  }

  // Fetch user's connections
  Future<void> fetchMyConnections() async {
    try {
      if (_authController.user == null) return;

      isLoading(true);
      final response = await _connectionRepository.getMyConnections(
        _authController.user!.id,
      );

      if (response.success) {
        myConnections.value = response.data ?? [];
      } else {
        debugPrint("Error fetching connections: ${response.message}");
      }
    } catch (e) {
      debugPrint("Error fetching connections: $e");
    } finally {
      isLoading(false);
    }
  }

  // Fetch user's followers
  Future<void> fetchMyFollowers() async {
    try {
      if (_authController.user == null) return;

      isLoading(true);
      final response = await _connectionRepository.getMyFollowers(
        _authController.user!.id,
      );

      if (response.success) {
        myFollowers.value = response.data ?? [];
      } else {
        debugPrint("Error fetching followers: ${response.message}");
      }
    } catch (e) {
      debugPrint("Error fetching followers: $e");
    } finally {
      isLoading(false);
    }
  }

  // Fetch suggested users
  Future<void> fetchSuggestedUsers() async {
    try {
      if (_authController.user == null) return;

      isLoading(true);
      final response = await _connectionRepository.getSuggestedUsers(
        currentUserId: _authController.user!.id,
        limit: 20,
      );

      if (response.success) {
        suggestedUsers.value = response.data ?? [];
      } else {
        debugPrint("Error fetching suggested users: ${response.message}");
      }
    } catch (e) {
      debugPrint("Error fetching suggested users: $e");
    } finally {
      isLoading(false);
    }
  }

  // Search users
  Future<void> searchUsers(String query) async {
    try {
      if (_authController.user == null) return;

      if (query.trim().isEmpty) {
        searchResults.clear();
        return;
      }

      isSearching(true);
      final response = await _connectionRepository.searchUsers(
        query: query.trim(),
        currentUserId: _authController.user!.id,
      );

      if (response.success) {
        searchResults.value = response.data ?? [];
      } else {
        debugPrint("Error searching users: ${response.message}");
        searchResults.clear();
      }
    } catch (e) {
      debugPrint("Error searching users: $e");
      searchResults.clear();
    } finally {
      isSearching(false);
    }
  }

  // Check if connected with user
  Future<bool> isConnectedWith(String targetUserId) async {
    try {
      if (_authController.user == null) return false;

      final response = await _connectionRepository.isConnected(
        currentUserId: _authController.user!.id,
        targetUserId: targetUserId,
      );
      isConnected.value = response.data ?? false;
      return response.data ?? false;
    } catch (e) {
      debugPrint("Error checking connection: $e");
      isConnected.value = false;
      return false;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      isLoading(true);
      final response = await _connectionRepository.getUserById(userId);

      if (response.success && response.data != null) {
        selectedUser.value = response.data;
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching user: $e");
      return null;
    }finally {
      isLoading(false);
    }
  }

  // Clear search results
  void clearSearch() {
    searchResults.clear();
  }
}