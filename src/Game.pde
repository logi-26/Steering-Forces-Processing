PFont font;                                                            // Font to be used
int time;                                                              // Time between asteroid spawns
int gameEndTimer = 120;                                                // Game runs after player dies for short time
int asteroidHealth = 1;                                                // Determine if asteroid is alive
int score;                                                             // The players score
int particleWeaponNumber = 2;                                          // Number of particle weapon bullets at start of game
int seekerWeaponNumber = 2;                                            // Number of seeker weapon bullets at start of game
int finalMouseX = 0;                                                   // Used to prevent player moving after death
float currentGravity = 0.08;                                           // Start gravity (increases with each level)
float shots;                                                           // Counts player shots (to calculate accuracy)
float hits;                                                            // Counts player hits (to calculate accuracy)
boolean shoot;                                                         // Determines if player is currently shooting the weapon
boolean gameOver = false;                                              // Determines if the game is over
boolean playerParticleSystemRunning = false;                           // Determines if the player particle system is running
ArrayList<ParticleSystem> asteroidParticleSystemArray;                 // List of asteroid particle systems
ArrayList<ParticleSystem> playerParticleSystemArray;                   // List of player particle systems
ArrayList<ParticleSystem> weaponParticleSystemArray;                   // List of weapons particle systems (for special particle weapon)
ArrayList<Asteroid> asteroidArray;                                     // List of asteroids
boolean flowFieldUpdated = false;                                      // Used to check if the flow field has been updated
FlowField flowfield;                                                   // Flowfield object
Seeker seekerWeapon;                                                   // Seeker weapon object
boolean seekerWeaponActive = false;                                    // Used to check if the seeker weapon is currently active
boolean debug = false;                                                 // Used to toggle the flow field display (Spacebar toggles)


void setup() {
  
  font = loadFont("AgencyFB-Reg-20.vlw");                              // Set the font that will be used
  size(800,900);                                                       // Set the window size
  smooth();
  
  flowfield = new FlowField(40, 800, 900);                             // Initialise the flow field with a resolution of 40
  
  asteroidArray = new ArrayList<Asteroid>();                           // Initialise the asteroid array list
  asteroidParticleSystemArray = new ArrayList<ParticleSystem>();       // Initialise the asteroid particle array list
  playerParticleSystemArray = new ArrayList<ParticleSystem>();         // Initialise the player particle array list
  weaponParticleSystemArray = new ArrayList<ParticleSystem>();         // Initialise the special weapon particle array list
  noCursor();
}


void draw() {
  
  background(0);
  frameRate(30);

  // If the player has not been killed
  if (!gameOver) {
    
    // Display the flowfield in "debug" mode
    if (debug) flowfield.display();
 
    // Draws the player ship
    fill(229,154,48);
    stroke(229,154,48);
    rect(mouseX-20,830,40,30);
    rect(mouseX-10,820,20,40);
    
    // If the player shoots the standard weapon
    if (shoot) {
      stroke(255, 0, 0);
      // Draws the standard weapon shot (line)
      line(mouseX,0,mouseX,820);                                          
      stroke(0);
    }
    hitCheck();
    time++;
  }
  
  // This runs for a short time after the player has been died
  if (gameEndTimer > 0) {

    spawnAsteroid();                                                  // Create the asteroids
    update();
    
    // Draws the arena walls
    fill(255); 
    stroke(255);
    rect(0,860,width,height-860);                                     // Bottom wall
    rect(0,0,5,height);                                               // Left wall
    rect(width - 5,0,5,height);                                       // Right wall
    
    // Game text
    fill(0);
    textFont(font, 24);
    text("Particle Bullets: " + particleWeaponNumber, 20,890);        // Displays the number of particle bullets the player currently has
    text("Seeker Bullets: " + seekerWeaponNumber, 240,890);           // Displays the number of seeker bullets the player currently has
    text("Debug: " + debug, 450,890);                                 // Displays the current score
    text("Accuracy: " + int(hits) + "/" + int(shots), 640, 890);      // Displays the players accuracy
  } else {
    // If the game is over
    fill(255,0,0);                                                    // Set the font colour (red)
    textFont(font, 60);                                               // Set the font size
    text("YOU LOSE",100,100);                                         // Displays the "You lose" text (There is no way of winning this game lol)
    textFont(font,40);                                                // Decrease the font size
    text("SCORE: " + score,100,150);                                  // Displays the players final score
    fill(255);                                                        // Set the font colour (white)
    text("PRESS ENTER TO START A NEW GAME" ,100,250);                 // Tells the user to hit enter if they want to start a new game
  }
  shoot = false;
}


