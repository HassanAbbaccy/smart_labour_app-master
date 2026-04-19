import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class CustomImageView extends StatelessWidget {
  final String? url;
  final String placeholder;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  const CustomImageView({
    super.key,
    required this.url,
    this.placeholder = 'assets/images/user_placeholder.png',
    this.width,
    this.height,
    this.borderRadius = 0,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: _buildImageWidget(),
    );
  }

  Widget _buildImageWidget() {
    if (url == null || url!.isEmpty) {
      return Image.asset(
        placeholder,
        width: width,
        height: height,
        fit: fit,
      );
    }

    if (!url!.startsWith('http')) {
      return Image.asset(
        url!,
        width: width,
        height: height,
        fit: fit,
      );
    }

    return CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => Image.asset(
        placeholder,
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }
}
