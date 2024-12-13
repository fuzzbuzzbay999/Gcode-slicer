//import
import g4p_controls.*;
import jankovicsandras.imagetracer.ImageTracer;

//file stuff
PrintWriter imagesDropdown;
//variables
int xScale, yScale;
float imgWidth, imgHeight, imgScaler;
File file = null;

String CurrentImageSelected;

//graphics
PImage imageSelected;

PGraphics PrintArea;
PGraphics UI;
PGraphics Preview;
PGraphics Outline;
PGraphics Grid;

//variables to deal with unit conversions pixels to mm
//change these to fit the x y volume of your machien
int bedWidth=250; //mm
int bedHeight=150; //mm
int gridSize = 20; //pixels

//auto change do not change
int PPmm; //pixels per mm
boolean isProportional = true;
float changeAmount;

//master list
ArrayList<imgData> Images = new ArrayList();



//true if the selectImage function is running
boolean currentlySelectingImg =false;
//string for packaged data
//String[] ImageDataString;
//stores all data for an image
public class imgData {
  private String address;
  private int xPos;
  private int yPos;
  private int wide;
  private int tall;
  private int number;
  private float scaleFactor;
  private int scaleWide;
  private int scaleTall;
  imgData(String Address, int X, int Y, int Wide, int Tall, int Number) {
    address = Address;
    xPos=X;
    yPos=Y;
    wide = Wide;
    scaleWide = Wide;
    tall = Tall;
    scaleTall = Tall;
    number = Number;
  }
  String reqData() {
    return "x pos "+xPos+" y pos "+yPos +"\nwidth " +wide+ " height " +tall+"\naddress " +address + "\nnumber " + number;
  }
  String reqAddress() {
    return address;
  }
  Integer reqNum() {
    return number;
  }
  int reqScaleWide() {

    return scaleWide;
  }
  int reqScaleTall() {
    return scaleTall;
  }
  void move(int x, int y) {
    xPos = x;
    yPos=y;
  }
  void setScale(float amount) {
    scaleFactor = amount;
    scaleWide=int(wide/scaleFactor);
    scaleTall=int(tall/scaleFactor);
  }
}
//start
void setup() { //<>//
  size(2500, 1300);
  xScale=width;
  yScale=height;
  PPmm=yScale/bedHeight;
  // surface. setResizable(true);
  PrintArea = createGraphics(xScale-xScale/4, yScale);
  UI = createGraphics(xScale/4, yScale);
  Preview =createGraphics(xScale/4, xScale/4);
  Outline = createGraphics(xScale-xScale/4, yScale);
  Grid = createGraphics(xScale-xScale/4,yScale);
  createGUI();

  //initializeDropdown();
  drawImages();
  println("current dimensions are: " + yScale+ "pixels tall to" + bedHeight + "mm bed height, making a PPmm of" + PPmm);
}

//loop
void draw() {
  //if the window changes size resize
  if (xScale!=width||yScale!=height) {
    xScale=width;
    yScale=height;
    println(width+" "+height);
    UI();
  }
//redraw every frame
  cleanUI();
  image(Grid,xScale/4,0);
  image(PrintArea, xScale/4, 0);
  image(Outline, xScale/4, 0);


  if (currentlySelectingImg) {
    drawImages();
  }
}

void mousePressed() {
}


void keyPressed() {

  if (key=='f'||key =='F')   selectInput("select Image:", "ImageSelected", file);
  if (key =='r'||key =='R')drawImages();
  if (key == 'd'||key == 'D') packdata();
  if (key == 'p'||key =='P')createPrevImg(ImageDropdown.getSelectedText());
  if(key=='e'||key=='E') selectOutput("slected where to save the png to be converted","export",file);
  if(key=='t'||key=='T')selectInput("select Image to be traced","trace",file);
}

void printArea() {
}

