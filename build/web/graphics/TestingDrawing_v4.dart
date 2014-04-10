import 'dart:html';
import 'package:stagexl/stagexl.dart';
import 'package:stats/stats.dart';

Stage stage;
RenderLoop renderLoop = new RenderLoop();

var background;
var mouseDownListener;
BitmapData canvasBitmapData;
List<Point> pixels = [];
Shape penCanvas;
var createLineStart = false;
var touchListener;
int totalPoints = 0;
int CACHE_THRESHOLD = 1000;
void main() {

  // setup canvas & stage
  stage = new Stage(document.querySelector('#stage'), width: 900, height: 500, webGL: false);
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
   penCanvas.graphics.clear();
   canvasBitmapData.clear();
   penCanvas.refreshCache();
  });

  // measure the fps
  Stats stats = new Stats();
  document.querySelector('#fpsMeter').append(stats.container);
  stage.onEnterFrame.listen((EnterFrameEvent e) {
   stats.end();
   stats.begin();    
  });
  
  // init canvas
  penCanvas = new Shape();
  penCanvas.addTo(stage);
  canvasBitmapData = new BitmapData(900, 500, true, 0); 
  Bitmap drawingCache = new Bitmap(canvasBitmapData);
  drawingCache.addTo(stage);
  
  // start listener
  mouseDownListener = background.onMouseDown.listen((e) {
    startStatic(e.localX.toInt(), e.localY.toInt());
   });
}

// static cache draw
startStatic(int startx, int starty) {
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
  totalPoints += 1;
  document.querySelector('#points').text = "Points: ${pixels.length.toString()}";
  document.querySelector('#totalPoints').text = "Total Points: ${totalPoints}";
  // cache vectors to bitmapdata
  if(pixels.length> CACHE_THRESHOLD ){
   endDraw();
   startStatic(toX, toY);
   return;
  }
  
  penCanvas.graphics.clear();
  penCanvas.graphics.moveTo(pixels[0].x , pixels[0].y);
  for(int i=1;i<pixels.length;i++){
   penCanvas.graphics.lineTo(pixels[i].x , pixels[i].y);
  }
  penCanvas.graphics.strokeColor(Color.DimGray , 5);
}

endDraw() {
 pixels = [];
 document.querySelector('#points').text = "Points: ${pixels.length.toString()}";
  canvasBitmapData.draw(penCanvas);
  penCanvas.graphics.clear();
  touchListener.cancel();
}

