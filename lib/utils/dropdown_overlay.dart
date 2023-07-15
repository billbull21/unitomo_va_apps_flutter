import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DropdownOverlay<T> extends StatefulWidget {
  final VoidCallback? onWidgetTap;
  final bool enabled;
  final bool readonly;
  final T? value;
  final List<T?> dataList;
  final double radius;
  final double borderWidth;
  final Color borderColor;
  final Color bgColor;
  final Widget Function(BuildContext context, T? singleData) itemBuilder;
  final Widget Function(
      BuildContext context, T? value, bool isOpen, bool isFocus) builder;

  const DropdownOverlay({
    Key? key,
    required this.value,
    required this.dataList,
    this.radius = 8,
    this.enabled = true,
    this.readonly = false,
    this.borderWidth = 1,
    this.bgColor = Colors.white,
    this.borderColor = Colors.grey,
    this.onWidgetTap,
    required this.itemBuilder,
    required this.builder,
  }) : super(key: key);

  @override
  State<DropdownOverlay<T>> createState() {
    return _DropdownOverlayState<T>();
  }
}

class _DropdownOverlayState<T> extends State<DropdownOverlay<T>>
    with TickerProviderStateMixin {
  // focus node object to detect gained or loss on textField
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  GlobalKey globalKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  bool isOpen = false;
  TapDownDetails? _tapDownDetails;

  @override
  void initState() {
    super.initState();
    OverlayState? overlayState = Overlay.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalKey;
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          isOpen = true;
        });
        _overlayEntry = _createOverlay();

        overlayState.insert(_overlayEntry!);
      } else {
        setState(() {
          isOpen = false;
        });
        _overlayEntry!.remove();
      }
    });
  }

  OverlayEntry _createOverlay() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;

    final pos = renderBox.localToGlobal(Offset.zero);
    final globalOffset =
    renderBox.localToGlobal(_tapDownDetails?.globalPosition ?? Offset.zero);

    // final screenRatio = MediaQuery.of(context).devicePixelRatio;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    var screenHeight = MediaQuery.of(context).size.height;
    var remainingScreenHeight = screenHeight - statusBarHeight - kToolbarHeight;

    if (kDebugMode) {
      // print("RATIO : $screenRatio");
      print("globalOffset : (${globalOffset.dx}, ${globalOffset.dy})");
      print("screen Position : (${pos.dx}, ${pos.dy})");
      print("REMAINING HEIGHT : $remainingScreenHeight");
    }
    bool isBottom = true;
    if (remainingScreenHeight - pos.dy < 200) {
      isBottom = false;
    }
    var size = renderBox.size;
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _focusNode.unfocus(),
              child: const ColoredBox(
                color: Colors.black26,
              ),
            ),
          ),
          Positioned(
            width: size.width,
            child: _DropdownBodyComponent(
              contextFocusNode: _focusNode.context ?? context,
              layerLink: _layerLink,
              widgetSize: size,
              isBottom: isBottom,
              dataList: widget.dataList,
              radius: widget.radius,
              borderWidth: widget.borderWidth,
              bgColor: widget.bgColor,
              borderColor: widget.borderColor,
              itemBuilder: widget.itemBuilder,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTapDown: widget.enabled && !widget.readonly ? (TapDownDetails tapDownDetails) {
          setState(() {
            _tapDownDetails = tapDownDetails;
          });
          if (!_focusNode.hasFocus) {
            _focusNode.requestFocus();
          } else {
            _focusNode.unfocus();
          }
          if (widget.onWidgetTap != null) widget.onWidgetTap!();
        } : widget.onWidgetTap != null ? (_) => widget.onWidgetTap!() : null,
        child: Focus(
          focusNode: _focusNode,
          child: Container(
            child: widget.builder(
              context,
              widget.value,
              isOpen,
              _focusNode.hasFocus,
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownBodyComponent<T> extends StatefulWidget {
  final BuildContext contextFocusNode;
  final LayerLink layerLink;
  final Size widgetSize;
  final bool isBottom;
  final List<T?> dataList;
  final double radius;
  final double borderWidth;
  final Color borderColor;
  final Color bgColor;
  final Widget Function(BuildContext context, T? singleData) itemBuilder;

  const _DropdownBodyComponent({
    Key? key,
    required this.contextFocusNode,
    required this.layerLink,
    required this.widgetSize,
    required this.isBottom,
    required this.dataList,
    required this.radius,
    required this.borderWidth,
    required this.bgColor,
    required this.borderColor,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  State<_DropdownBodyComponent<T>> createState() =>
      _DropdownBodyComponentState<T>();
}

class _DropdownBodyComponentState<T> extends State<_DropdownBodyComponent<T>> {
  // calculate overlayHeight to place it right on the top of widget
  double overlayHeight = 150.0; // default

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final r = context.findRenderObject() as RenderBox?;
      if (r != null) {
        setState(() {
          overlayHeight = r.size.height;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformFollower(
      link: widget.layerLink,
      showWhenUnlinked: false,
      offset: Offset(
        0.0,
        widget.isBottom ? widget.widgetSize.height : -(overlayHeight),
      ),
      child: Material(
        color: widget.bgColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.radius),
          side: BorderSide(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 200,
            ),
            child: ListView.builder(
              // physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.dataList.length,
              itemBuilder: (ctx, i) {
                final singleData = widget.dataList[i];
                return widget.itemBuilder(widget.contextFocusNode, singleData);
              },
            ),
          ),
        ),
      ),
    );
  }
}