//executes when image is selected
void ImageSelected(File file) {
  try {
    imageSelected = loadImage(file.getAbsolutePath());
    //add new image to master list
    Images.add(new imgData(file.getAbsolutePath(), 0, 0, imageSelected.width, imageSelected.height, Images.size()));
    println("begin image data");
    println(Images.get(Images.size()-1).reqData());
    println("end image data");
    println(Images.size());
    //enable the selected image so we can draw all of the images
    currentlySelectingImg=true;
    //update the sliders to the new image position
    updateSliders(ImageDropdown.getSelectedIndex());
    //sets the preview as the new image selected.
     createPrevImg(file.getAbsolutePath());
  }
  catch(Exception e) {
    //throw error if not an image
    System.err.println("oops woopsy, make sure its an image. you dumb pone");
  }
}

//update images
void drawImages() {
  //draw the grid
  drawGrid();
  PrintArea.beginDraw();
  PrintArea.clear();
  //txt file for dropdown
  imagesDropdown = createWriter("data/images.txt");

  //disp images
  int  i=0;
  for (imgData img : Images) {
    i++;

    println("currently processing image");
    println(img.address);

    //writes img.adress to dropdown
    imagesDropdown.println(img.address);
    imageSelected = loadImage(img.address);
    PrintArea.image(imageSelected, img.xPos, img.yPos, img.scaleWide, img.scaleTall);
  }
  println("total images processed: "+i);

  PrintArea.endDraw();
  imagesDropdown.flush();
  //display the print area with the new images
  image(PrintArea, xScale/4, 0);
  println("draw fin");
  //update the dropdown
  ImageDropdown.setItems(loadStrings("data/images.txt"), ImageDropdown.getSelectedIndex());
  cleanUI();

  //remove the placement outline
  Outline.beginDraw();
  Outline.clear();
  Outline.endDraw();

  //disable imageselecting to stop running drawImages()
  currentlySelectingImg = false;
 
}

//pack data to a new array list so we can export for saving the season
void packdata() {
  ArrayList ImageDataString = new ArrayList<String>();
  for (imgData img : Images) {
    ImageDataString.add(img.reqData());
  }
  println(ImageDataString.toString());
  // saveStrings("Images.txt", ImageDataString);
}


//*******UI*******
//initializes and resizes the ui strip
void UI() {
  PrintArea = createGraphics(xScale-xScale/4, yScale);
  UI = createGraphics(xScale/4, yScale);
  Preview = createGraphics(xScale/4, xScale);
  UI.beginDraw();
  UI.background(0);
  UI.endDraw();


  image(UI, 0, 0);
  //clears garbage memory
  System.gc();

  drawImages();
}
//cleans the ui strip
void cleanUI() {
  UI.beginDraw();
  UI.background(100);
  UI.endDraw();
  image(UI, 0, 0);
  image(Preview, 0, yScale-xScale/4);
}

//draw the grid
void drawGrid(){
 Grid.beginDraw();
  Grid.background(255);
  //txt file for dropdown
 
  //grid
  for (int gridX=0; gridX<width; gridX+= gridSize) {
   Grid.stroke(200, 200, 255);
   Grid.line(gridX, 0, gridX, height);
  }
  for (int gridY=0; gridY< height; gridY+= gridSize) {
   Grid.stroke(200, 200, 255);
    Grid.line(0, gridY, width, gridY);
  }

  Grid.endDraw();
}

//draws the image preview givent the number assosiated with adress assosiated with the image
void createPrevImg(String address) {

  imageSelected = loadImage(address);

  Preview.beginDraw();
  Preview.background(135);

  //resize the image to fit the area
  println("img width: "+imageSelected.width +"img height: "+imageSelected.height);
  if (imageSelected.width>=imageSelected.height) {
    println("wide");
    imgScaler=(float)imageSelected.width/Preview.width;
    imgWidth=(float)imageSelected.width/imgScaler;
    imgHeight=(float)imageSelected.height/imgScaler;
  } else if (imageSelected.width<imageSelected.height) {
    println("tall");
    imgScaler=(float)imageSelected.height/Preview.height;
    imgWidth=(float)imageSelected.width/imgScaler;
    imgHeight=(float)imageSelected.height/imgScaler;
  }
  Preview.image(imageSelected, 0, 0, imgWidth, imgHeight);
  println("scaler: " + imgScaler);
  println("new img width: "+imgWidth +"new img height: "+imgHeight);
  println("preview width: "+Preview.width + "preveiw height: "+Preview.height);
  println("Preview image");
  println(address);
  Preview.endDraw();
  image(Preview, 0, yScale-xScale/4);
}


