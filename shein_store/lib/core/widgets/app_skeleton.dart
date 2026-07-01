import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

enum AppLoadingLayout {
  marketplace,
  productGrid,
  category,
  list,
  detail,
  dashboard,
}

class AppSkeletonLayout extends StatelessWidget {
  const AppSkeletonLayout({
    super.key,
    this.layout = AppLoadingLayout.marketplace,
    this.message,
  });

  final AppLoadingLayout layout;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Skeletonizer.zone(
      containersColor: colors.surfaceSoft,
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.fromSTEB(
          AppSizes.lg,
          AppSizes.lg,
          AppSizes.lg,
          MediaQuery.paddingOf(context).bottom + AppSizes.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message != null) ...[
              Text(
                message!,
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.md),
            ],
            switch (layout) {
              AppLoadingLayout.marketplace => const _MarketplaceSkeleton(),
              AppLoadingLayout.productGrid => const _ProductGridSkeleton(),
              AppLoadingLayout.category => const _CategorySkeleton(),
              AppLoadingLayout.list => const _ListSkeleton(),
              AppLoadingLayout.detail => const _DetailSkeleton(),
              AppLoadingLayout.dashboard => const _DashboardSkeleton(),
            },
          ],
        ),
      ),
    );
  }
}

class _MarketplaceSkeleton extends StatelessWidget {
  const _MarketplaceSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SearchSkeleton(),
        const SizedBox(height: AppSizes.md),
        const _HorizontalBones(count: 6, height: 44, widths: [72, 96, 82, 74]),
        const SizedBox(height: AppSizes.lg),
        const _CardBone(height: 210, radius: 28),
        const SizedBox(height: AppSizes.md),
        const Center(child: _PillDots()),
        const SizedBox(height: AppSizes.lg),
        Row(
          children: [
            Expanded(child: _ServiceBone()),
            const SizedBox(width: AppSizes.md),
            Expanded(child: _ServiceBone()),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        const _CategoryIconRow(),
        const SizedBox(height: AppSizes.xl),
        const _ProductGridSkeleton(itemCount: 4),
      ],
    );
  }
}

class _ProductGridSkeleton extends StatelessWidget {
  const _ProductGridSkeleton({this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 620 ? 3 : 2;

        return Column(
          children: [
            const _HorizontalBones(
              count: 5,
              height: 42,
              widths: [110, 84, 92, 84, 112],
            ),
            const SizedBox(height: AppSizes.lg),
            const _ToolbarSkeleton(),
            const SizedBox(height: AppSizes.lg),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSizes.md,
                mainAxisSpacing: AppSizes.md,
                childAspectRatio: 0.58,
              ),
              itemBuilder: (context, index) => const _ProductCardSkeleton(),
            ),
          ],
        );
      },
    );
  }
}

class _CategorySkeleton extends StatelessWidget {
  const _CategorySkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SearchSkeleton(),
        const SizedBox(height: AppSizes.md),
        const _HorizontalBones(count: 5, height: 40, widths: [70, 86, 74, 70]),
        const SizedBox(height: AppSizes.lg),
        SizedBox(
          height: 620,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 112,
                child: Column(
                  children: List.generate(
                    8,
                    (index) => const Padding(
                      padding: EdgeInsets.only(bottom: AppSizes.md),
                      child: _SideMenuBone(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.lg),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LineBone(width: 190, height: 30),
                    SizedBox(height: AppSizes.lg),
                    _RoundGridSkeleton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        6,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSizes.md),
          child: _ListTileSkeleton(),
        ),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CardBone(height: 430, radius: 28),
        const SizedBox(height: AppSizes.xl),
        const _LineBone(width: 260, height: 34),
        const SizedBox(height: AppSizes.sm),
        const _LineBone(width: 170, height: 22),
        const SizedBox(height: AppSizes.lg),
        const _HorizontalBones(count: 3, height: 48, widths: [110, 96, 120]),
        const SizedBox(height: AppSizes.xl),
        Row(
          children: [
            Expanded(child: _CardBone(height: 72, radius: 18)),
            const SizedBox(width: AppSizes.md),
            Expanded(child: _CardBone(height: 72, radius: 18)),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        const _CardBone(height: 180, radius: 24),
      ],
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CardBone(height: 300, radius: 30),
        const SizedBox(height: AppSizes.lg),
        const _LineBone(width: 230, height: 30),
        const SizedBox(height: AppSizes.sm),
        const _LineBone(width: 300, height: 18),
        const SizedBox(height: AppSizes.lg),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (_, _) => const SizedBox(width: AppSizes.md),
            itemBuilder: (_, _) => const SizedBox(
              width: 160,
              child: _CardBone(height: 150, radius: 22),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        const _ListSkeleton(),
      ],
    );
  }
}

class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _CardBone(radius: 14)),
          SizedBox(height: AppSizes.md),
          _LineBone(width: double.infinity, height: 16),
          SizedBox(height: AppSizes.sm),
          _LineBone(width: 112, height: 16),
          SizedBox(height: AppSizes.md),
          _LineBone(width: 92, height: 22),
          SizedBox(height: AppSizes.sm),
          _LineBone(width: 128, height: 14),
        ],
      ),
    );
  }
}

