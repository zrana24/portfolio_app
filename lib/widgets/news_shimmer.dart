import 'package:flutter/material.dart';

class NewsShimmer extends StatelessWidget {
  const NewsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: double.infinity,
            height: size.height * 0.28,
            borderRadius: size.width * 0.05,
          ),
          SizedBox(height: size.height * 0.03),

          ShimmerBox(
            width: size.width * 0.4,
            height: size.height * 0.025,
            borderRadius: 8,
          ),
          SizedBox(height: size.height * 0.015),

          Row(
            children: [
              Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: size.height * 0.2,
                  borderRadius: size.width * 0.04,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: size.height * 0.2,
                  borderRadius: size.width * 0.04,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.012),

          Row(
            children: [
              Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: size.height * 0.2,
                  borderRadius: size.width * 0.04,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: size.height * 0.2,
                  borderRadius: size.width * 0.04,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
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
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE5E7EB),
                Color(0xFFF3F4F6),
                Color(0xFFE5E7EB),
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

class NewsDetailShimmer extends StatelessWidget {
  const NewsDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.015),

          ShimmerBox(
            width: size.width * 0.25,
            height: size.height * 0.025,
            borderRadius: size.width * 0.02,
          ),
          SizedBox(height: size.height * 0.012),

          ShimmerBox(
            width: double.infinity,
            height: size.height * 0.04,
            borderRadius: 8,
          ),
          SizedBox(height: size.height * 0.008),
          ShimmerBox(
            width: size.width * 0.7,
            height: size.height * 0.04,
            borderRadius: 8,
          ),
          SizedBox(height: size.height * 0.012),

          ShimmerBox(
            width: size.width * 0.5,
            height: size.height * 0.02,
            borderRadius: 6,
          ),
          SizedBox(height: size.height * 0.02),

          ShimmerBox(
            width: double.infinity,
            height: size.height * 0.25,
            borderRadius: size.width * 0.04,
          ),
          SizedBox(height: size.height * 0.02),

          ShimmerBox(
            width: double.infinity,
            height: size.height * 0.015,
            borderRadius: 6,
          ),
          SizedBox(height: size.height * 0.008),
          ShimmerBox(
            width: double.infinity,
            height: size.height * 0.015,
            borderRadius: 6,
          ),
          SizedBox(height: size.height * 0.008),
          ShimmerBox(
            width: size.width * 0.8,
            height: size.height * 0.015,
            borderRadius: 6,
          ),
          SizedBox(height: size.height * 0.012),
          ShimmerBox(
            width: double.infinity,
            height: size.height * 0.015,
            borderRadius: 6,
          ),
          SizedBox(height: size.height * 0.008),
          ShimmerBox(
            width: double.infinity,
            height: size.height * 0.015,
            borderRadius: 6,
          ),
        ],
      ),
    );
  }
}