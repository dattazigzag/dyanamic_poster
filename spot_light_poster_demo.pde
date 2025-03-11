// Text settings
PFont font;
int fontSize = 72;
String displayText = "We are\nhiring";

// Spotlight settings
PGraphics spotlightOneBuffer;
PGraphics spotlightTwoBuffer;
int spotlightSize = 220;        // Size of the circle spotlight
int spotlightSpread = 100;      // Extra padding for blur spread
int blurAmount = 15;            // Blur intensity (1-20)
int spotlightAlpha = 150;       // Transparency level (0-255)

// Colors (using hex colors for readability)
color spotlightOneColor = #75FBCF;  // Greenish
color spotlightTwoColor = #A4B2FA;  // Bluish
color textColor = #FFFFFF;          // White

// Mode settings
boolean autoMove = false;
float autoAngle = 0;
int autoRadius = 100;
float spiralTightness = 0.15;  // Controls how quickly the spiral tightens
float centerDanceRadius = 40;  // How far from center the spotlights orbit when dancing
float danceFactor = 3;         // Creates the dancing effect at center
String animationState = "spiral-in"; // Can be "spiral-in" or "dance"
float animationProgress = 0;   // 0 to 1 for spiral-in, continuous for dance

void setup() {
  size(400, 400);

  // Initialize font
  font = createFont("Arial", fontSize); // Changed to createFont to avoid dependency on .vlw files
  textFont(font, fontSize);
  textAlign(CENTER, CENTER);

  // Set drawing modes
  rectMode(CENTER);
  imageMode(CENTER);
  noStroke();

  // Create spotlights
  createSpotlightBuffers();

  // Display instructions
  println("Controls:");
  println("+ / - : Adjust blur amount");
  println("[ / ] : Adjust spotlight size");
  println("< / > : Adjust transparency");
  println("a     : Toggle auto movement");
  println("r     : Reset animation");
  println("s     : Switch animation state");
  println("t     : Change text");
}

void draw() {
  // Black background
  background(0);

  // Draw the text
  fill(textColor);
  text(displayText, width/2, height/2);

  // Calculate spotlight positions
  float spotX = width/2;  // Default initialization
  float spotY = height/2;
  float spot2X = width/2;
  float spot2Y = height/2;

  if (autoMove) {
    // Complex auto movement pattern
    if (animationState == "spiral-in") {
      // Spiral in from corners to center
      float spiralRadius = width/2 * (1 - animationProgress);
      float spiralAngle = TWO_PI * animationProgress / spiralTightness;

      // First spotlight spirals in from top-left
      spotX = width/2 + cos(spiralAngle) * spiralRadius;
      spotY = height/2 + sin(spiralAngle) * spiralRadius;

      // Second spotlight spirals in from opposite corner (bottom-right)
      spot2X = width/2 + cos(spiralAngle + PI) * spiralRadius;
      spot2Y = height/2 + sin(spiralAngle + PI) * spiralRadius;

      // Advance the animation
      animationProgress += 0.005;

      // Transition to dancing when we reach the center
      if (animationProgress >= 1) {
        animationState = "dance";
        animationProgress = 0;
        autoAngle = 0;
      }
    } else if (animationState == "dance") {
      // Complex dancing pattern near the center
      // Main circular motion
      float baseX = width/2 + cos(autoAngle) * centerDanceRadius;
      float baseY = height/2 + sin(autoAngle) * centerDanceRadius;

      // Add secondary motion for more interesting orbit
      float secondaryX = cos(autoAngle * danceFactor) * (centerDanceRadius/2);
      float secondaryY = sin(autoAngle * danceFactor) * (centerDanceRadius/2);

      // Combine motions for first spotlight
      spotX = baseX + secondaryX;
      spotY = baseY + secondaryY;

      // Second spotlight mirror moves
      spot2X = width - spotX;
      spot2Y = height - spotY;

      // Advance the animation
      autoAngle += 0.02;

      // Reset back to spiral-in after a full dance cycle (about 10 seconds)
      if (autoAngle >= TWO_PI * 3) {  // 3 full rotations
        animationState = "spiral-in";
        animationProgress = 0;
      }
    }
  } else {
    // Mouse-controlled movement
    spotX = mouseX;
    spotY = mouseY;
    spot2X = width - mouseX;
    spot2Y = height - mouseY;
  }

  // Draw the blurred, translucent circles
  tint(255, spotlightAlpha);
  image(spotlightOneBuffer, spotX, spotY);
  image(spotlightTwoBuffer, spot2X, spot2Y);

  // Display info in corner (uncomment if needed for debugging)
  // fill(255);
  // textSize(12);
  // text("FPS: " + int(frameRate) + " | Blur: " + blurAmount + " | Size: " + spotlightSize, 10, 15);
  // textSize(fontSize); // Reset text size
}

