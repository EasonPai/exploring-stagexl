import 'dart:html';
import 'package:stats/stats.dart';
import 'package:stagexl/stagexl.dart' as sxl;

sxl.Stage stage;
sxl.RenderLoop renderLoop = new sxl.RenderLoop();

var background;
var mouseDownListener;
void main() {

  // setup canvas & stage
  var canvas = document.querySelector('#stage');
  stage = new sxl.Stage(canvas, width: 900, height: 500);
  stage.scaleMode = sxl.StageScaleMode.SHOW_ALL;
  stage.align = sxl.StageAlign.NONE;
  renderLoop.addStage(stage);

  // add bg
  background = new sxl.Sprite();
  background.graphics.beginPath();
  background.graphics.rect(0, 0, 900, 500);
  background.graphics.closePath();
  background.graphics.fillColor(sxl.Color.LightGreen);
  background.graphics.strokeColor(sxl.Color.LightGray, 5);
  background.applyCache(0, 0, 900, 500);
  background.addTo(stage);

  // setup buttons
  document.querySelector('#clean').onClick.listen((e) {
   stage.removeChildren(1, stage.numChildren-1);
  });

  // measure the fps
  Stats stats = new Stats();
  document.querySelector('#fpsMeter').append(stats.container);
  stage.onEnterFrame.listen((sxl.EnterFrameEvent e) {
   stats.end();
   stats.begin();    
  });
  
  mouseDownListener = background.onMouseDown.listen((e) {
      startStatic(e.localX.toInt(), e.localY.toInt());
  });
  
}


List<Point> pixels = [];
sxl.Shape drawBody;
var createLineStart = false;
var touchListener;

// static cache draw
startStatic(int startx, int starty) {
  pixels = [];
  
  drawBody = new sxl.Shape();
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
  pixels.add(new Point(toX, toY));
  print("pixel length > ${pixels.length}");
  
  if(pixels.length>1000){
   
  }
  
  drawBody.graphics.clear();
  for(int i=0;i<pixels.length;i++){
   if(i>1){
    drawBody.graphics.moveTo(pixels[i-1].x , pixels[i-1].y);
   }
   drawBody.graphics.lineTo(pixels[i].x , pixels[i].y);
  }
  drawBody.graphics.strokeColor(sxl.Color.DimGray , 5);
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

