// Text settings
PFont font;
int fontSize = 102;
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

// Position smoothing variables
float prevSpotX, prevSpotY, prevSpot2X, prevSpot2Y;
float transitionSpeed = 0.15;  // Lower = smoother but slower transitions

void setup() {
  size(400, 400);

  // Initialize font - keeping the original font name
  font = createFont("AeonikPro-Bold", fontSize);
  textFont(font, fontSize);
  textAlign(CENTER, CENTER);

  // Set drawing modes
  rectMode(CENTER);
  imageMode(CENTER);
  noStroke();

  // Initialize position variables
  prevSpotX = prevSpot2X = width/2;
  prevSpotY = prevSpot2Y = height/2;

  // Create buffers
  createSpotlightBuffers();

  // Display instructions
  println("Controls:");
  println("+ / - : Adjust blur amount");
  println("[ / ] : Adjust spotlight size");
  println("< / > : Adjust transparency");
  println("a     : Toggle auto movement");
  println("r     : Reset animation");
  println("s     : Switch animation state");
  println("f / F : Adjust animation smoothness");
}

void draw() {
  // Black background
  background(0);

  // Calculate target spotlight positions
  float targetSpotX = width/2;
  float targetSpotY = height/2;
  float targetSpot2X = width/2;
  float targetSpot2Y = height/2;

  if (autoMove) {
    // Complex auto movement pattern
    if (animationState == "spiral-in") {
      // Spiral in from corners to center
      float spiralRadius = width/2 * (1 - animationProgress);
      float spiralAngle = TWO_PI * animationProgress / spiralTightness;

      // First spotlight spirals in from top-left
      targetSpotX = width/2 + cos(spiralAngle) * spiralRadius;
      targetSpotY = height/2 + sin(spiralAngle) * spiralRadius;

      // Second spotlight spirals in from opposite corner (bottom-right)
      targetSpot2X = width/2 + cos(spiralAngle + PI) * spiralRadius;
      targetSpot2Y = height/2 + sin(spiralAngle + PI) * spiralRadius;

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
      float secondaryX = cos(autoAngle * danceFactor) * (centerDanceRadius/3);
      float secondaryY = sin(autoAngle * danceFactor) * (centerDanceRadius/3);

      // Combine motions for first spotlight
      targetSpotX = baseX + secondaryX;
      targetSpotY = baseY + secondaryY;

      // Second spotlight mirror moves
      targetSpot2X = width - targetSpotX;
      targetSpot2Y = height - targetSpotY;

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
    targetSpotX = mouseX;
    targetSpotY = mouseY;
    targetSpot2X = width - mouseX;
    targetSpot2Y = height - mouseY;

    // Make mouse movement respond faster
    transitionSpeed = 0.4;
  }

  // Apply smooth transitions to the spotlight positions
  prevSpotX = lerp(prevSpotX, targetSpotX, transitionSpeed);
  prevSpotY = lerp(prevSpotY, targetSpotY, transitionSpeed);
  prevSpot2X = lerp(prevSpot2X, targetSpot2X, transitionSpeed);
  prevSpot2Y = lerp(prevSpot2Y, targetSpot2Y, transitionSpeed);

  // PART 1: Draw very dim text in background - this is visible in dark areas
  fill(textColor, 20);
  text(displayText, width/2, height/2);

  // PART 2: Draw spotlights in ADD mode
  blendMode(ADD);

  // Fixed opacity here - key to stability
  tint(255, spotlightAlpha);
  image(spotlightOneBuffer, prevSpotX, prevSpotY);
  image(spotlightTwoBuffer, prevSpot2X, prevSpot2Y);

  // PART 3: Draw final text layer in ADD mode - this gets bright in lit areas
  fill(textColor, 60);
  text(displayText, width/2, height/2);

  // Reset blend mode
  blendMode(BLEND);
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
  spotlightOneBuffer.background(0, 0); // Transparent background
  spotlightOneBuffer.ellipseMode(CENTER);
  spotlightOneBuffer.noStroke();

  // Draw multiple circles with decreasing opacity for a softer gradient
  int steps = 5;
  for (int i = 0; i < steps; i++) {
    float size = spotlightSize * (1 - (float)i/steps);
    int alpha = 255 - (i * 40);
    spotlightOneBuffer.fill(red(spotlightOneColor), green(spotlightOneColor), blue(spotlightOneColor), alpha);
    spotlightOneBuffer.ellipse(bufferSize/2, bufferSize/2, size, size);
  }

  // Apply strong blur for extra softness
  spotlightOneBuffer.filter(BLUR, blurAmount);
  spotlightOneBuffer.endDraw();

  // Draw second spotlight
  spotlightTwoBuffer.beginDraw();
  spotlightTwoBuffer.clear();
  spotlightTwoBuffer.background(0, 0); // Transparent background
  spotlightTwoBuffer.ellipseMode(CENTER);
  spotlightTwoBuffer.noStroke();

  // Draw multiple circles with decreasing opacity for a softer gradient
  for (int i = 0; i < steps; i++) {
    float size = spotlightSize * (1 - (float)i/steps);
    int alpha = 255 - (i * 40);
    spotlightTwoBuffer.fill(red(spotlightTwoColor), green(spotlightTwoColor), blue(spotlightTwoColor), alpha);
    spotlightTwoBuffer.ellipse(bufferSize/2, bufferSize/2, size, size);
  }

  // Apply strong blur for extra softness
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

  // Transition speed adjustment
  else if (key == 'f') {
    transitionSpeed = constrain(transitionSpeed - 0.02, 0.01, 1.0);
    println("Transition smoothness: " + nf(1-transitionSpeed, 0, 2) + " (higher = smoother)");
  } else if (key == 'F') {
    transitionSpeed = constrain(transitionSpeed + 0.02, 0.01, 1.0);
    println("Transition smoothness: " + nf(1-transitionSpeed, 0, 2) + " (higher = smoother)");
  }

  // Toggle auto movement
  else if (key == 'a' || key == 'A') {
    autoMove = !autoMove;
    // When switching to auto mode, use smoother transitions
    if (autoMove) transitionSpeed = 0.15;
  }

  // Reset animation
  else if (key == 'r' || key == 'R') {
    animationState = "spiral-in";
    animationProgress = 0;
    autoAngle = 0;

    // Reset positions to avoid jumps
    prevSpotX = prevSpot2X = width/2;
    prevSpotY = prevSpot2Y = height/2;
  }

  // Switch animation state
  else if (key == 's' || key == 'S') {
    if (animationState == "spiral-in") {
      animationState = "dance";
      animationProgress = 0;
    } else {
      animationState = "spiral-in";
      animationProgress = 0;
    }
  }

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
