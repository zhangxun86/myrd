// Android平台dynamic_layouts占位符
import 'package:flutter/material.dart';

class DynamicGridView extends StatelessWidget {
  final ScrollController? controller;
  final SliverGridDelegate gridDelegate;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  
  const DynamicGridView.builder({
    Key? key,
    this.controller,
    required this.gridDelegate,
    required this.itemBuilder,
    required this.itemCount,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
      gridDelegate: gridDelegate,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
    );
  }
}

class SliverGridDelegateWithWrapping extends SliverGridDelegate {
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final int? crossAxisCount;
  
  const SliverGridDelegateWithWrapping({
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.crossAxisCount,
  });
  
  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final int crossAxisCount = this.crossAxisCount ?? 2;
    final double usableCrossAxisExtent = constraints.crossAxisExtent;
    final double childCrossAxisExtent = (usableCrossAxisExtent - (crossAxisCount - 1) * crossAxisSpacing) / crossAxisCount;
    final double childMainAxisExtent = childCrossAxisExtent / childAspectRatio;
    
    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: false,
    );
  }
  
  @override
  bool shouldRelayout(SliverGridDelegateWithWrapping oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.childAspectRatio != childAspectRatio;
  }
}