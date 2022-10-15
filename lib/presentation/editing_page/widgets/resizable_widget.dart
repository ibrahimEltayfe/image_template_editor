import 'package:flutter/material.dart';
import 'package:image_manipulate/presentation/editing_page/view_model/editing_view_model.dart';

class ResizableWidget extends StatefulWidget {
  final Widget child;
  final double ballDiameter;
  final int index;
  final EditingViewModel editingViewModel;
  final bool isResizable;
  const ResizableWidget({
    super.key,
    required this.index,
    required this.child,
    required this.ballDiameter,
    required this.editingViewModel,
    required this.isResizable
  });

  @override
  _ResizableWidgetState createState() => _ResizableWidgetState();
}

class _ResizableWidgetState extends State<ResizableWidget> {
  late double height;
  late double width;
  late double top;
  late double left;
  late double ballDiameter;

  @override
  void initState() {
    height = widget.editingViewModel.imageList[widget.index].height;
    width =  widget.editingViewModel.imageList[widget.index].width;
    top = widget.editingViewModel.imageList[widget.index].top;
    left = widget.editingViewModel.imageList[widget.index].left;

    ballDiameter = widget.ballDiameter;
    super.initState();
  }
  double initX = 0;
  double initY = 0;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;

      setState(() {
        top = top + dy;
        left = left + dx;
      });
  }
  //todo:do refactor
  _saveValuesOnEnd(DragEndDetails d){
    widget.editingViewModel.imageList[widget.index].height = height;
    widget.editingViewModel.imageList[widget.index].width = width;
    widget.editingViewModel.imageList[widget.index].top = top;
    widget.editingViewModel.imageList[widget.index].left = left;
  }
  @override
  Widget build(BuildContext context) {
    return widget.isResizable
      ? Stack(
      children: <Widget>[
        Positioned(
          top: top,
          left: left,
          child: GestureDetector(
            onPanStart: _handleDrag,
            onPanUpdate: _handleUpdate,
            onPanEnd: _saveValuesOnEnd,
            child: SizedBox(
              height: height,
              width: width,
              child: widget.child,
            ),
          ),
        ),
        // top left
        Positioned(
          top: top - ballDiameter / 2,
          left: left - ballDiameter / 2,
          child: ManipulatingBall(
            ballDiameter: ballDiameter,
            onEnd:  _saveValuesOnEnd,
            onDrag: (dx, dy) {
              var mid = (dx + dy) / 2;
              var newHeight = height - 2 * mid;
              var newWidth = width - 2 * mid;
              setState(() {
                height = newHeight > 40 ? newHeight : 40;
                width = newWidth > 40 ? newWidth : 40;
                top = top + mid;
                left = left + mid;
              });

            },
          ),
        ),
        // top middle
        Positioned(
          top: top - ballDiameter / 2,
          left: left + width / 2 - ballDiameter / 2,
          child: ManipulatingBall(
            ballDiameter: ballDiameter,
            onEnd:  _saveValuesOnEnd,
            onDrag: (dx, dy) {
              var newHeight = height - dy;

              setState(() {
                height = newHeight > 40 ? newHeight : 40;
                top = top + dy;
              });

            },
          ),
        ),
        // top right
        Positioned(
          top: top - ballDiameter / 2,
          left: left + width - ballDiameter / 2,
          child: ManipulatingBall(
            ballDiameter: ballDiameter,
            onEnd:  _saveValuesOnEnd,
            onDrag: (dx, dy) {
              var mid = (dx + (dy * -1)) / 2;

              var newHeight = height + 2 * mid;
              var newWidth = width + 2 * mid;

              setState(() {
                height = newHeight > 40 ? newHeight : 40;
                width = newWidth > 40 ? newWidth : 40;
                top = top - mid;
                left = left - mid;
              });
            },
          ),
        ),
        // center right
        Positioned(
          top: top + height / 2 - ballDiameter / 2,
          left: left + width - ballDiameter / 2,
          child: ManipulatingBall(
            onEnd:  _saveValuesOnEnd,
            ballDiameter: ballDiameter,
            onDrag: (dx, dy) {
              var newWidth = width + dx;

              setState(() {
                width = newWidth > 40 ? newWidth : 40;
              });
            },
          ),
        ),
        // bottom right
        Positioned(
          top: top + height - ballDiameter / 2,
          left: left + width - ballDiameter / 2,
          child: ManipulatingBall(
            ballDiameter: ballDiameter,
            onEnd:  _saveValuesOnEnd,
            onDrag: (dx, dy) {
              var mid = (dx + dy) / 2;

              var newHeight = height + 2 * mid;
              var newWidth = width + 2 * mid;

              setState(() {
                height = newHeight > 40 ? newHeight : 40;
                width = newWidth > 40 ? newWidth : 40;
                top = top - mid;
                left = left - mid;
              });
            },
          ),
        ),
        // bottom center
        Positioned(
          top: top + height - ballDiameter / 2,
          left: left + width / 2 - ballDiameter / 2,
          child: ManipulatingBall(
            ballDiameter: ballDiameter,
            onEnd:  _saveValuesOnEnd,
            onDrag: (dx, dy) {
              var newHeight = height + dy;

              setState(() {
                height = newHeight > 40 ? newHeight : 40;
              });

            },
          ),
        ),
        // bottom left
        Positioned(
          top: top + height - ballDiameter / 2,
          left: left - ballDiameter / 2,
          child: ManipulatingBall(
            ballDiameter: ballDiameter,
            onEnd:  _saveValuesOnEnd,
            onDrag: (dx, dy) {
              var mid = ((dx * -1) + dy) / 2;

              var newHeight = height + 2 * mid;
              var newWidth = width + 2 * mid;

              setState(() {
                height = newHeight > 40 ? newHeight : 40;
                width = newWidth > 40 ? newWidth : 40;
                top = top - mid;
                left = left - mid;
              });

            },
          ),
        ),
        //left center
        Positioned(
          top: top + height / 2 - ballDiameter / 2,
          left: left - ballDiameter / 2,
          child: ManipulatingBall(
            ballDiameter: ballDiameter,
            onEnd:  _saveValuesOnEnd,
            onDrag: (dx, dy) {
              var newWidth = width - dx;

              setState(() {
                width = newWidth > 40 ? newWidth : 40;
                left = left + dx;
              });

            },
          ),
        ),
        // center center
        Positioned(
          top: top + height / 2 - ballDiameter / 2,
          left: left + width / 2 - ballDiameter / 2,
          child: ManipulatingBall(
            ballDiameter: ballDiameter,
            onEnd: _saveValuesOnEnd,
            onDrag: (dx, dy) {
              setState(() {
                top = top + dy;
                left = left + dx;
              });

            },
          ),
        ),
      ],
    )
      : Stack(
      children: [
        Positioned(
            top: top,
            left: left,
            child: GestureDetector(
                  onTap:(){
                    widget.editingViewModel.changeSelectedImageIndex(widget.index);
                  },

              child: SizedBox(
                width: width,
                  height:height,
                  child: FittedBox(
                      fit: BoxFit.fill,
                      child: widget.child
                  )
              ),
            )
        )
      ],
    );
  }
}

class ManipulatingBall extends StatefulWidget {
  final double ballDiameter;
  final Function onDrag;
  final void Function(DragEndDetails) onEnd;
  const ManipulatingBall({super.key, required this.onDrag, required this.ballDiameter, required this.onEnd});

  @override
  _ManipulatingBallState createState() => _ManipulatingBallState();
}

class _ManipulatingBallState extends State<ManipulatingBall> {
  late double ballDiameter;
  double initX = 0;
  double initY = 0;

  @override
  void initState() {
    ballDiameter = widget.ballDiameter;
    super.initState();
  }

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      onPanEnd: widget.onEnd,
      child: Container(
        width: ballDiameter,
        height: ballDiameter,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
          shape: BoxShape.rectangle,
        ),
      ),
    );
  }
}