class _RoundGridSkeleton extends StatelessWidget {
  const _RoundGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.lg,
        mainAxisSpacing: AppSizes.lg,
        childAspectRatio: 0.86,
      ),
      itemBuilder: (_, _) => const Column(
        children: [
          Bone.circle(size: 86),
          SizedBox(height: AppSizes.sm),
          _LineBone(width: 88, height: 16),
        ],
      ),
    );
  }
}

class _CategoryIconRow extends StatelessWidget {
  const _CategoryIconRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, _) => const SizedBox(width: AppSizes.lg),
        itemBuilder: (_, _) => const SizedBox(
          width: 76,
          child: Column(
            children: [
              Bone.square(size: 70, uniRadius: 18),
              SizedBox(height: AppSizes.sm),
              _LineBone(width: 62, height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceBone extends StatelessWidget {
  const _ServiceBone();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: const Row(
        children: [
          Bone.square(size: 42, uniRadius: 12),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LineBone(width: double.infinity, height: 16),
                SizedBox(height: AppSizes.sm),
                _LineBone(width: 74, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarSkeleton extends StatelessWidget {
  const _ToolbarSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: const Row(
        children: [
          Expanded(child: _LineBone(width: double.infinity, height: 22)),
          SizedBox(width: AppSizes.xl),
          Bone.icon(size: 28),
          SizedBox(width: AppSizes.xl),
          Bone.icon(size: 28),
        ],
      ),
    );
  }
}

class _ListTileSkeleton extends StatelessWidget {
  const _ListTileSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: const Row(
        children: [
          Bone.square(size: 64, uniRadius: 16),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LineBone(width: double.infinity, height: 18),
                SizedBox(height: AppSizes.sm),
                _LineBone(width: 150, height: 15),
                SizedBox(height: AppSizes.md),
                _LineBone(width: 96, height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideMenuBone extends StatelessWidget {
  const _SideMenuBone();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Bone.icon(size: 22),
        SizedBox(width: AppSizes.sm),
        Expanded(child: _LineBone(width: double.infinity, height: 16)),
      ],
    );
  }
}

class _SearchSkeleton extends StatelessWidget {
  const _SearchSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: const Row(
        children: [
          Bone.icon(size: 26),
          SizedBox(width: AppSizes.md),
          Expanded(child: _LineBone(width: double.infinity, height: 18)),
        ],
      ),
    );
  }
}

class _HorizontalBones extends StatelessWidget {
  const _HorizontalBones({
    required this.count,
    required this.height,
    required this.widths,
  });

  final int count;
  final double height;
  final List<double> widths;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(width: AppSizes.sm),
        itemBuilder: (_, index) => Bone(
          width: widths[index % widths.length],
          height: height,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}

class _PillDots extends StatelessWidget {
  const _PillDots();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Bone(width: 38, height: 10, uniRadius: 10),
        SizedBox(width: 8),
        Bone.circle(size: 10),
        SizedBox(width: 8),
        Bone.circle(size: 10),
      ],
    );
  }
}

class _CardBone extends StatelessWidget {
  const _CardBone({this.height, this.radius = 18});

  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Bone(
      width: double.infinity,
      height: height,
      borderRadius: BorderRadius.circular(radius),
    );
  }
}

class _LineBone extends StatelessWidget {
  const _LineBone({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Bone(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(height / 2),
    );
  }
}
