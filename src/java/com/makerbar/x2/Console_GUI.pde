import java.awt.AWTException;
import java.awt.Robot;
import processing.serial.*;

final float EIGHTH_PI = QUARTER_PI / 2;

final int TOOL_WATER = 0;
final int TOOL_LAND = 1;
final int TOOL_CLOUD = 2;
final int TOOL_COMET = 3;

color[] colorValues =
{
  #ff57ed, 
  #8233de, 
  #032ac4, 
  #1b94ae, 
  #0dbf27, 
  #96fe42, 
  #fffe06, 
  #ff9650, 
  #d31212, 
  #9d7e74, 
  #636363, 
  #a5a5a5, 
  #e7e7e7
};

color[] waterColorValues = 
{
  #6b005f, 
  #4b049e, 
  #001d8f, 
  #0f7990, 
  #006a10, 
  #42751a, 
  #959400, 
  #ac5e2a, 
  #970000, 
  #593023, 
  #0c0c0c, 
  #5b5b5b, 
  #7f7f7f
};

color[] cloudColorValues = 
{
  #ffa9f6, 
  #cfb0f2, 
  #b4bfed, 
  #b9dee6, 
  #b6ecbe, 
  #dcffc0, 
  #ffffb5, 
  #ffdcc4, 
  #f1b5b5, 
  #cfc0bb, 
  #bfbfbf, 
  #e4e4e4, 
  #f7f7f7
};

float chicken = 1.0;
PImage chickenBuffer;
int debugSphereBearingModifier;

Robot jp; // I'm saving up to get metal legs. It's a risky operation, but it's worth it.

Serial serial;
boolean processedControls;

boolean gameOver = false;

boolean leftButtonIsPressed;
boolean leftButtonWasPressed;
boolean rightButtonIsPressed;
boolean rightButtonWasPressed;
boolean bigAssButtonIsPressed;
boolean bigAssButtonWasPressed;
boolean triggerIsPulled;
boolean triggerWasPulled;
boolean switchIsActivated;
boolean switchWasActivated;
int joystickX;
int joystickY;

PFont headerFont;
PFont confirmationFont;
PFont keywordFont;

XML[] planetList;
String planetName;

PGraphics leftStripBuffer;
PGraphics rightStripBuffer;

final int sphereWidth = 223; // Remember that everything is zero-indexed
final int sphereHeight = 101;
int sphereBearing = sphereWidth / 2;

int reticleX;
int reticleY;
int lastReticleX = -1;
int lastReticleY = -1; // Used for brush interpolation

final int waterBrushDiameter = 30;
final int landBrushDiameter = 10;
final int cloudBrushDiameter = 20;

PGraphics waterBuffer;
PGraphics landBuffer;
PGraphics cloudBuffer;
PGraphics cloudSubBuffer;
PGraphics postWindCloudBuffer;
boolean clearedClouds;
ArrayList<Comet> comets = new ArrayList<Comet>();
PGraphics cometBuffer;
PGraphics sphereBuffer;
PGraphics outputBuffer;
PGraphics minimap;

int windSpeed = 2;

int waterSpreadX = -1;
int waterSpreadY = -1;
int waterSpreadDiameter = 1;
color waterSpreadColor;

int planetClearAlpha = -1;

PImage reticle10px;
PImage reticle20px;
PImage reticle30px;

PImage background;
PImage backgroundTop;
PImage backgroundBottom;
PImage overlayMask;

PImage buttons;
PImage crosshair;

PImage iconBackground;
PImage smallIconBackground;
PImage smallIconBackground2;
PImage nurdleIcon;
PImage smallNurdleIcon;
PImage deleteIcon;
PImage smallDeleteIcon;

PImage overlay;
//PImage overlayAlternate;
PImage backgroundDestroyEverything;
//PImage overlayFinishEarly;
PImage overlayTimeWarning;

PImage[] toolIcons = new PImage[6];
PImage[] smallToolIcons = new PImage[6];

//todo add ability to end game early
int timeLimit = 300000; // Default of 300000, or five minutes
int confirmationTimeout = 5000;
int startingMillis;
int confirmationStartMillis = -1;
int demoTime = 30000;
int demoStartMillis = -1;

int scrollTime = 200;
int leftScrollStartMillis;
boolean isScrollingLeft;
int rightScrollStartMillis;
boolean isScrollingRight;

int swapTime = scrollTime;
int leftSwapStartMillis;
boolean isSwappingLeft;
int rightSwapStartMillis;
boolean isSwappingRight;

int numberOfColors = 13;
int numberOfTools = 4;

int stripIconWidth = 285;
int stripIconHeight = 280;

int leftStripCenterX = 166;
int rightStripCenterX = 1123;
int stripCenterY = 690;
int[] leftStripIconPositions = new int[4];
int[] rightStripIconPositions = new int[4];
int leftStripOffset;
int rightStripOffset;

final int[] defaultStripIconPositions = 
{
  (int)(stripIconHeight * -0.5), 
  (int)(stripIconHeight * 0.5), 
  (int)(stripIconHeight * 1.5), 
  (int)(stripIconHeight * 2.5)
  };

  int displayIconPositionX;
int displayIconPositionY;
int displayIconWidth = 379;
int displayIconHeight = 376;

int activeColor;
int activeTool = TOOL_WATER;
boolean isInEraseMode = false;

float rotationScale = 0.10;

int debugCrosshairX;
int debugCrosshairY;
boolean debugOverrideSwitch;
boolean debugKeyPressed;

int windowX;
int windowY;

int mouseXZero;
int mouseYZero;

