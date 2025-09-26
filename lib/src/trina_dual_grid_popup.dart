import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

/// [TrinaDualGridPopup] can connect the keyboard movement between the two grids
/// by arranging two [TrinaGrid] left and right.
/// It works as a popup.
class TrinaDualGridPopup {
  final BuildContext context;

  final TrinaDualGridProps gridPropsA;

  final TrinaDualGridProps gridPropsB;

  final TrinaGridMode mode;

  final TrinaDualOnSelectedEventCallback? onSelected;

  final TrinaDualGridDisplay? display;

  final double? width;

  final double? height;

  final TrinaDualGridDivider? divider;

  TrinaDualGridPopup({
    required this.context,
    required this.gridPropsA,
    required this.gridPropsB,
    this.mode = TrinaGridMode.normal,
    this.onSelected,
    this.display,
    this.width,
    this.height,
    this.divider,
  }) {
    open();
  }

  Future<void> open() async {
    final textDirection = Directionality.of(context);

    final splitBorderRadius = _splitBorderRadius(textDirection);

    final shape = _getShape(splitBorderRadius);

    final propsA = _applyBorderRadiusToGridProps(
      splitBorderRadius.elementAt(0),
      gridPropsA,
    );

    final propsB = _applyBorderRadiusToGridProps(
      splitBorderRadius.elementAt(1),
      gridPropsB,
    );

    TrinaDualOnSelectedEvent? selected =
        await showDialog<TrinaDualOnSelectedEvent>(
          context: context,
          builder: (BuildContext ctx) {
            return Dialog(
              shape: shape,
              child: LayoutBuilder(
                builder: (ctx, size) {
                  return SizedBox(
                    width:
                        (width ?? size.maxWidth) +
                        TrinaGridSettings.gridInnerSpacing,
                    height: height ?? size.maxHeight,
                    child: Directionality(
                      textDirection: textDirection,
                      child: TrinaDualGrid(
                        gridPropsA: propsA,
                        gridPropsB: propsB,
                        mode: mode,
                        onSelected: (TrinaDualOnSelectedEvent event) {
                          Navigator.pop(ctx, event);
                        },
                        display: display ?? TrinaDualGridDisplayRatio(),
                        divider: divider ?? const TrinaDualGridDivider(),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
    if (onSelected != null && selected != null) {
      onSelected!(selected);
    }
  }

  List<BorderRadius> _splitBorderRadius(TextDirection textDirection) {
    final left = gridPropsA.configuration.style.gridBorderRadius.resolve(
      TextDirection.ltr,
    );

    final right = gridPropsB.configuration.style.gridBorderRadius.resolve(
      TextDirection.ltr,
    );

    return [
      BorderRadiusDirectional.only(
        topStart: left.topLeft,
        bottomStart: left.bottomLeft,
        topEnd: Radius.zero,
        bottomEnd: Radius.zero,
      ).resolve(textDirection),
      BorderRadiusDirectional.only(
        topStart: Radius.zero,
        bottomStart: Radius.zero,
        topEnd: right.topRight,
        bottomEnd: right.bottomRight,
      ).resolve(textDirection),
    ];
  }

  ShapeBorder _getShape(List<BorderRadius> borderRadius) {
    return RoundedRectangleBorder(
      borderRadius: borderRadius.elementAt(0) + borderRadius.elementAt(1),
    );
  }

  TrinaDualGridProps _applyBorderRadiusToGridProps(
    BorderRadius borderRadius,
    TrinaDualGridProps gridProps,
  ) {
    return gridProps.copyWith(
      configuration: gridProps.configuration.copyWith(
        style: gridProps.configuration.style.copyWith(
          gridBorderRadius: borderRadius,
        ),
      ),
    );
  }
}
