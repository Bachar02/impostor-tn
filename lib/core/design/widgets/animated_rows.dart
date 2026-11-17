import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_motion.dart';

/// A column of rows that animates additions and removals
/// (`listItemIn` / `listItemOut`, PUB-05 interactions): a new row fades in
/// and rises 8 and is scrolled into view; a removed row fades and collapses,
/// gap included. Rows present at the first build appear at once. With
/// reduced motion every change is instant.
class AnimatedRows<T> extends StatefulWidget {
  const AnimatedRows({
    super.key,
    required this.items,
    required this.idOf,
    required this.builder,
    this.gap = 0,
  });

  final List<T> items;

  /// A stable identity per item.
  final Object Function(T item) idOf;
  final Widget Function(BuildContext context, T item, int index) builder;

  /// Space under each row.
  final double gap;

  @override
  State<AnimatedRows<T>> createState() => _AnimatedRowsState<T>();
}

final class _Row<T> {
  _Row(this.id, this.item, this.index, this.controller)
    : animation = CurvedAnimation(
        parent: controller,
        curve: TesskraCurves.enter,
        reverseCurve: TesskraCurves.exit,
      );

  final Object id;
  T item;
  int index;
  final AnimationController controller;
  final CurvedAnimation animation;
  final key = GlobalKey();
  bool removing = false;

  void dispose() {
    animation.dispose();
    controller.dispose();
  }
}

class _AnimatedRowsState<T> extends State<AnimatedRows<T>>
    with TickerProviderStateMixin {
  late List<_Row<T>> _rows = [
    for (final (index, item) in widget.items.indexed)
      _row(item, index, value: 1),
  ];

  _Row<T> _row(T item, int index, {required double value}) => _Row(
    widget.idOf(item),
    item,
    index,
    AnimationController(
      vsync: this,
      value: value,
      duration: TesskraMotion.listItemIn,
      reverseDuration: TesskraMotion.listItemOut,
    ),
  );

  @override
  void didUpdateWidget(AnimatedRows<T> old) {
    super.didUpdateWidget(old);
    final reduced = MediaQuery.disableAnimationsOf(context);
    final byId = {for (final row in _rows) row.id: row};
    final kept = <_Row<T>>[];
    _Row<T>? added;
    for (final (index, item) in widget.items.indexed) {
      final row = byId.remove(widget.idOf(item));
      if (row == null) {
        added = _row(item, index, value: reduced ? 1 : 0);
        kept.add(added);
        if (!reduced) added.controller.forward();
        continue;
      }
      row
        ..item = item
        ..index = index;
      if (row.removing) {
        row.removing = false;
        row.controller.forward();
      }
      kept.add(row);
    }

    // Removed rows stay where they were until they have collapsed.
    final next = [...kept];
    for (final (position, row) in _rows.indexed) {
      if (!byId.containsKey(row.id)) continue;
      if (reduced) {
        row.dispose();
        continue;
      }
      final before = _rows
          .take(position)
          .lastWhere(next.contains, orElse: () => row);
      next.insert(identical(before, row) ? 0 : next.indexOf(before) + 1, row);
      if (!row.removing) {
        row.removing = true;
        row.controller.reverse().whenComplete(() => _drop(row));
      }
    }
    _rows = next;

    if (added case final row?) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = row.key.currentContext;
        if (context == null || !context.mounted) return;
        Scrollable.ensureVisible(
          context,
          duration: reduced ? Duration.zero : TesskraMotion.listItemIn,
          curve: TesskraCurves.standard,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      });
    }
  }

  void _drop(_Row<T> row) {
    if (!mounted || !row.removing) return;
    setState(() => _rows.remove(row));
    row.dispose();
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final row in _rows)
          KeyedSubtree(
            key: ValueKey(row.id),
            child: IgnorePointer(
              ignoring: row.removing,
              child: ExcludeSemantics(
                excluding: row.removing,
                child: SizeTransition(
                  sizeFactor: row.removing
                      ? row.animation
                      : kAlwaysCompleteAnimation,
                  alignment: AlignmentDirectional.topCenter,
                  child: FadeTransition(
                    opacity: row.animation,
                    child: AnimatedBuilder(
                      animation: row.animation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(
                          0,
                          row.removing
                              ? 0
                              : TesskraMotion.listItemRise *
                                    (1 - row.animation.value),
                        ),
                        child: child,
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(bottom: widget.gap),
                        child: KeyedSubtree(
                          key: row.key,
                          child: widget.builder(context, row.item, row.index),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
