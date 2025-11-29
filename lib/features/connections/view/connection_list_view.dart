import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:virtual_career/core/theme/app_colors.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/config/routes/route_name.dart';
import '../controller/connection_controller.dart';
import '../../auth/model/user_model.dart';

class ConnectionsView extends StatefulWidget {
  const ConnectionsView({super.key});

  @override
  State<ConnectionsView> createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends State<ConnectionsView> with SingleTickerProviderStateMixin {
  final _controller = Get.find<ConnectionController>();
  final _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Connections',),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(110.h),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: responsive.responsivePadding(16, 0, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    _controller.searchUsers(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _controller.clearSearch();
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Connections'),
                  Tab(text: 'Followers'),
                  Tab(text: 'Discover'),
                ],
                labelStyle: AppTextStyles.bodyOpenSans.copyWith(
                  color: Colors.white,
                ),
                indicatorColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ],
          ),
        ),
      ),
      body: _searchController.text.isNotEmpty ? _buildSearchResults(responsive) : TabBarView(
        controller: _tabController,
        children: [
          _buildConnectionsList(responsive),
          _buildFollowersList(responsive),
          _buildSuggestedUsers(responsive),
        ],
      ),
    );
  }

  Widget _buildSearchResults(Responsive responsive) {
    return Obx(() {
      if (_controller.isSearching.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.searchResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64.sp, color: Colors.grey),
              16.verticalSpace,
              Text(
                'No users found',
                style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: responsive.responsivePadding(16, 16, 16, 16),
        itemCount: _controller.searchResults.length,
        itemBuilder: (context, index) {
          final user = _controller.searchResults[index];
          return _buildUserCard(user, responsive);
        },
      );
    });
  }

  Widget _buildConnectionsList(Responsive responsive) {
    return Obx(() {
      if (_controller.isLoading.value && _controller.myConnections.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.myConnections.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64.sp, color: Colors.grey),
              16.verticalSpace,
              Text(
                'No connections yet',
                style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey),
              ),
              8.verticalSpace,
              Text(
                'Start connecting with people!',
                style: AppTextStyles.bodyOpenSans.copyWith(
                  color: Colors.grey,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => await _controller.fetchMyConnections(),
        child: ListView.builder(
          padding: responsive.responsivePadding(16, 16, 16, 16),
          itemCount: _controller.myConnections.length,
          itemBuilder: (context, index) {
            final user = _controller.myConnections[index];
            return _buildUserCard(user, responsive, showDisconnect: true);
          },
        ),
      );
    });
  }

  Widget _buildFollowersList(Responsive responsive) {
    return Obx(() {
      if (_controller.isLoading.value && _controller.myFollowers.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.myFollowers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_outlined, size: 64.sp, color: Colors.grey),
              16.verticalSpace,
              Text(
                'No followers yet',
                style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => await _controller.fetchMyFollowers(),
        child: ListView.builder(
          padding: responsive.responsivePadding(16, 16, 16, 16),
          itemCount: _controller.myFollowers.length,
          itemBuilder: (context, index) {
            final user = _controller.myFollowers[index];
            return _buildUserCard(user, responsive);
          },
        ),
      );
    });
  }

  Widget _buildSuggestedUsers(Responsive responsive) {
    return Obx(() {
      if (_controller.isLoading.value && _controller.suggestedUsers.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.suggestedUsers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.explore_outlined, size: 64.sp, color: Colors.grey),
              16.verticalSpace,
              Text(
                'No suggestions available',
                style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => await _controller.fetchSuggestedUsers(),
        child: ListView.builder(
          padding: responsive.responsivePadding(16, 16, 16, 16),
          itemCount: _controller.suggestedUsers.length,
          itemBuilder: (context, index) {
            final user = _controller.suggestedUsers[index];
            return _buildUserCard(user, responsive);
          },
        ),
      );
    });
  }

  Widget _buildUserCard(UserModel user, Responsive responsive, {bool showDisconnect = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.black12)
      ),
      child: InkWell(
        onTap: () => Get.toNamed(
          RouteNames.userProfile,
          arguments: {'userId': user.id},
        ),
        child: Padding(
          padding: responsive.responsivePadding(12, 12, 12, 12),
          child: Row(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 30.r,
                backgroundImage: user.profileImageUrl != null
                    ? NetworkImage(user.profileImageUrl!)
                    : null,
                child: user.profileImageUrl == null
                    ? Text(
                  user.fullName[0].toUpperCase(),
                  style: AppTextStyles.bodyOpenSans.copyWith(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
              12.horizontalSpace,
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: AppTextStyles.bodyOpenSans.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    if (user.bio != null && user.bio!.isNotEmpty) ...[
                      4.verticalSpace,
                      Text(
                        user.bio!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyOpenSans.copyWith(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    4.verticalSpace,
                    Row(
                      children: [
                        Icon(Icons.people, size: 14.sp, color: Colors.grey),
                        4.horizontalSpace,
                        Text(
                          '${user.connections.length} connections',
                          style: AppTextStyles.bodyOpenSans.copyWith(
                            fontSize: 11.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              8.w.horizontalSpace,

              // Action Button
              if (showDisconnect)
                OutlinedButton(
                  onPressed: () => _controller.disconnectFromUser(user.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                  child: Text(
                    'Disconnect',
                    style: AppTextStyles.bodyOpenSans.copyWith(fontSize: 12.sp),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: () => _controller.connectWithUser(user.id),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    backgroundColor: AppColor.buttonColor,
                  ),
                  child: Text(
                    'Connect',
                    style: AppTextStyles.bodyOpenSans.copyWith(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}