void createSpotlightBuffers() {
  // Calculate total buffer size needed
  int bufferSize = spotlightSize + spotlightSpread;

  // Create buffers
  spotlightOneBuffer = createGraphics(bufferSize, bufferSize);
  spotlightTwoBuffer = createGraphics(bufferSize, bufferSize);

  // Draw first spotlight
  spotlightOneBuffer.beginDraw();
  spotlightOneBuffer.clear();
  spotlightOneBuffer.ellipseMode(CENTER);
  spotlightOneBuffer.noStroke();
  spotlightOneBuffer.fill(spotlightOneColor);
  spotlightOneBuffer.ellipse(bufferSize/2, bufferSize/2, spotlightSize, spotlightSize);
  spotlightOneBuffer.filter(BLUR, blurAmount);
  spotlightOneBuffer.endDraw();

  // Draw second spotlight
  spotlightTwoBuffer.beginDraw();
  spotlightTwoBuffer.clear();
  spotlightTwoBuffer.ellipseMode(CENTER);
  spotlightTwoBuffer.noStroke();
  spotlightTwoBuffer.fill(spotlightTwoColor);
  spotlightTwoBuffer.ellipse(bufferSize/2, bufferSize/2, spotlightSize, spotlightSize);
  spotlightTwoBuffer.filter(BLUR, blurAmount);
  spotlightTwoBuffer.endDraw();
}

// Handle user input
void keyPressed() {
  boolean needsUpdate = false;

  // Blur adjustment
  if (key == '+' || key == '=') {
    blurAmount = constrain(blurAmount + 1, 1, 30);
    needsUpdate = true;
  } else if (key == '-' || key == '_') {
    blurAmount = constrain(blurAmount - 1, 1, 30);
    needsUpdate = true;
  }

  // Size adjustment
  else if (key == ']') {
    spotlightSize = constrain(spotlightSize + 10, 50, 400);
    needsUpdate = true;
  } else if (key == '[') {
    spotlightSize = constrain(spotlightSize - 10, 50, 400);
    needsUpdate = true;
  }

  // Alpha adjustment
  else if (key == '.' || key == '>') {
    spotlightAlpha = constrain(spotlightAlpha + 10, 10, 255);
  } else if (key == ',' || key == '<') {
    spotlightAlpha = constrain(spotlightAlpha - 10, 10, 255);
  }

  // Toggle auto movement
  else if (key == 'a' || key == 'A') {
    autoMove = !autoMove;
  }

  // Change text
  //else if (key == 't' || key == 'T') {
  //  String[] texts = {"We are\nhiring", "Join\nour team", "Creative\ndesign", "Hello\nworld"};
  //  displayText = texts[int(random(texts.length))];
  //}

  // Recreate buffers if needed
  if (needsUpdate) {
    createSpotlightBuffers();
  }

  // Print current settings when any key is pressed
  println("Blur: " + blurAmount + " | Size: " + spotlightSize + " | Alpha: " + spotlightAlpha);
}

void mouseWheel(MouseEvent event) {
  // Adjust auto-move radius with mouse wheel
  if (autoMove) {
    autoRadius = constrain(autoRadius + event.getCount() * 5, 20, 200);
  }
}