boolean sketchFullScreen() { return true;}

void setup()
{
  size(1280, 1024); // P3D and P2D renderers seem to cause massive flickering
  noSmooth();
  frameRate(30);

  leftStripBuffer = createGraphics(stripIconWidth, stripIconHeight * 2);
  rightStripBuffer = createGraphics(stripIconWidth, stripIconHeight * 2);

  waterBuffer = createGraphics(sphereWidth, sphereHeight);
  landBuffer = createGraphics(sphereWidth, sphereHeight);
  cloudBuffer = createGraphics(sphereWidth, sphereHeight);
  cloudSubBuffer = createGraphics(sphereWidth, sphereHeight);
  postWindCloudBuffer = createGraphics(sphereWidth, sphereHeight);
  cometBuffer = createGraphics(sphereWidth, sphereHeight);
  sphereBuffer = createGraphics(sphereWidth, sphereHeight);
  outputBuffer = createGraphics(sphereWidth, sphereHeight);

  minimap = createGraphics(sphereWidth / 2, sphereHeight);

  // Dumbshit workaround for NullPointerExceptions on draw, and disable antialiasing
  waterBuffer.beginDraw();
  waterBuffer.noSmooth();
  waterBuffer.endDraw();

  landBuffer.beginDraw();
  landBuffer.noSmooth();
  landBuffer.endDraw();

  cloudBuffer.beginDraw();
  cloudBuffer.noSmooth();
  cloudBuffer.endDraw();

  cloudSubBuffer.beginDraw();
  cloudSubBuffer.noSmooth();
  cloudSubBuffer.endDraw();
  
  postWindCloudBuffer.beginDraw();
  postWindCloudBuffer.noSmooth();
  postWindCloudBuffer.endDraw();

  sphereBuffer.beginDraw();
  sphereBuffer.noSmooth();
  sphereBuffer.endDraw();

  outputBuffer.beginDraw();
  outputBuffer.noSmooth();
  outputBuffer.endDraw();

  minimap.beginDraw();
  minimap.noSmooth();
  minimap.endDraw();

  Comet.setSphereParameters(sphereWidth, sphereHeight);

  try { 
    jp = new Robot();
  }
  catch (AWTException e) { 
    e.printStackTrace();
  }

  println(Serial.list());
  if (Serial.list().length >= 5) serial = new Serial(this, Serial.list()[0], 115200);
  if (serial != null) serial.buffer(6);

  headerFont = createFont("BebasNeue.otf", 200);
  confirmationFont = createFont("BebasNeue.otf", 100);
  keywordFont = createFont("BebasNeue.otf", 400);

  reticle10px = loadImage("Reticle 10px.png");
  reticle20px = loadImage("Reticle 20px.png");
  reticle30px = loadImage("Reticle 30px.png");

  background = loadImage("Background.png");
  backgroundTop = loadImage("Background Top.png");
  backgroundBottom = loadImage("Background Bottom.png");
  overlayMask = loadImage("Overlay Mask.png");

  buttons = loadImage("Buttons.png");
  crosshair = loadImage("Crosshair.png");

  iconBackground = loadImage("Icon Background.png");
  nurdleIcon = loadImage("Nurdle Icon.png");
  //deleteIcon = loadImage("Delete Icon.png");
  deleteIcon = loadImage("Nuke Icon.png");

  toolIcons[0] = loadImage("Water Icon.png");
  toolIcons[1] = loadImage("Land Icon.png");
  toolIcons[2] = loadImage("Cloud Icon.png");
  toolIcons[3] = loadImage("Comet Icon.png");
  toolIcons[4] = loadImage("Finished Icon.png");
  toolIcons[5] = loadImage("Nuke Icon.png");

  smallIconBackground = iconBackground.get();
  smallIconBackground.resize(stripIconWidth, stripIconHeight);
  smallNurdleIcon = nurdleIcon.get();
  smallNurdleIcon.resize(stripIconWidth, stripIconHeight);
  //smallDeleteIcon = deleteIcon.get();
  //smallDeleteIcon.resize(stripIconWidth, stripIconHeight);

  for (int i = 0; i < 6; i++)
  {
    smallToolIcons[i] = toolIcons[i].get();
    smallToolIcons[i].resize(stripIconWidth, stripIconHeight);
  }

  overlay = loadImage("Overlay.png");
  //overlayAlternate = loadImage("Overlay Alternate.png");
  backgroundDestroyEverything = loadImage("Background Destroy Everything.png");
  //overlayFinishEarly = loadImage("Overlay Finish Early.png");
  overlayTimeWarning = loadImage("Overlay Time Warning.png");

  for (int i = 0; i < 4; i++)
  {
    leftStripIconPositions[i] = defaultStripIconPositions[i];
    rightStripIconPositions[i] = defaultStripIconPositions[i];
  }

  displayIconPositionX = (width / 2);
  displayIconPositionY = (int)(height * .65);

  startingMillis = millis();

  resetPlanet();
  //jp.mouseMove(1280 / 2, 1024 / 2);
}