// Mouse pressed event handler
void mousePressed() {
  
  // If the left mouse button is pressed
  if (mouseButton == LEFT && !gameOver) {
    shoot = true;
    shots ++;
  }
  
  // If the right mouse button is pressed
  if (mouseButton == RIGHT && !gameOver) {
    if (particleWeaponNumber > 0) ShootSpecialWeapon();
  }
  
  if (mouseButton == CENTER && !gameOver) {
    if (seekerWeaponNumber > 0)ShootSeekerWeapon();
  }
}


// Key pressed event handler
void keyPressed() {
  
  // If the enter key is pressed
  if (key == ENTER) {
    if (gameOver && gameEndTimer == 0) startNewGame();
  } 
  
  // If the space key is pressed
  if (key == ' ') debug = !debug;
}


// This function updates the asteroids and the particle systems
void update() {
  
  if (gameOver) {
    gameEndTimer--;
    
    // Run any particle systems that are in the player particle system array list
    for (ParticleSystem ps: playerParticleSystemArray) ps.run();
  }
 
   if (!flowFieldUpdated && score % 4 == 0) {
     flowfield.init();
     flowFieldUpdated = true;
   }

  // Update the asteroids
  updateAsteroid();          

  // Run any particle systems that are in the weapon particle system array list
  for (ParticleSystem ps: weaponParticleSystemArray) ps.run();
  
  if (seekerWeaponActive && asteroidArray.size() > 0) {
    
    Asteroid theAsteroid = (Asteroid)asteroidArray.get(0);
    seekerWeapon.seek(theAsteroid.location);
    seekerWeapon.update();
    seekerWeapon.display();
    
    if (seekerWeapon.hitAsteroid(asteroidArray, asteroidParticleSystemArray)) seekerWeaponActive = false;
  }
}


// This function spawns the asteroids
void spawnAsteroid() {
  
  if (time == 30) {
    time = 0;
    PVector asteroidLocation = new PVector(int(random(30,width - 50)), 0);  
    float asteroidMass = random(0.8, 3);
    float asteroidMaxForce = random(0.1, 0.5);
    float asteroidMaxSpeed = random(2, 5);
    Asteroid theAsteroid = new Asteroid(asteroidLocation, asteroidMass, asteroidHealth, asteroidMaxForce, asteroidMaxSpeed);
    asteroidArray.add(theAsteroid);
    theAsteroid = null;
  }
}


// This function updates the asteroids
void updateAsteroid() {
  
  // Loop through the asteroid array list
  for (Asteroid theAsteroid: asteroidArray) {
    
    if (gameEndTimer > 0) {

      // Loop through the asteroid particle system array list
      for (ParticleSystem ps: asteroidParticleSystemArray) ps.applyRepeller(theAsteroid);
      
      // Update and display the asteroids
      theAsteroid.follow(flowfield);
      theAsteroid.update();                                                                            // Updates the asteroid
      
      theAsteroid.checkBorders();                                                                      
      
      theAsteroid.display();                                                                           // Displays the asteroid
      gameOver = theAsteroid.outOfBounds(gameOver);                                                    // Checks if any asteroid is outside the game arena (if so, its game over)
      
      if (!gameOver) finalMouseX = mouseX;                                                             // This records the last location of the mouse X position
      if (gameOver && !playerParticleSystemRunning) playerParticleSystem(30);                          // When the game is over the player ship exlodes (player particle system)
    }
  }
  for (ParticleSystem ps: asteroidParticleSystemArray) ps.run();                                       // Run any particle systems that are in the asteroid particle system array list
}


