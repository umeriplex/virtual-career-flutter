import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../generated/assets.dart';
import '../constant/app_constants.dart';

class UltimateCachedNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, String)? customPlaceholder;
  final Widget Function(BuildContext, String, dynamic)? customErrorWidget;
  final String? loadingAnimationPath;
  final String? errorAnimationPath;
  final Duration animationDuration;
  final Color? placeholderColor;
  final BorderRadius? borderRadius;
  final bool useHeroAnimation;
  final String? heroTag;
  final List<BoxShadow>? shadow;
  final Color? imageBackgroundColor;
  final Widget? customLoadingWidget;
  final Widget? customErrorImage;

  const UltimateCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.customPlaceholder,
    this.customErrorWidget,
    this.loadingAnimationPath = Assets.imagesLoadingAnimationPath,
    this.errorAnimationPath = Assets.imagesErrorAnimationPath,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.placeholderColor,
    this.borderRadius,
    this.useHeroAnimation = false,
    this.heroTag,
    this.shadow,
    this.imageBackgroundColor,
    this.customLoadingWidget,
    this.customErrorImage,
  });

  @override
  State<UltimateCachedNetworkImage> createState() => _UltimateCachedNetworkImageState();
}

class _UltimateCachedNetworkImageState extends State<UltimateCachedNetworkImage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = Material(
      color: widget.imageBackgroundColor ?? Colors.transparent,
      borderRadius: widget.borderRadius,
      elevation: 0,
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            placeholder: (context, url) => widget.customPlaceholder?.call(context, url) ?? _buildUltimatePlaceholder(),
            errorWidget: (context, url, error) => widget.customErrorWidget?.call(context, url, error) ?? _buildUltimateErrorWidget(),
            fadeInDuration: widget.animationDuration,
            fadeOutDuration: widget.animationDuration,
          ),
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        boxShadow: widget.shadow,
      ),
      child: widget.useHeroAnimation
          ? Hero(
        tag: widget.heroTag ?? widget.imageUrl,
        child: imageWidget,
      )
          : imageWidget,
    );
  }

  Widget _buildUltimatePlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.placeholderColor ?? Colors.grey[200],
      child: Center(
        child: widget.customLoadingWidget ??
            (widget.loadingAnimationPath != null
                ? Lottie.asset(
              widget.loadingAnimationPath!,
              width: widget.width != null ? widget.width! * 0.5 : 100,
              height: widget.height != null ? widget.height! * 0.5 : 100,
              fit: BoxFit.contain,
            )
                : Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                color: Colors.white,
                width: widget.width,
                height: widget.height,
              ),
            )),
      ),
    );
  }

  Widget _buildUltimateErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.placeholderColor ?? Colors.grey[200],
      child: Center(
        child: widget.customErrorImage ??
            (widget.errorAnimationPath != null
                ? Lottie.asset(
              widget.errorAnimationPath!,
              width: widget.width != null ? widget.width! * 0.5 : 100,
              height: widget.height != null ? widget.height! * 0.5 : 100,
              fit: BoxFit.contain,
            )
                : Image.asset(
              AppConstants.placeHolderImage,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
            )),
      ),
    );
  }
}