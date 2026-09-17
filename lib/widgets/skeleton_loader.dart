import 'package:flutter/material.dart';

/// Skeleton loader widget for loading states
/// Provides a shimmer effect while content is loading
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    Key? key,
    this.width,
    this.height = 20,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade200,
                Colors.grey.shade300,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Customer list item skeleton
class CustomerListSkeleton extends StatelessWidget {
  const CustomerListSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: SkeletonLoader(
          width: 40,
          height: 40,
          borderRadius: BorderRadius.circular(20),
        ),
        title: const SkeletonLoader(height: 16, width: 150),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 8),
            SkeletonLoader(height: 14, width: 100),
          ],
        ),
        trailing: const SkeletonLoader(
          width: 80,
          height: 32,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}

/// Transaction list item skeleton
class TransactionSkeleton extends StatelessWidget {
  const TransactionSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: SkeletonLoader(
          width: 40,
          height: 40,
          borderRadius: BorderRadius.circular(20),
        ),
        title: const SkeletonLoader(height: 16, width: 120),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 8),
            SkeletonLoader(height: 12, width: 200),
          ],
        ),
        trailing: const SkeletonLoader(height: 14, width: 100),
      ),
    );
  }
}