// This function checks for collisions between the objects
void hitCheck() {
  
  // If the player has shot the standard weapon
  if (shoot) checkWeaponHit();
    
  checkAsteroidHitPlayer();                                                                            // Check if an asteroid has hit the player ship
  checkParticleHitPlayer();                                                                            // Check if an asteroid particle has hit the player ship
  checkSpecialWeaponHit();                                                                             // Check if a particle from the players special weapon has hit any asteroids
}


// This function creates the asteroid particle systems
void createParticleSystem(Asteroid theAsteroid) {
  ps = new ParticleSystem(theAsteroid.location);
  float particleSize = theAsteroid.mass * 3;                                                           // The asteroid particles size is relative to the size of the asteroid
  int red = 255;                                                                                       // Asteroid particles are red
  int green = 0;
  int blue = 0;
  for(int i = 0; i < 10; i++) ps.addParticle(particleSize, red, green, blue);                          // This adds 10 red particles with the size relative to the asteroid that spawns them

  PVector gravity = new PVector(0,1);                                                                  // This sets the gravitational force
  ps.applyForce(gravity);                                                                              // This applies the gravitational force to the particle
  asteroidParticleSystemArray.add(ps);                                                                 // This adds the particle to the asteroid particle system array list
}


// This function creates the player ship particle systems
void playerParticleSystem(int number) {
  gameOver = true;                                                                                     // When the player ship dies, the game over boolean is set true
  playerParticleSystemRunning = true;                                                                  // Boolean to show the player particle system is now running
  PVector location  = new PVector(finalMouseX,830);                                                    // The player particle system is located at the mouses last X position
  ps = new ParticleSystem(location);                                                                   // Creates the player particle system at the location
  float particleSize = 8;                                                                              // Player particle size is pre-determined
  int red = 229;                                                                                       // This sets the player particle colour (orange)
  int green = 154;
  int blue = 48;
  for(int i = 0; i < number; i++) ps.addParticle(particleSize, red, green, blue);                      // This adds the specific number of particles to the player particle array list

  PVector gravity = new PVector(0,0.1);                                                                // This sets the gravitational force
  ps.applyForce(gravity);                                                                              // This applies the gravitational force to the particle
  playerParticleSystemArray.add(ps);                                                                   // This adds the particle to the player particle system array list
}


// This function shoots the special weapon (Called when the right mouse button is clicked)
void ShootSpecialWeapon() {
  
  particleWeaponNumber --;                                                                             // Increments the number of available special weapons
  stroke(0, 255, 0);
  line(mouseX,height/2,mouseX,820);                                                                    // Draws the line for the special weapons
  
  PVector location  = new PVector(mouseX,height/2);                                                    // Location for the special weapon particle system
  ps = new ParticleSystem(location);
  float particleSize = 8;                                                                              // Special weapon particle size is pre-determined
  int red = 0;
  int green = 255;                                                                                     // Sets the special weapon particle colour (green) 
  int blue = 0;
  for(int i = 0; i < 50; i++) ps.addParticle(particleSize, red, green, blue);                          // Adds 50 green particles to the special weapon particle array list
  
  PVector gravity = new PVector(0,0.4);                                                                // This sets the gravitational force  
  ps.applyForce(gravity);                                                                              // This applies the gravitational force to the particle
  weaponParticleSystemArray.add(ps);                                                                   // This adds the particle to the special weapon particle system array list
  stroke(0);
}


// This function shoots the seeker weapon (Called when the middle mouse button is clicked)
void ShootSeekerWeapon() {
  
  if (!seekerWeaponActive) {
  
    PVector location  = new PVector(mouseX,810);                                                         // Location for the special weapon particle system
    seekerWeapon = new Seeker(location);
    PVector gravity = new PVector(0,0.4);                                                                // This sets the gravitational force  
    seekerWeapon.applyForce(gravity);                                                                    // This applies the gravitational force to the particle
    seekerWeapon.display();
    seekerWeaponActive = true;
    seekerWeaponNumber --;
  }
}


