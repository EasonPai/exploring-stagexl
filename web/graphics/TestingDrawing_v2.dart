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
  
  document.querySelector('#mode2').click();
}


List<Point> pixels = [];
Shape drawBody;
var createLineStart = false;
var touchListener;
var minx = 0;
var miny = 0;
var maxx = 0;
var maxy = 0;

// static cache draw
startStatic(int startx, int starty) {
  pixels = [];
  
  drawBody = new Shape();
  drawBody.addTo(stage);
  drawBody.applyCache(0, 0, 900, 500, debugBorder: true);
  pixels.add(new Point(startx, starty));
  touchListener = background.onMouseMove.listen((e) {
      drawStatic( e.localX.toInt(), e.localY.toInt());
  });
  background.onMouseUp.listen((e) {
        endDraw();
  });
}

drawStatic(int toX, int toY) {
  // drawBody.graphics.moveTo(endx, endy);
  pixels.add(new Point(toX, toY));
  print("pixels > ${pixels.length}");
  drawBody.graphics.clear();
  for(int i=0;i<pixels.length;i++){
   if(i>1){
//    print("move: ${pixels[i-1].x},  ${pixels[i-1].y}");
    drawBody.graphics.moveTo(pixels[i-1].x , pixels[i-1].y);
   }
//   print("line: ${pixels[i].x},  ${pixels[i].y}");
   drawBody.graphics.lineTo(pixels[i].x , pixels[i].y);
  }
  drawBody.graphics.strokeColor(Color.DimGray , 5);
  drawBody.refreshCache();
}

endDraw() {
  touchListener.cancel();
}


updateButton(Element target) {
  var btns = document.querySelectorAll('.btn');
  for (var btn in btns) {
    btn.classes.remove("active");
  }
  target.classes.add("active");
}