void draw()
{ 
  /*** Center mouse ***/
  if (mouseXZero == 0)
  {
    if (mouseX != 0)
    {
      try
      {
        windowX = this.frame.getLocationOnScreen().x;
        windowY = this.frame.getLocationOnScreen().y;

        mouseXZero = (1280 / 2) + windowX;
        mouseYZero = (1024 / 2) + windowY;

        jp.mouseMove(mouseXZero, mouseYZero);
        noCursor();

        /*
        print("MouseZero ");
         print(mouseXZero);
         print(", ");
         println(mouseYZero);
         */
      }
      catch(Exception e) {
      }
    }
  }
  else
  {
    // Calculate the mouse X delta and rotate the globe (bearing)
    if (!gameOver) sphereBearing += (mouseX - 640) * rotationScale;

    jp.mouseMove(mouseXZero, mouseYZero);

    sphereBearing += debugSphereBearingModifier;
    debugSphereBearingModifier = 0;

    sphereBearing = mod2(sphereBearing, sphereWidth);
  }

  /*** Handle input ***/
  if (triggerIsPulled && triggerWasPulled)
  {
    lastReticleX = reticleX;
    lastReticleY = reticleY;
  }

  float scaledJoystickX = map(joystickX, -128, 128, -sphereHeight / 2, sphereHeight / 2);
  float scaledJoystickY = map(joystickY, -128, 128, sphereHeight / 2, -sphereHeight / 2);
  float reticleAngle = atan2(scaledJoystickY, scaledJoystickX);
  float reticleMagnitude = 
    min(sqrt(scaledJoystickY * scaledJoystickY + scaledJoystickX * scaledJoystickX), sphereHeight / 2);

  reticleX = (int)(cos(reticleAngle) * reticleMagnitude) + sphereBearing;
  reticleY = (int)(sin(reticleAngle) * reticleMagnitude) + (sphereHeight / 2);

  if (leftButtonIsPressed && !leftButtonWasPressed)
  {
    if (isScrollingLeft)
    {
      activeColor = (activeColor + 1) % numberOfColors;
    }

    if (!isInEraseMode) // Colors disabled during Erase Mode
    {
      isScrollingLeft = true;
      leftScrollStartMillis = millis();
    }

    if (demoStartMillis != -1)
    {
      demoStartMillis = min(demoStartMillis + demoTime, demoStartMillis - 1000);
    }
  }

  if (bigAssButtonIsPressed && !bigAssButtonWasPressed)
  {
    if (gameOver)
    {
      if (demoStartMillis == -1)
      {
        gameOver = false;
        startingMillis = millis();
      }
    }
    else if (!isInEraseMode && !isSwappingLeft && !isSwappingRight) // Shuffle disabled during Erase Mode
    {
      isSwappingLeft = isSwappingRight = true;
      leftSwapStartMillis = rightSwapStartMillis = millis();

      int randomNumber = (int)random(numberOfColors);
      while (randomNumber == activeColor) randomNumber = (int)random(numberOfColors);

      activeColor = randomNumber;

      randomNumber = (int)random(numberOfTools - 1);
      while (randomNumber == activeTool) randomNumber = (int)random(numberOfTools - 1);

      activeTool = randomNumber;
    }
  }

  if (rightButtonIsPressed && !rightButtonWasPressed)
  {
    if (!isInEraseMode)
    {
      if (isScrollingRight)
      {
        activeTool = (activeTool + 1) % numberOfTools;
      }

      confirmationStartMillis = -1;
      isSwappingLeft = true;
      leftSwapStartMillis = millis();
      isScrollingRight = true;
      rightScrollStartMillis = millis();
    }

    if (demoStartMillis != -1)
    {
      demoStartMillis = min(demoStartMillis + demoTime, demoStartMillis - 1000);
    }
  }

  if (triggerIsPulled && !triggerWasPulled)
  {
    lastReticleX = reticleX;
    lastReticleY = reticleY;
    confirmationStartMillis = millis();
  }
  else if (!triggerIsPulled && triggerWasPulled)
  {
    confirmationStartMillis = -1;
  }

  if (switchIsActivated && !switchWasActivated)
  {
    isInEraseMode = true;

    isSwappingLeft = isSwappingRight = true;
    leftSwapStartMillis = rightSwapStartMillis = millis();
  }
  else if (!switchIsActivated && switchWasActivated)
  {
    isInEraseMode = false;
    isSwappingLeft = isSwappingRight = true;
    leftSwapStartMillis = rightSwapStartMillis = millis(); // todo: start animation halfway
  }

  processedControls = true;

  /*** Update comets ***/
  for (int i = 0; i < comets.size(); i++)
  {
    comets.get(i).update();
  }

  if (!gameOver)
  {
    /*** Paint the Planet ***/
    if (isInEraseMode)
    {
      if (confirmationStartMillis != -1 && millis() - confirmationStartMillis > confirmationTimeout && planetClearAlpha == -1)
      {
        resetPlanet();
      }
    }
    else
    {
      switch(activeTool)
      {
      case TOOL_WATER:
        if (triggerIsPulled && !triggerWasPulled)
        {
          if (waterSpreadX == -1)
          {
            waterSpreadX = reticleX;
            waterSpreadY = reticleY;
            waterSpreadDiameter = 1;
            waterSpreadColor = iconColor(activeColor, activeTool);
          }
        }
        break;

      case TOOL_LAND:
        if (triggerIsPulled)
        {
          brush(landBuffer, lastReticleX, lastReticleY, reticleX, reticleY, 
          iconColor(activeColor, activeTool), landBrushDiameter);
        }
        break;

      case TOOL_CLOUD:
        if (triggerIsPulled)
        {
          if (triggerIsPulled)
          {
            spray(cloudSubBuffer, lastReticleX, lastReticleY, reticleX, reticleY, 
            iconColor(activeColor, activeTool), 10, 10);
          }

          clearedClouds = false;
        }
        else if (!clearedClouds)
        {
          cloudBuffer.beginDraw();
          cloudBuffer.tint(255, 128);
          cloudBuffer.image(cloudSubBuffer.get(), 0, 0);
          cloudBuffer.endDraw();

          cloudSubBuffer.beginDraw();
          cloudSubBuffer.clear();
          cloudSubBuffer.endDraw();

          clearedClouds = true;
        }
        break;

      case TOOL_COMET:
        if (triggerIsPulled && !triggerWasPulled)
        { 
          int cometDirection = 0;

          if (reticleX == sphereBearing && reticleY == sphereHeight / 2)
          {
            cometDirection = (int)random(8);
          }
          else
          {
            if (reticleAngle > -EIGHTH_PI && reticleAngle <= EIGHTH_PI)
              cometDirection = Comet.DIRECTION_RIGHT;
            else if (reticleAngle > EIGHTH_PI && reticleAngle <= EIGHTH_PI + QUARTER_PI)
              cometDirection = Comet.DIRECTION_DOWNRIGHT;
            else if (reticleAngle > EIGHTH_PI + QUARTER_PI && reticleAngle <= EIGHTH_PI + HALF_PI)
              cometDirection = Comet.DIRECTION_DOWN;
            else if (reticleAngle > EIGHTH_PI + HALF_PI && reticleAngle <= PI - EIGHTH_PI)
              cometDirection = Comet.DIRECTION_DOWNLEFT;
            else if (reticleAngle > PI - EIGHTH_PI || reticleAngle <= EIGHTH_PI - PI)
              cometDirection = Comet.DIRECTION_LEFT;
            else if (reticleAngle > EIGHTH_PI - PI && reticleAngle <= -1 * (HALF_PI + EIGHTH_PI))
              cometDirection = Comet.DIRECTION_UPLEFT;
            else if (reticleAngle > -1 * (HALF_PI + EIGHTH_PI) && reticleAngle <= -1 * (EIGHTH_PI + QUARTER_PI))
              cometDirection = Comet.DIRECTION_UP;
            else
              cometDirection = Comet.DIRECTION_UPRIGHT;
          }

          comets.add(new Comet(sphereBearing, sphereHeight / 2, cometDirection, iconColor(activeColor, activeTool)));
        }
        break;

      default:
        break;
      }
    }
  }

  if (gameOver && demoStartMillis != -1)
  {
    sphereBearing += 1;
    sphereBearing %= sphereWidth;
  }

  /*** Render the Planet ***/
  sphereBuffer.beginDraw();
  sphereBuffer.background(0);

  //sphereBuffer.image(grid, 0, 0);
  // Debug reference lines
  sphereBuffer.stroke(255);
  sphereBuffer.line(sphereBearing, 0, sphereBearing, sphereHeight);
  sphereBuffer.stroke(128);
  sphereBuffer.line(
  mod2(sphereBearing - (sphereWidth / 4), sphereWidth), 0, 
  mod2(sphereBearing - (sphereWidth / 4), sphereWidth), sphereHeight);
  sphereBuffer.line(
  (sphereBearing + (sphereWidth / 4)) % sphereWidth, 0, 
  (sphereBearing + (sphereWidth / 4)) % sphereWidth, sphereHeight);
  sphereBuffer.noStroke();

  // Planet layers
  if (waterSpreadX != -1)
  {
    waterBuffer.beginDraw();
    waterBuffer.noStroke();
    waterBuffer.fill(waterSpreadColor);
    dab(waterBuffer, waterSpreadX, waterSpreadY, waterSpreadDiameter);
    waterBuffer.endDraw();

    waterSpreadDiameter += 4;

    if (waterSpreadDiameter >= sphereWidth * 1.25)
    {
      waterSpreadX = -1;
      waterSpreadY = -1;
    }
  }

  sphereBuffer.image(waterBuffer, 0, 0);

  sphereBuffer.image(landBuffer, 0, 0);
  sphereBuffer.tint(255, 128);
  sphereBuffer.image(cloudSubBuffer, 0, 0);
  sphereBuffer.noTint();
  sphereBuffer.image(cloudBuffer, 0, 0);

  cometBuffer.beginDraw();
  cometBuffer.noStroke();
  cometBuffer.loadPixels();
  for (int i = 0; i < sphereWidth * sphereHeight; i++)
  {
    int alpha = max(0, (cometBuffer.pixels[i] >> 24 & 0xFF) >> 1); // Subtraction also works, may be slower
    cometBuffer.pixels[i] = (cometBuffer.pixels[i] & 0xFFFFFF) + (alpha << 24);
  }
  cometBuffer.updatePixels();
  for (int i = 0; i < comets.size(); i++)
  {
    cometBuffer.fill(comets.get(i).cometColor);
    dab(cometBuffer, comets.get(i).positionX, comets.get(i).positionY, 10);
  }
  cometBuffer.endDraw();

  sphereBuffer.image(cometBuffer, 0, 0);

  sphereBuffer.endDraw();

  outputBuffer.beginDraw();
  outputBuffer.clear();
  outputBuffer.image(sphereBuffer, (sphereWidth / 2 - sphereBearing), 0);
  if (sphereBearing < sphereWidth / 2)
    outputBuffer.image(sphereBuffer, ((sphereWidth / 2) - sphereBearing) - sphereWidth, 0);
  else
    outputBuffer.image(sphereBuffer, ((sphereWidth / 2) - sphereBearing) + sphereWidth, 0);  
  outputBuffer.endDraw();

  minimap.beginDraw();
  minimap.clear();
  minimap.copy(outputBuffer, sphereWidth / 4, 0, sphereWidth / 2, sphereHeight, 0, 0, sphereWidth / 2, sphereHeight);
  if (planetClearAlpha != -1)
  {
    minimap.fill(255, planetClearAlpha);
    minimap.rect(0, 0, sphereWidth / 2, sphereHeight);
  }
  minimap.endDraw();

  outputBuffer.beginDraw();

  if (!gameOver)
  {
    // On-planet reticle
    PImage reticleImage = reticle20px;

    //sphereBuffer.imageMode(CENTER);
    outputBuffer.imageMode(CENTER);
    outputBuffer.image(reticleImage, reticleX, reticleY);

    /*
    sphereBuffer.image(reticleImage, reticleX, reticleY);
     if (reticleX < reticleImage.width / 2) 
     sphereBuffer.image(reticleImage, reticleX + sphereWidth, reticleY);
     else if (reticleX > sphereWidth - (reticleImage.width / 2))
     sphereBuffer.image(reticleImage, reticleX - sphereWidth, reticleY);
     
     if (reticleY < reticleImage.height / 2)
     {
     int wrappedX = (reticleX + (sphereWidth / 2)) % sphereWidth;
     int wrappedY = reticleY * -1;
     
     sphereBuffer.image(reticleImage, wrappedX, wrappedY);
     
     if (wrappedX < reticleImage.width / 2) 
     sphereBuffer.image(reticleImage, wrappedX + sphereWidth, wrappedY);
     else if (wrappedX > sphereWidth - (reticleImage.width / 2))
     sphereBuffer.image(reticleImage, wrappedX - sphereWidth, wrappedY);
     }
     else if (reticleY > sphereHeight - (cloudBrushDiameter / 2))
     {
     int wrappedX = (reticleX + (sphereWidth / 2)) % sphereWidth;
     int wrappedY = sphereHeight + (sphereHeight - reticleY);
     
     sphereBuffer.image(reticleImage, wrappedX, wrappedY);
     
     if (wrappedX < reticleImage.width / 2) 
     sphereBuffer.image(reticleImage, wrappedX + sphereWidth, wrappedY);
     else if (wrappedX > sphereWidth - (reticleImage.width / 2))
     sphereBuffer.image(reticleImage, wrappedX - sphereWidth, wrappedY);
     }
     */
    //sphereBuffer.imageMode(CORNER);
    outputBuffer.imageMode(CORNER);
  }

  if (planetClearAlpha != -1)
  {
    outputBuffer.fill(255, planetClearAlpha);
    outputBuffer.rect(0, 0, sphereWidth, sphereHeight);
    planetClearAlpha = max(-1, planetClearAlpha - 5);
  }

  //sphereBuffer.endDraw();
  outputBuffer.endDraw();

  /*** Draw background ***/
  background(isInEraseMode && !gameOver ? backgroundDestroyEverything : backgroundBottom);  

  /*** Update variables for scrolling animations ***/
  int currentMillis = millis();

  if (isScrollingLeft)
  {
    if (currentMillis >= leftScrollStartMillis + scrollTime)
    {
      activeColor = (activeColor + 1) % numberOfColors;
      isScrollingLeft = false;
      for (int i = 0; i < 4; i++) leftStripIconPositions[i] = defaultStripIconPositions[i];
    }
    else
    {
      for (int i = 0; i < 4; i++)
      {
        leftStripIconPositions[i] = defaultStripIconPositions[i] - 
          (int)lerp(0, stripIconHeight, (currentMillis - leftScrollStartMillis) / (float)scrollTime);
      }
    }
  }

  if (isScrollingRight)
  {
    if (currentMillis >= rightScrollStartMillis + scrollTime)
    {
      activeTool = (activeTool + 1) % numberOfTools;
      isScrollingRight = false;
      for (int i = 0; i < 4; i++) rightStripIconPositions[i] = defaultStripIconPositions[i];
    }
    else
    {
      for (int i = 0; i < 4; i++)
      {
        rightStripIconPositions[i] = defaultStripIconPositions[i] - 
          (int)lerp(0, stripIconHeight, (currentMillis - rightScrollStartMillis) / (float)scrollTime); // Todo: replace with just multiplication dude
      }
    }
  }

  /*** Update variables for swapping animations ***/
  if (isSwappingLeft)
  {
    if (currentMillis >= leftSwapStartMillis + swapTime)
    {
      isSwappingLeft = false;
      leftStripOffset = 0;
    }
    else
    {
      if (currentMillis - leftSwapStartMillis <= swapTime / 2)
      {
        leftStripOffset = 
          (int)lerp(0, stripIconWidth * -1, 
        ((currentMillis - leftSwapStartMillis) / (float)(swapTime / 2.0)));
      }
      else
      {
        leftStripOffset =
          (int)lerp(stripIconWidth * -1, 0, 
        ((currentMillis - leftSwapStartMillis - (swapTime / 2)) / (float)(swapTime / 2.0)));
      }
    }
  }

  if (isSwappingRight)
  {
    if (currentMillis >= rightSwapStartMillis + swapTime)
    {
      isSwappingRight = false;
      rightStripOffset = 0;
    }
    else
    {
      if (currentMillis - rightSwapStartMillis <= swapTime / 2)
      {
        rightStripOffset = 
          (int)lerp(0, stripIconWidth, 
        ((currentMillis - rightSwapStartMillis) / (float)(swapTime / 2.0)));
      }
      else
      {
        rightStripOffset =
          (int)lerp(stripIconWidth, 0, 
        ((currentMillis - rightSwapStartMillis - (swapTime / 2)) / (float)(swapTime / 2.0)));
      }
    }
  }

  if (!gameOver)
  {
    /*** Draw left color strip ***/
    if (!isInEraseMode)
    {
      leftStripBuffer.beginDraw();
      leftStripBuffer.clear();

      for (int i = 0; i < 3; i++) 
      {      
        leftStripBuffer.noTint();
        leftStripBuffer.image(smallIconBackground, 0, leftStripIconPositions[i]);//, stripIconWidth, stripIconHeight);

        leftStripBuffer.tint(iconColor(mod2(activeColor + i - 1, numberOfColors), activeTool));
        leftStripBuffer.image(smallNurdleIcon, 0, leftStripIconPositions[i]);//, stripIconWidth, stripIconHeight);
      }

      leftStripBuffer.endDraw();

      imageMode(CENTER);
      image(leftStripBuffer, leftStripCenterX + leftStripOffset, stripCenterY);
      imageMode(CORNER);
    }

    /*** Draw right tool strip ***/
    if (!isInEraseMode)
    {
      rightStripBuffer.beginDraw();
      rightStripBuffer.clear();

      for (int i = 0; i < 3; i++) 
      {      
        rightStripBuffer.noTint();
        rightStripBuffer.image(smallIconBackground, 0, rightStripIconPositions[i]);//, stripIconWidth, stripIconHeight);

        rightStripBuffer.tint(isInEraseMode ? #ac0014 : #0082ac);
        rightStripBuffer.image(smallToolIcons[mod2(activeTool + i - 1, numberOfTools)], 
        0, rightStripIconPositions[i]);//, stripIconWidth, stripIconHeight);
      }

      rightStripBuffer.endDraw();

      imageMode(CENTER);
      image(rightStripBuffer, rightStripCenterX + rightStripOffset, stripCenterY);
      imageMode(CORNER);

      image(overlayMask, 0, 0);
    }
  }

  /*** Draw overlays ***/
  image(backgroundTop, 0, 0);

  if (!gameOver)
  {
    if (isInEraseMode)
    {
      textFont(confirmationFont);
      textAlign(LEFT, CENTER);
      fill(0);
      text(confirmationStartMillis == -1 ? "5.000" : 
      confirmationStartMillis + confirmationTimeout < millis() ? "BOOM!" : str(
      max((confirmationTimeout - millis() + confirmationStartMillis) / 1000.0, 0)), 
      100, height - 175);
    }
    else
      image(overlay, 0, 0);
  }

  if (timeLimit - (millis() - startingMillis) < 60000) image(overlayTimeWarning, 0, 0);

  if (gameOver == false && timeLimit - (millis() - startingMillis) <= 0 && demoStartMillis == -1)
  {
    startingMillis = -1;
    gameOver = true;
    demoStartMillis = millis();
  }

  textFont(headerFont);
  textAlign(CENTER, CENTER);
  fill(0);
  text(millisToString(timeLimit + startingMillis - millis()), 1280 - 215, 150);

  /*** Draw center icon indicator (active tool) ***/
  if (!gameOver)
  {
    imageMode(CENTER);

    image(iconBackground, displayIconPositionX, displayIconPositionY, displayIconWidth, displayIconHeight);

    if (isInEraseMode) 
    {
      tint(#ac0014);
      image(deleteIcon, displayIconPositionX, displayIconPositionY, displayIconWidth, displayIconHeight);
    }
    else
    {  
      tint(iconColor(activeColor, activeTool));
      image(toolIcons[activeTool], 
      displayIconPositionX, displayIconPositionY, displayIconWidth, displayIconHeight);
    }

    tint(255);

    /*** Draw crosshair ***/
    image(crosshair, 1280 / 2 + ((joystickX + debugCrosshairX) * 0.7), 175 - ((joystickY + debugCrosshairY) * 0.7));

    noTint();
    imageMode(CORNER);
  }
  else
  {
    if (demoStartMillis != -1)
    {
      textFont(confirmationFont);
      fill(0);
      text("Time's Up!", 640, 490);
      text("Planetary Upload in", 640, 590);
      
      textFont(keywordFont);
      text((demoTime + demoStartMillis - millis()) / 1000, 640, 790);

      if (millis() - demoStartMillis >= demoTime)
      {  
        XML planetsXML = loadXML("planets.xml");
        planetList = planetsXML.getChildren();

        boolean foundAName = false;

        while (!foundAName)
        {
          foundAName = true;

          planetName = "";

          planetName += (char)random(65, 91);
          planetName += (char)random(65, 91);
          planetName += (char)random(65, 91);
          println(planetName);

          for (int i = 0; i < planetList.length; i++)
          {
            if (planetName.equals(planetList[i].getContent())) 
            {
              foundAName = false;
            }
          }
        }

        XML newPlanet = planetsXML.addChild("planet");
        newPlanet.setContent(planetName);
        saveXML(planetsXML, dataPath("") + "/planets.xml");

        waterBuffer.save(dataPath("") + "/planets/" + planetName + "/water.png");
        landBuffer.save(dataPath("") + "/planets/" + planetName + "/land.png");
        cloudBuffer.save(dataPath("") + "/planets/" + planetName + "/clouds.png");

        XML cometXml = loadXML("comet XML prototype.xml");
        for (int i = 0; i < comets.size(); i++)
        {
          XML cometEntry = cometXml.addChild("comet");
          cometEntry.setInt("positionX", comets.get(i).positionX);
          cometEntry.setInt("positionY", comets.get(i).positionY);
          cometEntry.setInt("direction", comets.get(i).getDirection());
          cometEntry.setInt("color", comets.get(i).cometColor);
        }

        saveXML(cometXml, dataPath("") + "/planets/" + planetName + "/comets.xml");

        demoStartMillis = -1;
        resetPlanet();
      }
    }
    else
    {
      textFont(confirmationFont);
      fill(0);
      text("Upload Complete! Galactic ID:", 640, 490);
      
      textFont(keywordFont);
      text(planetName, 640, 670);
      
      textFont(confirmationFont);
      text("Play Again at the Hoboken MakerBar", 640, 920);
    }
  }

  /*** Draw minimap ***/
  //image(outputBuffer, 100, 100, (int)(sphereWidth * 3), (int)(sphereHeight * 3));
  image(minimap, 80, 75, sphereWidth, sphereHeight * 2);

  // TODO: Draw a rectangle for the whiteout destroy effect

  if (debugKeyPressed)
  {
    leftButtonWasPressed = leftButtonIsPressed;
    rightButtonWasPressed = rightButtonIsPressed;
    bigAssButtonWasPressed = bigAssButtonIsPressed;
    triggerWasPulled = triggerIsPulled;
    switchWasActivated = switchIsActivated;
    debugKeyPressed = false;
  }

  println(frameRate);
}


void mask2(PImage image, PImage mask)
{
  image.loadPixels();

  for (int i = 0; i < image.width * image.height; i++)
  {
    color oldPixel = image.pixels[i];
    color maskPixel = mask.pixels[i];

    image.pixels[i] = (min(maskPixel & 0xFF, (oldPixel >> 24) & 0xFF) << 24) + (oldPixel & 0xFFFFFF);
  }

  image.updatePixels();
}


void keyPressed()
{
  switch(key)
  {
  case 'a':
    leftButtonWasPressed = leftButtonIsPressed;
    leftButtonIsPressed = true;
    debugKeyPressed = true;
    break;

  case 's':
    bigAssButtonWasPressed = bigAssButtonIsPressed;
    bigAssButtonIsPressed = true;
    debugKeyPressed = true;
    break;

  case 'd':
    rightButtonWasPressed = rightButtonIsPressed;
    rightButtonIsPressed = true;
    debugKeyPressed = true;
    break;

  case 'f':
    switchWasActivated = switchIsActivated;
    switchIsActivated = true;
    debugKeyPressed = true;
    break;

  case 'g':
    triggerWasPulled = triggerIsPulled;
    triggerIsPulled = true;
    debugKeyPressed = true;
    break;

  case 'z':
    debugSphereBearingModifier--;
    break;

  case 'x':
    debugSphereBearingModifier++;
    break;

  case CODED:
    switch (keyCode)
    {
    case UP:
      //debugCrosshairY = min(128, debugCrosshairY + 128);
      joystickY = 64;
      //chicken += 0.05;
      //println(chicken);
      break;

    case DOWN:
      //debugCrosshairY = max(-128, debugCrosshairY - 128);
      joystickY = -64;
      //      chicken -= 0.05;
      //      println(chicken);
      break;

    case RIGHT:
      //debugCrosshairX = min(128, debugCrosshairX + 128);
      joystickX = 64;
      break;

    case LEFT:
      //debugCrosshairX = max(-128, debugCrosshairX - 128);
      joystickX = -64;
      break;
    }
    break;
  }
}


void keyReleased()
{
  switch (key)
  {
  case 'a':
    leftButtonWasPressed = leftButtonIsPressed;
    leftButtonIsPressed = false;
    debugKeyPressed = true;
    break;

  case 's':
    bigAssButtonWasPressed = bigAssButtonIsPressed;
    bigAssButtonIsPressed = false;
    debugKeyPressed = true;
    break;

  case 'd':
    rightButtonWasPressed = rightButtonIsPressed;
    rightButtonIsPressed = false;
    debugKeyPressed = true;
    break;

  case 'f':
    switchWasActivated = switchIsActivated;
    switchIsActivated = false;
    debugKeyPressed = true;
    break;

  case 'g':
    triggerWasPulled = triggerIsPulled;
    triggerIsPulled = false;
    debugKeyPressed = true;
    break;  

  case CODED:
    switch (keyCode)
    {
    case UP:
      //debugCrosshairY -= 128;
      joystickY = 0;
      break;

    case DOWN:
      //debugCrosshairY += 128;
      joystickY = 0;
      break;

    case RIGHT:
      //debugCrosshairX -= 128;
      joystickX = 0;
      break;

    case LEFT:
      //debugCrosshairX += 128;
      joystickX = 0;
      break;
    }
    break;
  }
}


void serialEvent(Serial serial)
{  
  int nextByte = 0;

  nextByte = serial.read();
  /*
  print(hex(nextByte));
   print(' ');
   */
  if (nextByte == 0xFF)
  {
    nextByte = serial.read();
    /*
    print(hex(nextByte));
     print(' ');
     */
    if (nextByte == 0xFF)
    {
      nextByte = serial.read();
      /*
      print(hex(nextByte));
       print(' ');
       */
      if (nextByte == 0xFF)
      { 
        if (!processedControls)
        {
          /*
          print(hex(serial.read()));
           print(hex(serial.read()));
           print(hex(serial.read()));
           println();
           */
          serial.read();
          serial.read();
          serial.read();
          return;
        }

        leftButtonWasPressed = leftButtonIsPressed;
        rightButtonWasPressed = rightButtonIsPressed;
        bigAssButtonWasPressed = bigAssButtonIsPressed;
        triggerWasPulled = triggerIsPulled;
        switchWasActivated = switchIsActivated;

        nextByte = serial.read();
        /*
        print(hex(nextByte));
         print(' ');
         */

        int buttonStates = nextByte;
        leftButtonIsPressed = boolean(buttonStates & 0x01);
        bigAssButtonIsPressed = boolean(buttonStates & 0x02);
        rightButtonIsPressed = boolean(buttonStates & 0x04);
        triggerIsPulled = boolean(buttonStates & 0x08);
        switchIsActivated = boolean(buttonStates & 0x10);

        nextByte = serial.read();
        /*
        print(hex(nextByte));
         print(' ');
         */

        joystickX = nextByte - 128;

        nextByte = serial.read();
        /*
        print(hex(nextByte));
         print(' ');
         */

        joystickY = nextByte - 128;

        processedControls = false;
        //serial.write('Z');
      }
    }
  }

  //serial.clear();
  //println();
}


String millisToString(int millis)
{
  if (millis < 0) return "0:00";

  int minutes = millis / 1000 / 60;
  int seconds = millis / 1000 % 60;
  String output = str(minutes) + ':' + (seconds < 10 ? '0': "") + str(seconds);

  return output;
}


color iconColor(int colorIndex, int toolIndex)
{
  switch(activeTool)
  {
  case TOOL_WATER:
    return waterColorValues[colorIndex];

  case TOOL_LAND:
  case TOOL_COMET:
    return colorValues[colorIndex];

  case TOOL_CLOUD:
    return cloudColorValues[colorIndex];

    /*
  case TOOL_APOCALYPSE:
     return #ac0014;
     */

  default:
    return #000000;
  }
}


int mod2(int a, int b)
{
  return (a % b + b) % b;
}


void brush(PGraphics buffer, int x1, int y1, int x2, int y2, color fill, int diameter)
{
  buffer.beginDraw();
  buffer.noStroke();
  buffer.fill(iconColor(activeColor, activeTool));

  int numberOfSteps = (int)(sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2)) / 3.0);

  if (numberOfSteps == 0)
  {
    dab(buffer, x2, y2, diameter);
    buffer.endDraw();
    return;
  }

  for (int i = 1; i <= numberOfSteps; i++)
  {
    dab(buffer, 
    (int)lerp(x1, x2, i / (float)numberOfSteps), 
    (int)lerp(y1, y2, i / (float)numberOfSteps), 
    diameter);
  }

  buffer.endDraw();
}


