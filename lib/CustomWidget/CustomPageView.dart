import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


//Custom PageView allowing to show an indicator at the bottom and animation
class CustomPageView extends StatefulWidget {
  PageView _pageView;
  double pageViewHeight;
  int _length;
  Color singleDotIndicatorsSelectedColor, singleDotIndicatorsDefaultColor;
  double currentPage = 0;

  CustomPageView(this._pageView, this._length,
      {this.pageViewHeight = 200,
      this.singleDotIndicatorsDefaultColor = const Color(0xFFB8B8B8),
      this.singleDotIndicatorsSelectedColor = const Color(0xFF8E8E8E)});

  _CustomPageView createState() => _CustomPageView();
}

class _CustomPageView extends State<CustomPageView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: widget.pageViewHeight, child: widget._pageView),
        SizedBox(
          height: 15,
        ),
        if (widget._length > 1)
          SingleDotIndicators(
            widget._length,
            currentPage: widget.currentPage,
            selectedColor: widget.singleDotIndicatorsSelectedColor,
            color: widget.singleDotIndicatorsDefaultColor,
          )
      ],
    );
  }

  @override
  void initState() {
    widget._pageView.controller.addListener(() {
      setState(() {
        widget.currentPage = widget._pageView.controller.page.toDouble();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _animateSlider());
  }

  void _animateSlider() {
    Future.delayed(Duration(seconds: 5)).then((_) {
      int nextPage = widget._pageView.controller.page.round() + 1;

      if (nextPage == widget._length) {
      nextPage = 0;
      }

      widget._pageView.controller
          .animateToPage(nextPage, duration: Duration(seconds: 1), curve: Curves.linear)
          .then((_) => _animateSlider());
    });
  }
}

class SingleDotIndicators extends StatefulWidget {
  double currentPage;
  int length;
  Color selectedColor, color;

  SingleDotIndicators(this.length,
      {this.currentPage = 0, this.selectedColor, this.color});

  _SingleDotIndicators createState() => _SingleDotIndicators();
}

class _SingleDotIndicators extends State<SingleDotIndicators> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < widget.length; i++)
              Indicator(i == widget.currentPage ? true : false)
          ],
        ));
  }

  Widget Indicator(bool selected) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 3),
        height: selected ? 9 : 7,
        width: selected ? 9 : 7,
        decoration: BoxDecoration(
            color: selected ? widget.selectedColor : widget.color,
            shape: BoxShape.circle));
  }
}
