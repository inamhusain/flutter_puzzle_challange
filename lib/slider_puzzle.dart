// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations, curly_braces_in_flow_control_structures, avoid_print, unnecessary_null_comparison, sized_box_for_whitespace, must_be_immutable

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slider_puzzle/utils.dart';

import 'package:image/image.dart' as image;

class SlidePuzzle extends StatefulWidget {
  @override
  _SlidePuzzleState createState() => _SlidePuzzleState();
}

class _SlidePuzzleState extends State<SlidePuzzle> {
  GlobalKey<_SlidePuzzleWidgetState> globalKey = GlobalKey();

  final ValueNotifier<double> valueSlider = ValueNotifier<double>(3);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double border = 5;

    return Scaffold(
      backgroundColor: AppColors.lightPurple,
      appBar: AppBar(
        backgroundColor: AppColors.strongDarkPurple,
        centerTitle: true,
        title: AutoSizeText(
          'Slider Puzzle ${valueSlider.value.round()}x${valueSlider.value.round()}'
              .toUpperCase(),
          style: TextStyle(fontSize: Utils.ratioSize(context, 7)),
          maxFontSize: 22,
        ),
        actions: [
          IconButton(
              onPressed: () => globalKey.currentState!.generatePuzzle(),
              icon: Icon(Icons.refresh))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          // height: double.maxFinite,
          // width: double.maxFinite,
          color: AppColors.lightPurple,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.lightPurple,
                    border: Border.all(
                        width: border, color: AppColors.strongDarkPurple),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        width: constraints.biggest.width,
                        child: SlidePuzzleWidget(
                          key: globalKey,
                          size: constraints.biggest,
                          sizePuzzle: valueSlider.value.round(),
                          imageBckGround: Image.asset(
                            'assets/imgBG2.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                  // child: ,
                ),
                Slider(
                  activeColor: AppColors.strongDarkPurple,
                  inactiveColor: AppColors.purple,
                  thumbColor: AppColors.strongDarkPurple,
                  min: 3,
                  max: 5,
                  divisions: 2,
                  label: "${valueSlider.value.toString()}",
                  value: valueSlider.value,
                  onChanged: (value) {
                    valueSlider.value = value;
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SlidePuzzleWidget extends StatefulWidget {
  Size? size;
  double innerPadding;
  Image? imageBckGround;
  int? sizePuzzle;
  SlidePuzzleWidget({
    Key? key,
    this.size,
    this.innerPadding = 5,
    this.imageBckGround,
    this.sizePuzzle,
  }) : super(key: key);

  @override
  _SlidePuzzleWidgetState createState() => _SlidePuzzleWidgetState();
}

class _SlidePuzzleWidgetState extends State<SlidePuzzleWidget> {
  GlobalKey _globalKey = GlobalKey();
  Size? size;

  List<SlideObject>? slideObjects;
  image.Image? fullImage;
  bool success = false;
  bool startSlide = false;
  List<int>? process;
  bool finishSwap = false;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    size = Size(widget.size!.width - widget.innerPadding * 2,
        widget.size!.width - widget.innerPadding);

    return Column(
      mainAxisSize: MainAxisSize.min,
      // let make ui
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.white),
          width: widget.size!.width,
          height: widget.size!.width,
          padding: EdgeInsets.all(widget.innerPadding),
          child: Stack(
            children: [
              if (widget.imageBckGround != null && slideObjects == null) ...[
                RepaintBoundary(
                  key: _globalKey,
                  child: Container(
                    height: double.maxFinite,
                    child: widget.imageBckGround,
                  ),
                )
              ],
              if (slideObjects != null)
                ...slideObjects!.where((slideObject) => slideObject.empty!).map(
                  (slideObject) {
                    return Positioned(
                      left: slideObject.posCurrent!.dx,
                      top: slideObject.posCurrent!.dy,
                      child: SizedBox(
                        width: slideObject.size!.width,
                        height: slideObject.size!.height,
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              color: AppColors.strongDarkPurple,
                              borderRadius: BorderRadius.circular(5)),
                          child: Stack(
                            children: [
                              if (slideObject.image != null) ...[
                                Opacity(
                                  opacity: success ? 1 : 0.3,
                                  child: slideObject.image,
                                )
                              ]
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              if (slideObjects != null)
                ...slideObjects!
                    .where((slideObject) => !slideObject.empty!)
                    .map(
                  (slideObject) {
                    return AnimatedPositioned(
                      duration: Duration(milliseconds: 400),
                      curve: Curves.fastOutSlowIn,
                      left: slideObject.posCurrent!.dx,
                      top: slideObject.posCurrent!.dy,
                      child: GestureDetector(
                        onTap: () => changePos(slideObject.indexCurrent!),
                        child: SizedBox(
                          width: slideObject.size!.width,
                          height: slideObject.size!.height,
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                // color: AppColors.strongDarkPurple,
                                borderRadius: BorderRadius.circular(5)),
                            margin: EdgeInsets.all(2),
                            child: Stack(
                              children: [
                                if (slideObject.image != null) ...[
                                  slideObject.image!
                                ],
                                Center(
                                  child: AutoSizeText(
                                    '${slideObject.indexDefault}',
                                    style: TextStyle(
                                        color: AppColors.strongDarkPurple,
                                        fontWeight: FontWeight.bold,
                                        fontSize: Utils.ratioSize(context, 8)),
                                  ),
                                ),

                                // nice one.. lets make it random
                              ],
                            ),
                            // nice one
                          ),
                        ),
                      ),
                    );
                  },
                ).toList()
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: height * 0.02, bottom: height * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MaterialButton(
                color: AppColors.strongDarkPurple,
                shape: StadiumBorder(),
                onPressed: () => generatePuzzle(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AutoSizeText(
                    'Generate',
                    maxFontSize: 25,
                    minFontSize: 15,
                    style: TextStyle(
                        color: AppColors.lightPurple,
                        fontSize: Utils.ratioSize(context, 7)),
                  ),
                ),
              ),
              // MaterialButton(
              //   color: AppColors.strongDarkPurple,
              //   shape: StadiumBorder(),
              //   onPressed: startSlide ? null : () => reversePuzzle(),
              //   child: AutoSizeText(
              //     'Solve',
              //     style: TextStyle(color: AppColors.lightPurple),
              //   ),
              // ),
              MaterialButton(
                color: AppColors.strongDarkPurple,
                shape: StadiumBorder(),
                onPressed: () => clearPuzzle(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AutoSizeText(
                    'Clear',
                    maxFontSize: 25,
                    minFontSize: 15,
                    style: TextStyle(
                        color: AppColors.lightPurple,
                        fontSize: Utils.ratioSize(context, 7)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _getImageFromWidget() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    size = boundary.size;
    var img = await boundary.toImage();
    var byteData = await img.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData!.buffer.asUint8List();

    return image.decodeImage(pngBytes);
  }

  generatePuzzle() async {
    finishSwap = false;
    setState(() {});
    if (widget.imageBckGround != null && fullImage == null)
      fullImage = await _getImageFromWidget();

    print(fullImage!.width);

    Size sizeBox = Size(
        size!.width / widget.sizePuzzle!, size!.width / widget.sizePuzzle!);

    slideObjects =
        List.generate(widget.sizePuzzle! * widget.sizePuzzle!, (index) {
      Offset offsetTemp = Offset(
        index % widget.sizePuzzle! * sizeBox.width,
        index ~/ widget.sizePuzzle! * sizeBox.height,
      );

      image.Image? tempCrop;
      if (widget.imageBckGround != null && fullImage != null)
        tempCrop = image.copyCrop(
          fullImage!,
          offsetTemp.dx.round(),
          offsetTemp.dy.round(),
          sizeBox.width.round(),
          sizeBox.height.round(),
        );

      return SlideObject(
        posCurrent: offsetTemp,
        posDefault: offsetTemp,
        indexCurrent: index,
        indexDefault: index + 1,
        size: sizeBox,
        image: tempCrop == null
            ? null
            : Image.memory(
                image.encodePng(tempCrop) as Uint8List,
                fit: BoxFit.contain,
              ),
      );
    });

    slideObjects!.last.empty = true;

    bool swap = true;
    process = [];

    for (var i = 0; i < widget.sizePuzzle! * 20; i++) {
      for (var j = 0; j < widget.sizePuzzle! / 2; j++) {
        SlideObject slideObjectEmpty = getEmptyObject();

        int emptyIndex = slideObjectEmpty.indexCurrent!;
        process!.add(emptyIndex);
        int randKey;

        if (swap) {
          int row = emptyIndex ~/ widget.sizePuzzle!;
          randKey = row * widget.sizePuzzle! +
              new Random().nextInt(widget.sizePuzzle!);
        } else {
          int col = emptyIndex % widget.sizePuzzle!;
          randKey =
              widget.sizePuzzle! * new Random().nextInt(widget.sizePuzzle!) +
                  col;
        }

        changePos(randKey);
        swap = !swap;
      }
    }

    startSlide = false;
    finishSwap = true;
    setState(() {});
  }
  // eyay.. end

  SlideObject getEmptyObject() {
    return slideObjects!.firstWhere((element) => element.empty!);
  }

  changePos(int indexCurrent) {
    SlideObject slideObjectEmpty = getEmptyObject();

    int emptyIndex = slideObjectEmpty.indexCurrent!;

    int minIndex = min(indexCurrent, emptyIndex);
    int maxIndex = max(indexCurrent, emptyIndex);

    List<SlideObject> rangeMoves = [];

    if (indexCurrent % widget.sizePuzzle! == emptyIndex % widget.sizePuzzle!) {
      rangeMoves = slideObjects!
          .where((element) =>
              element.indexCurrent! % widget.sizePuzzle! ==
              indexCurrent % widget.sizePuzzle!)
          .toList();
    } else if (indexCurrent ~/ widget.sizePuzzle! ==
        emptyIndex ~/ widget.sizePuzzle!) {
      rangeMoves = slideObjects!;
    } else {
      rangeMoves = [];
    }

    rangeMoves = rangeMoves
        .where((puzzle) =>
            puzzle.indexCurrent! >= minIndex &&
            puzzle.indexCurrent! <= maxIndex &&
            puzzle.indexCurrent != emptyIndex)
        .toList();

    if (emptyIndex < indexCurrent)
      rangeMoves.sort((a, b) => a.indexCurrent! < b.indexCurrent! ? 1 : 0);
    else
      rangeMoves.sort((a, b) => a.indexCurrent! < b.indexCurrent! ? 0 : 1);

    if (rangeMoves.length > 0) {
      int tempIndex = rangeMoves[0].indexCurrent!;

      Offset tempPos = rangeMoves[0].posCurrent!;

      for (var i = 0; i < rangeMoves.length - 1; i++) {
        rangeMoves[i].indexCurrent = rangeMoves[i + 1].indexCurrent;
        rangeMoves[i].posCurrent = rangeMoves[i + 1].posCurrent;
      }

      rangeMoves.last.indexCurrent = slideObjectEmpty.indexCurrent;
      rangeMoves.last.posCurrent = slideObjectEmpty.posCurrent;

      slideObjectEmpty.indexCurrent = tempIndex;
      slideObjectEmpty.posCurrent = tempPos;
    }

    if (slideObjects!
                .where((slideObject) =>
                    slideObject.indexCurrent == slideObject.indexDefault! - 1)
                .length ==
            slideObjects!.length &&
        finishSwap) {
      print("Success");
      success = true;
    } else {
      success = false;
    }

    startSlide = true;
    setState(() {});
  }

  clearPuzzle() {
    setState(() {
      startSlide = true;
      slideObjects = null;
      finishSwap = true;
    });
  }

  // reversePuzzle() async {
  //   startSlide = true;
  //   finishSwap = true;
  //   setState(() {});

  //   await Stream.fromIterable(process!.reversed)
  //       .asyncMap((event) async =>
  //           await Future.delayed(Duration(milliseconds: 50))
  //               .then((value) => changePos(event)))
  //       .toList();

  //   process = [];
  //   setState(() {});
  // }
}

class SlideObject {
  Offset? posDefault;
  Offset? posCurrent;
  int? indexDefault;
  int? indexCurrent;
  bool? empty;
  Size? size;
  Image? image;

  SlideObject({
    this.empty = false,
    this.image,
    this.indexCurrent,
    this.indexDefault,
    this.posCurrent,
    this.posDefault,
    this.size,
  });
}