void spray(PGraphics buffer, int x1, int y1, int x2, int y2, color fill, int diameter, int sprayRadius)
{
  buffer.beginDraw();
  buffer.noStroke();
  buffer.fill(iconColor(activeColor, activeTool));

  int numberOfSteps = (int)(sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2)) / 3.0);

  if (numberOfSteps == 0)
  {
    for (int i = 0; i < 5; i++)
    {
      dab(buffer, 
      (int)random(-sprayRadius, sprayRadius) + x2, 
      (int)random(-sprayRadius, sprayRadius) + y2, 
      diameter, diameter / 2);
    }
    buffer.endDraw();
    return;
  }

  for (int i = 1; i <= numberOfSteps; i++)
  {
    for (int j = 0; j < 1; j++)
    {
      dab(buffer, 
      (int)random(-sprayRadius, sprayRadius) + (int)lerp(x1, x2, i / (float)numberOfSteps), 
      (int)random(-sprayRadius, sprayRadius) + (int)lerp(y1, y2, i / (float)numberOfSteps), 
      diameter, diameter / 2);
    }
  }

  buffer.endDraw();
}


void dab(PGraphics buffer, int x, int y, int diameterX, int diameterY)
{
  buffer.ellipse(x, y, diameterX, diameterY);
  if (x < diameterX / 2) 
    buffer.ellipse(x + sphereWidth, y, diameterX, diameterY);
  else if (x > sphereWidth - (diameterX / 2))
    buffer.ellipse(x - sphereWidth, y, diameterX, diameterY);

  if (y < diameterY / 2)
  {
    int wrappedX = (x + (sphereWidth / 2)) % sphereWidth;
    int wrappedY = y * -1;
    buffer.ellipse(wrappedX, wrappedY, diameterX, diameterY);

    if (wrappedX < diameterX / 2) 
      buffer.ellipse(wrappedX + sphereWidth, wrappedY, diameterX, diameterY);
    else if (wrappedX > sphereWidth - (diameterX / 2))
      buffer.ellipse(wrappedX - sphereWidth, wrappedY, diameterX, diameterY);
  }
  else if (y > sphereHeight - (diameterY / 2))
  {
    int wrappedX = (x + (sphereWidth / 2)) % sphereWidth;
    int wrappedY = sphereHeight + (sphereHeight - y);

    buffer.ellipse(wrappedX, wrappedY, diameterX, diameterY);

    if (wrappedX < diameterX / 2) 
      buffer.ellipse(wrappedX + sphereWidth, wrappedY, diameterX, diameterY);
    else if (wrappedX > sphereWidth - (diameterX / 2))
      buffer.ellipse(wrappedX - sphereWidth, wrappedY, diameterX, diameterY);
  }
}


void dab(PGraphics buffer, int x, int y, int diameter)
{
  dab(buffer, x, y, diameter, diameter);
}


void resetPlanet()
{
  planetClearAlpha = 300;

  waterBuffer.beginDraw();
  waterBuffer.clear();
  waterBuffer.endDraw();

  landBuffer.beginDraw();
  landBuffer.clear();
  landBuffer.endDraw();

  cloudBuffer.beginDraw();
  cloudBuffer.clear();
  cloudBuffer.endDraw();

  comets.clear();

  activeTool = TOOL_WATER;
  activeColor = (int)random(numberOfColors);

  sphereBearing = sphereWidth / 2;
}

