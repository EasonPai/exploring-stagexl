import 'dart:html';
import 'package:stagexl/stagexl.dart';
import 'package:stats/stats.dart';

Stage stage;
RenderLoop renderLoop = new RenderLoop();

var background;
var mouseDownListener;
BitmapData bitmapData;
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
  
  // init canvas
  canvas = new Shape();
  canvas.addTo(stage);
  canvas.applyCache(0, 0, 900, 500, debugBorder: true);
  bitmapData = new BitmapData(900, 500, true, 0); 
  Bitmap drawingCache = new Bitmap(bitmapData);
  drawingCache.addTo(stage);
  
  // start listener
  mouseDownListener = background.onMouseDown.listen((e) {
    startStatic(e.localX.toInt(), e.localY.toInt());
   });
}


List<Point> pixels = [];
Shape canvas;
var createLineStart = false;
var touchListener;

// static cache draw
startStatic(int startx, int starty) {
  pixels = [];
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
  
  // draw to bitmapdata
  if(pixels.length>1000){
   bitmapData.draw(canvas);
   endDraw();
   startStatic(toX, toY);
  }
  
  canvas.graphics.clear();
  for(int i=0;i<pixels.length;i++){
   if(i>1){
    canvas.graphics.moveTo(pixels[i-1].x , pixels[i-1].y);
   }
   canvas.graphics.lineTo(pixels[i].x , pixels[i].y);
  }
  canvas.graphics.strokeColor(Color.DimGray , 5);
  canvas.refreshCache();
}

endDraw() {
  touchListener.cancel();
}

