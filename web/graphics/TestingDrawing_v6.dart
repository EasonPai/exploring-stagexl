import 'dart:html';
import 'dart:math';
import 'package:stagexl/stagexl.dart' as sxl;
import 'package:stats/stats.dart';
import 'dart:async';

sxl.Stage stage;
sxl.RenderLoop renderLoop = new sxl.RenderLoop();

var background;
sxl.BitmapData canvasBitmapData;
List<Point> pixels = [];
sxl.Shape _canvas;
var createLineStart = false;
StreamSubscription touchListener,touchEndListener;
int totalPoints = 0;
int CACHE_THRESHOLD = 1000;
void main() {

  // setup canvas & stage
  stage = new sxl.Stage(document.querySelector('#stage'), width: 900, height: 500);
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
  document.querySelector('#arrow').onClick.listen((e) {
   endDraw();
   touchListener = background.onMouseDown.listen((e) {
    startArrow(e.localX.toInt(), e.localY.toInt());
   });
   setButtonStateOn(e.target);
  });
  
  document.querySelector('#arrow_200').onClick.listen((e) {
   var rng = new Random();
   int lastX = 0;
   int lastY = 0;
   endDraw();
   for(var i=0;i<200;i++){
    Arrow arrow = new Arrow();
    arrow.addTo(stage);
    arrow.pointTo(lastX, lastY , lastX = rng.nextInt(900) , lastY = rng.nextInt(500));
    arrow.endDraw();
   }
  });
  document.querySelector('#pen').onClick.listen((e) {
   endDraw();
   touchListener = background.onMouseDown.listen((e) {
     startPen(e.localX.toInt(), e.localY.toInt());
   });
   setButtonStateOn(e.target);
  });
  document.querySelector('#clean').onClick.listen((e) {
   _canvas.graphics.clear();
   canvasBitmapData.clear();
   _canvas.refreshCache();
  });

  // measure the fps
  Stats stats = new Stats();
  document.querySelector('#fpsMeter').append(stats.container);
  stage.onEnterFrame.listen((sxl.EnterFrameEvent e) {
   stats.end();
   stats.begin();    
  });
  
  // init canvas
  _canvas = new sxl.Shape();
  _canvas.addTo(stage);
  canvasBitmapData = new sxl.BitmapData(900, 500);
  sxl.Bitmap drawingCache = new sxl.Bitmap(canvasBitmapData);
  drawingCache.addTo(stage);
  
  // start listener
  document.querySelector('#arrow').click();
}

startArrow(int startx, int starty) {
 Arrow arrow = new Arrow();
  arrow.addTo(stage);

  touchListener = background.onMouseMove.listen((e) {
    arrow.pointTo(startx, starty, e.localX.toInt(), e.localY.toInt());
  });
  
  touchEndListener = background.onMouseUp.listen((e) {
   touchListener.cancel();
   touchEndListener.cancel();
   arrow.endDraw();
  });
}

startPen(int startx, int starty) {
  pixels.add(new Point(startx, starty));
  
  touchListener = background.onMouseMove.listen((e) {
    drawPen( e.localX.toInt(), e.localY.toInt());
  });
  touchEndListener = background.onMouseUp.listen((e) {
    endDraw();
  });
}


drawPen(int toX, int toY) {
  pixels.add(new Point(toX, toY));
  totalPoints += 1;
  document.querySelector('#points').text = "Points: ${pixels.length.toString()}";
  document.querySelector('#totalPoints').text = "Total Points: ${totalPoints}";
  // cache vectors to bitmapdata
  if(pixels.length> CACHE_THRESHOLD ){
   endDraw();
   startPen(toX, toY);
   return;
  }
  
  _canvas.graphics.clear();
  _canvas.graphics.moveTo(pixels[0].x , pixels[0].y);
  for(int i=1;i<pixels.length;i++){
   _canvas.graphics.lineTo(pixels[i].x , pixels[i].y);
  }
  _canvas.graphics.strokeColor(sxl.Color.DimGray , 5);
}

endDraw() {
 pixels = [];
 document.querySelector('#points').text = "Points: ${pixels.length.toString()}";
  canvasBitmapData.draw(_canvas);
  _canvas.graphics.clear();
  if(touchListener!=null){
   touchListener.cancel();
  }
  if(touchEndListener!=null){
   touchEndListener.cancel();
  }
}

setButtonStateOn(Element target) {
  var btns = document.querySelectorAll('.btn');
  for (var btn in btns) {
    btn.classes.remove("active");
  }
  target.classes.add("active");
}

class Arrow extends sxl.DisplayObjectContainer{
  sxl.Shape lineVector;
  sxl.Bitmap head;
  Arrow(){
    mouseEnabled = false;            
    lineVector = new sxl.Shape();
    lineVector.applyCache(0, 0, 900, 500, debugBorder: false);
    addChild(lineVector);

    sxl.Shape headVector = new sxl.Shape();
    headVector.graphics.beginPath();
    headVector.graphics.moveTo(25 , 10);
    headVector.graphics.lineTo(0, 20);
    headVector.graphics.quadraticCurveTo( 10 ,  10, 0,0);
//    headVector.graphics.lineTo(0,0);
    headVector.graphics.lineTo(25, 10);
    headVector.graphics.closePath();
    headVector.graphics.fillColor(sxl.Color.Black);
    
    // Being tested that cache vectors with BitmapData improves performance
    sxl.BitmapData canvasBitmapData = new sxl.BitmapData(25, 20);
    canvasBitmapData.draw(headVector);
    headVector.graphics.clear();
    
    head = new sxl.Bitmap(canvasBitmapData);
    head ..pivotX = 25 ..pivotY = 10;
    addChild(head);

  }
 
  var startpoint;
  var endpoint;
  var bodyLength;
  void pointTo(int x , int y , int x2 , int y2){
    startpoint = new Point( x, y);
    endpoint = new Point( x2, y2);
    bodyLength = startpoint.distanceTo(endpoint);
    
    lineVector.graphics.clear();
    lineVector.graphics.beginPath();
    lineVector.graphics.moveTo(x, y);
    lineVector.graphics.lineTo( x2 - (head.width/bodyLength)*(x2 - x) ,y2 - (head.width/bodyLength)*(y2 - y));
    lineVector.graphics.closePath();
    lineVector.graphics.strokeColor(sxl.Color.Black, 5 , sxl.JointStyle.BEVEL , sxl.CapsStyle.SQUARE);
    lineVector.refreshCache();
    head.rotation = atan2(y2 - y  , x2 - x);
    head.x = x2;
    head.y = y2;
  }
  
  void endDraw(){
   
//   print('${lineVector.width} , ${lineVector.height}');
    sxl.BitmapData bitmapData = new sxl.BitmapData(900,500);
   bitmapData.draw(lineVector);
    sxl.Bitmap body = new sxl.Bitmap(bitmapData);
//   body ..x = startpoint.x ..y = startpoint.y;
   addChild(body);
   lineVector.graphics.clear();
   removeChild(lineVector);
   
  }
}