// This function starts a new game (Called when game is over and enter key is pressed)
void startNewGame() {
  
   // This had to be called 3 times in order to fully remove all current asteroids
   // without the outer loop the player particles continued to spawn
   for(int j = 0; j < 3; j++) {
     // This removes all of the asteroids from the asteroid array list
     for(int i = 0; i < asteroidArray.size(); i++) {
        Asteroid theAsteroid = (Asteroid)asteroidArray.get(i); 
        theAsteroid = null;
        asteroidArray.remove(i);
      }
   }
  
  // This removes all of the particles from the asteroid particle system array list
  for(int i = 0; i < asteroidParticleSystemArray.size(); i++) {
    ParticleSystem ps = (ParticleSystem)asteroidParticleSystemArray.get(i);
    ps = null;
    asteroidParticleSystemArray.remove(i);
  }
  
  // This removes all of the particles from the player particle system array list
  for(int i = 0; i < playerParticleSystemArray.size(); i++) {
    ParticleSystem ps = (ParticleSystem)playerParticleSystemArray.get(i);
    ps = null;
    playerParticleSystemArray.remove(i);
  }
  
  // Resets the main game variables when a new game begins
  gameOver = false;
  gameEndTimer = 120;                                  
  currentGravity = 0.08;
  score = 0;
  shots = 0;
  hits = 0;
  playerParticleSystemRunning = false;
  particleWeaponNumber = 2;
  seekerWeaponNumber = 2;
}


// This function checks if the standard weapon has hit an asteroid
void checkWeaponHit() {

  // Loop through the array list of asteroids
  for (int i = 0; i < asteroidArray.size(); i++) {
    Asteroid theAsteroid = (Asteroid) asteroidArray.get(i);
    
    // If the weapon has hit the asteroid
    if (mouseX < theAsteroid.location.x + theAsteroid.mass*16 && 
    mouseX > theAsteroid.location.x - theAsteroid.mass*16) {
      
      theAsteroid.health -= 1;
    
      // If the asteroid is dead
      if (theAsteroid.health <= 0) {
        createParticleSystem(theAsteroid);
        theAsteroid = null;
        asteroidArray.remove(i);
      }
      hits ++;
      score ++;
      flowFieldUpdated = false;
      
      if (score % 20 == 0) {
        particleWeaponNumber++;
        seekerWeaponNumber++;
      }
    }
  }
}


// This function checks if a particle from the special weapon has hit an asteroid
void checkSpecialWeaponHit() {

  // Loop through the array list of weapon particle systems
 for (ParticleSystem ps: weaponParticleSystemArray) {

    // Loop through the array list of asteroids
    for (int i = 0; i < asteroidArray.size(); i++) {
      Asteroid theAsteroid = (Asteroid) asteroidArray.get(i);

      // Check if any of the weapon particles have hit an asteroid
      if (ps.hitAsteroid(theAsteroid)) {
        createParticleSystem(theAsteroid);
        theAsteroid = null;
        asteroidArray.remove(i);
      }
    }
  }
}


// This function checks if an asteroid has hit the player ship
void checkAsteroidHitPlayer() {
  
  // Loop through the array list of asteroids
  for (int i = 0; i < asteroidArray.size(); i++) {
    Asteroid theAsteroid = (Asteroid) asteroidArray.get(i);
    
    // If the asteroid has hit the player ship
    if (theAsteroid.location.x >= mouseX-20 && theAsteroid.location.x <= mouseX-20 + 40 && 
    theAsteroid.location.y >= 830 && theAsteroid.location.y <= 830 + 30 && !gameOver) {
      
      if (!gameOver) finalMouseX = mouseX;
      playerParticleSystem(30);
      theAsteroid = null;
      asteroidArray.remove(i);
    }   
  }
}


// This function checks if an asteroid particle has hit the player ship
void checkParticleHitPlayer() {
  
   // Loop through the array list of asteroid particle systems
   boolean playerHit = false;
   for (ParticleSystem ps: asteroidParticleSystemArray) {
      // This checks if any of the particles have hit the player ship
      if (ps.hitPlayer()) playerHit = true;                                                                              
   }
    
   if (playerHit) {
     if (!gameOver) finalMouseX = mouseX;
     playerParticleSystem(30);
   }
}