import controlP5.*;

//==================================================================================================================
// GLOBALS AND INITIALIZATION OF GLOBALS
//==================================================================================================================

// View Variables
double xScale = 2.0;
double yScale = 2.0;
double xOffset = 0.0;
double yOffset = 0.0;
double viewX;
double viewY;

//Complex class object to access the Complex functions
Complex Complex = new Complex();

//PImage object to store input image data
PImage img;

//ControlP5 GUI variables and class
ControlP5 controlP5;
double[] controlNums = new double[4];
boolean dragable = false;

// Initialize global variables that are dependent on the size method having been called first.
void initGlobals() {
  viewX = width/2.0;
  viewY = height/2.0;
  controlNums[0] = 1.35;
}

//==================================================================================================================
// PROCESSING SETUP AND DRAW METHODS
//==================================================================================================================

void setup() {
  // The canvas size is what dictates fluidity. If there are too many pixels the program is too slow. 500 by 500 is pretty reasonable so stick with that when interacting with the image.
  // If a more high resolution image is required comment out loadGUI(); from the load function and increase the size dimensions.
  size(1000, 1000);
  load();
  drawOutput(img);
  save("output.png");
}

void draw() {
  // Refresh the image to see changes caused by interaction.
  drawOutput(img);
}

//==================================================================================================================
// LOADER METHODS
//==================================================================================================================

// Load everything up.
void load() {
  initGlobals();
  loadInputImage();
  loadGUI();
  loadPixels();
}

// Load the input image found in the assets folder.
void loadInputImage() {
  img = loadImage("assets/Pattern.png");
  img.loadPixels();
}

// Initialize the controlP5 variable and bind it to the sketch. Then add the GUI elements to the canvas.
void loadGUI() {
  controlP5 = new ControlP5(this);
  
  addGUI();
}

//==================================================================================================================
// DRAWING METHODS
//==================================================================================================================

// Draw the desired output image by setting the canvas' pixels array to the corresponding color found with getColor().
void drawOutput() {
  colorMode(HSB, 2.0 * PI, 1.0, 1.0);
  strokeWeight(1);
  loadPixels();
  for (double y = 0.0; y < width; y++) {
    for (double x = 0.0; x < height; x++) {
      pixels[(int) (y*width+x)] = getColor(f(Complex.cart((x-viewX)*xScale, (viewY-y)*yScale)));
    }
  }
  updatePixels();
}

// Draw the desired output image by setting the canvas' pixels array to the corresponding image pixel color found with getPixel().
void drawOutput(PImage image) {
  colorMode(RGB, 255);
  for (double y = 0.0; y < width; y++) {
    for (double x = 0.0; x < height; x++) {
      // Set corresponding pixel to the output of f(z)
      pixels[(int) (y*width+x)] = getPixel(f(Complex.cart(((x-viewX)/width)*xScale, ((viewY-y)/height)*yScale)),image);
    }
  }
  updatePixels();
}

//==================================================================================================================
// COMPLEX FUNCTIONS
//==================================================================================================================

// Complex function f(z) = (controlNums[0])*(img.height)*e^(pi/4)*log(z)
ComplexNum f(ComplexNum z) {
  ComplexNum a = Complex.cart(controlNums[0]*img.height, 0);
  ComplexNum rotate = Complex.polar(1.0,PI/4);
  ComplexNum newZ = Complex.cart(z.re(),z.im());
  newZ = Complex.log(newZ);
  newZ = Complex.mult(rotate, newZ);
  newZ = Complex.mult(a,newZ);
  return newZ;
}

// Complex function g(z) = z^controlNums[0]
ComplexNum g(ComplexNum z) {
  return Complex.pow(z,controlNums[0]);
}

//==================================================================================================================
// COLOR FETCHING METHODS
//==================================================================================================================

// Function to get color of a the given complex number input. Hue is the argument and black level is magnitude.
color getColor(ComplexNum z) {
  float arg = (float) -z.arg() + PI;
  float r = (float) z.mag();
  return color(arg, 1, 1 - 1.0/log(r+(float) Math.E));
}

// Function to get the pixel that the complex number would land on in the regular tiling of the input img.
color getPixel(ComplexNum z, PImage image) {
  int a = (int) (z.re() + img.width/2) % img.width;
  int b = (int) (z.im() + img.height/2) % img.height;
  int x, y;

  if (a >= 0) {
    x = a;
  } else {
    x = img.width + a;
  }

  if (b >= 0) {
    y = b;
  } else {
    y = img.height + b;
  }
  int index = x + y * img.width;

  return image.pixels[index];
}

//==================================================================================================================
// INTERACTION HANDLING AND GUI ELEMENTS METHODS
//==================================================================================================================

// Add the GUI elements.
void addGUI() {
  controlP5.addNumberbox("numberbox1",0,10,10,100,30).setMultiplier(-0.001).setValue(0.45);
  controlP5.addButton("reset").setPosition(10,60).setSize(30,30);
  controlP5.addToggle("dragable").setPosition(10,110).setSize(30,30).setState(false);
}

// Deal with ControlP5 GUI interactions.
void controlEvent(ControlEvent e) {
  // Reset the viewer variables when the "reset" button is clicked.
  if(e.getController().getName()=="reset") {
    viewX = width/2.0;
    viewY = height/2.0;
    xScale= 2.0;
    yScale= 2.0;
  }
  
  // Update the value of the first controlNums item to be equal to the new numberbox value.
  if(e.getController().getName()=="numberbox1"){
    controlNums[0] = (double) e.getController().getValue();
  }
}

// Sets offset using initial postion of the mouse when pressed.
void mousePressed() {
  xOffset = mouseX-viewX; 
  yOffset = mouseY-viewY; 
}

// Add the ability to drag the output around using the offset values calculated by mousePressed().
void mouseDragged() {
  if(dragable) {
   viewX = mouseX-xOffset; 
   viewY = mouseY-yOffset;
  }
}

// Add the ability to zoom towards and away from the origin by multiplying the scale by magnitudes of ten. ( scale *= 10^(wheelSteps/25) )
void mouseWheel(MouseEvent e) {
  double wheelSteps = e.getCount();
  xScale *= Math.pow(10.0,wheelSteps/25.0);
  yScale *= Math.pow(10.0,wheelSteps/25.0);
}
