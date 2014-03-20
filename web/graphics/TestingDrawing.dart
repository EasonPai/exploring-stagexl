import 'dart:math';
import 'dart:html';
import 'package:stagexl/stagexl.dart';
import 'package:stats/stats.dart';

Stage stage;
RenderLoop renderLoop = new RenderLoop();

var background;
var mouseDownListener;
void main() {

  // setup canvas & stage
  var canvas = document.querySelector('#stage');
  stage = new Stage(canvas, width: 900, height: 500, webGL: true);
  stage.scaleMode = StageScaleMode.SHOW_ALL;
  stage.align = StageAlign.NONE;
  renderLoop.addStage(stage);

  // add bg
  background = new Sprite();
  background.graphics.beginPath();
  background.graphics.rect(0, 0, 900, 500);
  background.graphics.closePath();
  background.graphics.fillColor(Color.LightGreen);
  background.graphics.strokeColor(Color.LightGray, 5);
  background.applyCache(0, 0, 900, 500);
  background.addTo(stage);

  // setup buttons
  document.querySelector('#mode1').onClick.listen((e) {
   if(mouseDownListener!=null){
     mouseDownListener.cancel();
   }
   mouseDownListener = background.onMouseDown.listen((e) {
         startDynamic(e.localX.toInt(), e.localY.toInt());
     });
    updateButton(e.target as Element);
  });
  document.querySelector('#mode2').onClick.listen((e) {
   if(mouseDownListener!=null){
    mouseDownListener.cancel();
   }
   mouseDownListener = background.onMouseDown.listen((e) {
    startStatic(e.localX.toInt(), e.localY.toInt());
   });
   updateButton(e.target as Element);
  });
  document.querySelector('#clean').onClick.listen((e) {
   stage.removeChildren(1, stage.numChildren-1);
  });

  // measure the fps
  Stats stats = new Stats();
  document.querySelector('#fpsMeter').append(stats.container);
  stage.onEnterFrame.listen((EnterFrameEvent e) {
   stats.end();
   stats.begin();    
  });
}



Shape drawBody;
var createLineStart = false;
var touchListener;
var minx = 0;
var miny = 0;
var maxx = 0;
var maxy = 0;

// static cache draw
startStatic(int startx, int starty) {
  drawBody = new Shape();
  drawBody.addTo(stage);
  drawBody.applyCache(0, 0, 900, 500, debugBorder: true);
  touchListener = background.onMouseMove.listen((e) {
      drawStatic(startx , starty , e.localX.toInt(), e.localY.toInt());
  });
  background.onMouseUp.listen((e) {
        endDraw();
  });
}

drawStatic(int startx, int starty, int endx, int endy) {
  drawBody.graphics.lineTo(endx, endy);
  drawBody.graphics.strokeColor(Color.DimGray , 5);
  drawBody.refreshCache();
}

endDraw() {
  touchListener.cancel();
}

// dynamic cache draw
startDynamic(int startx, int starty) {
  drawBody = new Shape();
  drawBody.addTo(stage);
  touchListener = background.onMouseMove.listen((e) {
      drawDynamic(startx , starty , e.localX.toInt(), e.localY.toInt());
  });
  background.onMouseUp.listen((e) {
   endDraw();
  });
  
  // reset boundary
  minx = startx;
  miny = starty;
  maxx = startx;
  maxy = starty;
}


drawDynamic(int startx, int starty, int endx, int endy) {
 // find boundary
 if(endx < minx){
  minx = endx;
 }
 if(endy < miny){
  miny = endy;
 }
 if(endx > maxx){
  maxx = endx;
 }
 if(endy > maxy){
  maxy = endy;
 }
 
  drawBody.graphics.lineTo(endx, endy);
  drawBody.graphics.strokeColor(Color.Coral , 5);
  drawBody.applyCache(minx - 5, miny - 5, maxx - minx + 10, maxy - miny + 10, debugBorder: true);
  drawBody.refreshCache();
}

updateButton(Element target) {
  var btns = document.querySelectorAll('.btn');
  for (var btn in btns) {
    btn.classes.remove("active");
  }
  target.classes.add("active");
}

