import 'dart:html';
import 'package:stagexl/stagexl.dart';
import 'package:stats/stats.dart';
import 'dart:math';
import 'dart:async';

Stage stage;
RenderLoop renderLoop = new RenderLoop();

var background;
BitmapData canvasBitmapData;
List<Point> pixels = [];
Shape _canvas;
var createLineStart = false;
StreamSubscription touchListener;
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
  document.querySelector('#arrow').onClick.listen((e) {
   endDraw();
   touchListener = background.onMouseDown.listen((e) {
    startArrow(e.localX.toInt(), e.localY.toInt());
   });
   setButtonStateOn(e.target);
  });
  document.querySelector('#arrow_200').onClick.listen((e) {
   endDraw();
   for(var i=0;i<200;i++){
    Arrow arrow = new Arrow();
    arrow.addTo(stage);
    arrow.pointTo(0, i*3 , 860 , i*3);
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
  stage.onEnterFrame.listen((EnterFrameEvent e) {
   stats.end();
   stats.begin();    
  });
  
  // init canvas
  _canvas = new Shape();
  _canvas.addTo(stage);
  canvasBitmapData = new BitmapData(900, 500, true, 0); 
  Bitmap drawingCache = new Bitmap(canvasBitmapData);
  drawingCache.addTo(stage);
  
  // start listener
  document.querySelector('#arrow').click();
}

startArrow(int startx, int starty) {
 // create body
 Arrow arrow = new Arrow();
  arrow.addTo(stage);

  touchListener = background.onMouseMove.listen((e) {
    arrow.pointTo(startx, starty, e.localX.toInt(), e.localY.toInt());
  });
  
  background.onMouseUp.listen((e) {
    endDraw();
    arrow.endDraw();
  });
}

startPen(int startx, int starty) {
  pixels.add(new Point(startx, starty));
  
  touchListener = background.onMouseMove.listen((e) {
    drawPen( e.localX.toInt(), e.localY.toInt());
  });
  background.onMouseUp.listen((e) {
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
  _canvas.graphics.strokeColor(Color.DimGray , 5);
}

endDraw() {
 pixels = [];
 document.querySelector('#points').text = "Points: ${pixels.length.toString()}";
  canvasBitmapData.draw(_canvas);
  _canvas.graphics.clear();
  if(touchListener!=null) touchListener.cancel();
}

setButtonStateOn(Element target) {
  var btns = document.querySelectorAll('.btn');
  for (var btn in btns) {
    btn.classes.remove("active");
  }
  target.classes.add("active");
}

class Arrow extends DisplayObjectContainer{
  Shape lineVector;
  Bitmap head;
  Bitmap body;
  Arrow(){
    mouseEnabled = false;            
    lineVector = new Shape();
    addChild(lineVector);
    
    Shape headVector = new Shape();
    headVector.graphics.beginPath();
    headVector.graphics.moveTo(25 , 10);
    headVector.graphics.lineTo(0, 20);
    headVector.graphics.quadraticCurveTo( 10 ,  10, 0,0);
//    headVector.graphics.lineTo(0,0);
    headVector.graphics.lineTo(25, 10);
    headVector.graphics.closePath();
    headVector.graphics.fillColor(Color.Black);
    
    // Being tested that cache with BitmapData improves performance
    BitmapData canvasBitmapData = new BitmapData(25, 20, true, 0);
    canvasBitmapData.draw(headVector);
    headVector.graphics.clear();
    
    head = new Bitmap(canvasBitmapData);
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
    lineVector.graphics.strokeColor(Color.Black, 5 , JointStyle.BEVEL , CapsStyle.SQUARE);
    head.rotation = atan2(y2 - y  , x2 - x);
    head.x = x2;
    head.y = y2;
  }
  
  void endDraw(){
   
   if(lineVector.width==0) return;
   if(lineVector==null) return;
   print('${lineVector.width} , ${lineVector.height}');
   BitmapData bitmapData = new BitmapData(lineVector.width, lineVector.height, true, 0);
   bitmapData.draw(lineVector);
   body = new Bitmap(bitmapData);
//   body ..x = startpoint.x ..y = startpoint.y;
   addChild(body);
//   lineVector.graphics.clear();
   removeChild(lineVector);
   
  }
}
