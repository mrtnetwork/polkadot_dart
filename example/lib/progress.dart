import 'package:flutter/material.dart';

typedef WBuilder = Widget? Function(BuildContext context);

class ProgressWidget extends StatelessWidget {
  const ProgressWidget({required this.child, required this.enable, super.key});
  final bool enable;
  final WBuilder child;
  @override
  Widget build(BuildContext context) {
    return ConditionalWidget(widgets: {
      true: child,
      false: (context) => const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
            ],
          )
    }, enable: enable);
  }
}

class ConditionalWidget<T> extends StatelessWidget {
  const ConditionalWidget(
      {required this.widgets, required this.enable, super.key});
  final Map<T, WBuilder> widgets;
  final T enable;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _Wrap(widgets[enable]?.call(context) ?? const SizedBox(),
          key: ValueKey<T>(enable)),
    );
  }
}

class _Wrap extends StatelessWidget {
  const _Wrap(this.child, {super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