//move the image on the xy plane
void moveImage(int index, float xPercent, float yPercent) {
  imgData img = Images.get(index);

  int Xpos = int(map(xPercent, 0, 1, 0, PrintArea.width));
  int Ypos = int(map(yPercent, 0, 1, 0, PrintArea.height));
  drawOutline(img, Xpos, Ypos);
  img.xPos=Xpos;
  img.yPos=Ypos;
//displpay the outline
  image(Outline, xScale/4, 0);
}

//scale image horizontaly
void scaleImageX(int index, float xAmount) {
  imgData img = Images.get(index);
  changeAmount =(float)img.wide/(xAmount*PPmm);
  //if proportional check box is checked. then scale uniformly
  if (isProportional) {
    img.setScale(changeAmount);
  } else {
    //just scale width
    img.scaleWide = int(img.wide/changeAmount);
  }
  //draw the outline
  drawOutline(img, img.xPos, img.yPos);
}

//scale image vertiacaly
void scaleImageY(int index, float yAmount) {
imgData img = Images.get(index);
  changeAmount =(float)img.tall/(yAmount*PPmm);
  //if proportional editing then scale uniformly
  if (isProportional) {
    img.setScale(changeAmount);
  } else {
    //just scale height
    img.scaleTall = int(img.tall/changeAmount);
  }
  //draw the outline
  drawOutline(img, img.xPos, img.yPos);
}  



//resets the data feilds to the current selected image
void updateSliders(int index) {
  imgData img = Images.get(index);
  xPosSlider.setValue(map(img.xPos, 0, PrintArea.width, 0, 1));
  yPosSlider.setValue(map(img.yPos, 0, PrintArea.height, 0, 1));
  WidthBox.setText(img.scaleWide/PPmm+"");
  HeightBox.setText(img.scaleTall/PPmm+"");

  //yPosSlider.setValue(map(img.scaleFactor,1,100,0,1));
  drawOutline(img, img.xPos, img.yPos);
  print("current" +index+"is being updated");
}

//function for drawing outline
void drawOutline(imgData img, int Xpos, int Ypos) {
  Outline.beginDraw();
  Outline.clear();
  Outline.noFill();
  Outline.stroke(100, 50, 200);
  Outline.strokeWeight(10);
  Outline.rect(Xpos, Ypos, img.scaleWide, img.scaleTall);
  Outline.endDraw();
}
//exports the PrintArea layer as a png with transparency
void export(File file){ //<>//
 println("exporting file " ,file);
 PrintArea.save(file.getAbsolutePath());
 trace(file);
  
}


//converts the png to the SVG with a .svg extension
void trace(File file){ //<>//
  try{
    println("traceing ", file.getAbsolutePath());
  // print(path.toAbsolutePath());
  ImageTracer.saveString(file.getAbsolutePath()+".svg",ImageTracer.imageToSVG(file.getAbsolutePath(),null,null));
  println("Trace success");
  }catch(Exception e){
   println(e);
  }
}
//this is to convert svg to gcode
void svgToGcode( File file){
  /*
  code that will convert the paths found in the svg to gcode. 
  it will convert the path to individual G0 and G1 vectorss. 
  by taking the difference of the origin 0,0 (top left corner of the image) and the current point in the path of the SVG in question.
  then divide that by the PPmm(pixels per mm). to convert PIxels to mm,
  then format a string like
  GO X~~ Y~~
    *****turning on and off the laser*****
    when a new <path> stars we will output a m106 s200. (turn laser on)
    
    when the <path> ends aka a new one begins we will output a m106 s0 (turn laser off); then repeate this loop.
  */
}
